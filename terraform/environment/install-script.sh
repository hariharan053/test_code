#!/bin/bash

## Below Command will initialize the terraform script and launch the infra.
terraform init
terraform apply --auto-approve
if [[ $? -ne 0 ]]; then
    exit 1
fi
## Store the Terraform output
terraform output > config
sed -i 's/ = /=/g' config
source ./config

aws configure set default.region $region

aws eks update-kubeconfig --name $cluster_name --region us-east-1

echo "OIDC Creation Started"
#Create Identity Provider for EKS
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve --region us-east-1
echo "Get OIDC URL"
OIDC_URL=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text)
OIDC_ID=$(echo $OIDC_URL | cut -f 5 -d "/")
OIDC_ARN=$(aws iam list-open-id-connect-providers | grep $OIDC_ID | awk '{print $2}')

echo "==============================================================================="
echo "Login to Docker"
echo "==============================================================================="
docker login --username concertohealthai --password Concerto@123
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/root/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

## Below is to get the OIDC details and mananger the EFS filesystem from EKS.
ISSUER_HOSTPATH=$(aws eks describe-cluster --name $cluster_name --query cluster.identity.oidc.issuer --output text | cut -f 3- -d'/')

aws iam create-policy --policy-name AmazonEKS_EFS_CSI_Driver_Policy --policy-document file://iam-policy-efs.json &> /dev/null

cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": $OIDC_ARN
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${ISSUER_HOSTPATH}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name $efs_role_name --assume-role-policy-document file://"trust-policy.json" &> /dev/null

aws iam attach-role-policy --policy-arn arn:aws:iam::$account_id:policy/$efs_role_policy --role-name $efs_role_name &> /dev/null

cat << EOF > efs-service-account.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: efs-csi-controller-sa
  namespace: kube-system
  labels:
    app.kubernetes.io/name: aws-efs-csi-driver
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$account_id:role/$efs_role_name
EOF

kubectl apply -f efs-service-account.yaml

echo "Deploy EFS Driver"
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/ &> /dev/null
helm repo update &> /dev/null
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver --namespace kube-system --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver --set controller.serviceAccount.create=false --set controller.serviceAccount.name=efs-csi-controller-sa &> /dev/null
echo "Deploy EFS Completed."

if [[ $? -ne 0 ]]; then
    exit 1
fi

cat << EOF > storageclass.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
EOF

kubectl apply -f storageclass.yaml

echo "==============================================================================="
echo "Deploying ALB Ingress"
echo "==============================================================================="
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.2/docs/install/iam_policy.json &> /dev/null
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy_EDGE --policy-document file://iam_policy.json &> /dev/null

cat <<EOF > load-balancer-role-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": $OIDC_ARN
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${ISSUER_HOSTPATH}:aud": "sts.amazonaws.com",
                    "${ISSUER_HOSTPATH}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

aws iam create-role --role-name AmazonEKSLoadBalancerControllerRole_EDGE --assume-role-policy-document file://"load-balancer-role-trust-policy.json" &> /dev/null
aws iam attach-role-policy --policy-arn arn:aws:iam::$account_id:policy/AWSLoadBalancerControllerIAMPolicy_EDGE --role-name AmazonEKSLoadBalancerControllerRole_EDGE &> /dev/null

cat << EOF > aws-load-balancer-controller-service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$account_id:role/AmazonEKSLoadBalancerControllerRole_EDGE
EOF

kubectl apply -f aws-load-balancer-controller-service-account.yaml

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=dts-edge-server \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller


echo "==============================================================================="
echo "Deploying Postgres service"
echo "==============================================================================="
helm install pgsql-db ./helm-postgresql
sleep 10


## Update kubeconfig with new cluster created.
echo "==============================================================================="
echo "Deploying Application"
echo "==============================================================================="
helm template helm/dts-edge/dts-edge-server/micro-service/ -f helm/config/dts-edge/dts-edge-server.yml | kubectl apply -f -
sleep 30


## Below Script is to monitor the status for the running pods.
ns='default'

result=1

# Get the pod record from 'kubectl get pods'
p=$(kubectl get pods --namespace ${ns})

if [ -n "${p}" ]; then
    pod_name=$(echo -n "${p}" | awk '{print $1}')
    ready=$(echo -n "${p}" | awk '{print $2}')
    ready_actual=$(echo -n "${ready}" | awk -F/ '{print $1}')
    ready_max=$(echo -n "${ready}" | awk -F/ '{print $2}')
    status=$(echo -n "${p}" | awk '{print $3}')

    echo -e "... pod ${pod_name};\n ready is ${ready};\n ready_actual is ${ready_actual};\n ready_max is ${ready_max};\n status is ${status}\n"
    if [ "${ready_actual}" == "${ready_max}" ] && [ "${status}" == "Running" ]; then
        result=0
    fi
else
    echo "ERROR: Pod ${pod} not found"
fi

echo "Result: ${result}"

exit ${result}


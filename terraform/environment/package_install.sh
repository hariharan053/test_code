#!/bin/bash
packages=("terraform" "helm" "kubectl" "aws-iam-authenticator" "eksctl")
bin_path=/usr/local/bin/
tf_url="https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip"
helm_url="https://get.helm.sh/helm-v3.6.2-linux-amd64.tar.gz"
kubectl_url="https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl"
iam_auth_url="https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator"
eksctl_url="https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"

mkdir -p $bin_path

validate_url () {
        status="$(curl -L -Is $1 | head -1)"
        validate=( $status )
        if [ -z "$validate" ]
        then
          url="false"
          echo "Unable to acess the URL $1,  please check the firewall!"
        else
        if [ ${validate[-2]} == "200" ] || [ ${validate[-2]} == "302" ]; then
          echo "OK"
          url="true"
        else
          url="false"
          echo "Unable to acess the URL $1,  please check the firewall!"
        fi
        fi
}

install_terraform () {
        validate_url $tf_url
        if [ "$url" == "true" ]
        then
                echo "=============================================================================="
                echo "=============== Downloading & Installing Terraform ==========================="
                echo "=============================================================================="
                wget $tf_url
                sudo unzip terraform_0.12.31_linux_amd64.zip -d $bin_path
                echo "Terraform installed"
                $bin_path/terraform version
                rm -rf terraform_0.12.6_linux_amd64.zip
                echo "=============================================================================="
                echo "=================== Terraform (0.12.6) Installed ============================="
                echo "=============================================================================="
        fi
}

install_helm () {
        #wget $helm_url
        validate_url $helm_url
        if [ "$url" == "true" ]
        then
                echo "Downloadiing the package"
                wget $helm_url
                tar -xzf helm-v3.6.2-linux-amd64.tar.gz
                sudo mv linux-amd64/helm  $bin_path
                echo "Cleaning the temp files"
                rm -rf helm-v3.6.2-linux-amd64.tar.gz
        fi
}

install_kubectl () {
        validate_url $kubectl_url
        if [ "$url" == "true" ]
        then
                echo "Downloadiing the package"
                sudo curl -o $bin_path/kubectl $kubectl_url
                sudo chmod +x $bin_path/kubectl
        fi
}

install_aws_auth () {
        echo "Installing"
        validate_url $kubectl_url
        if [ "$url" == "true" ]
        then
                echo "Downloadiing the package"
                sudo curl -o $bin_path/aws-iam-authenticator $iam_auth_url
                sudo chmod +x $bin_path/aws-iam-authenticator
        fi
}

install_eksctl () {
        validate_url $eksctl_url
        if [ "$url" == "true" ]
        then
                echo "Downloadiing the package"
                curl --silent --location "$eksctl_url" | sudo tar xz -C $bin_path
                sudo chmod +x $bin_path/eksctl
        fi
}

check_package () {
for package in ${packages[*]}
do
        if [ -e $bin_path/$package ]
        then
            echo "Verified  $package is installedi!"
            #$bin_path/$package version
        else
            echo "Installing $package"
            sleep 3
            if [ "$package" == "aws-iam-authenticator" ]
            then
                    install_aws_auth
            else
                    install_$package
            fi
fi
done
}
check_package

check_version () {
        for package in ${packages[*]}
        do
                $package version
                which $package
        done
}
check_version

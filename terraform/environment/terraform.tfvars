## Global Values
region = "us-east-1"                            #example for us-east-1.
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
aws_account_id = ""                 # provider account id where DTS edge server need to be deployed
env = "prod"                                    # deployment tag
environment = "test"                  # deployment tag
instance_vpc_cidr_range = "10.171.0.0/21"       # enter VPC Network range where DTS deployment instance is running.
eks_ami_id = "ami-0f80e6144aa24f34d"            # EKS node AMI version 1.22

## Please provide existing VPC details in which EKS has to be deployed- 
vpc_id = ""                # existing VPC ID
private_subnet = "[]"
vpc_cidr_range = ["10.164.8.0/21"]              # enter VPC Network range.

## EKS Clsuter Values
eks_cluster_name = "test"     # EKS Cluster Name
worker_instance_types = "m5.2xlarge"            # instance type - default to m4.xlarge
workers_instance_count = "3"                    # number of EKS nodes - default to minimum 3 nodes and max (3 + 5)
key_name = "test"                 # AWS key pair for EKS nodes
fargate_enable = "false"                        # currently only default false is supported


## EFS Values
efs_name = "dts-edge-efs"                       # EFS volume name
efs_role_name = "EFS_DRVIER_ROLE_DTS_EDGE"               # Please change this name if you are creating a new cluster. Or else it will be the conflict or Delete this if already there.
efs_role_policy = "EFS_DRIVER_POLICY_DTS_EDGE"           # Please change this name if you are creating a new cluster. Or else it will be the conflict or Delete this if already there.

##Bucket Name
s3_bucket = "test"                   # Bucket will be used For EKS Node for application to run. It will be added in EKS Node Role.
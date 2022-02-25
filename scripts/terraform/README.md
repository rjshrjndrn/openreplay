export AWS_DEFAULT_REGION="eu-west-1"
cd to directory
tf init 
tf plan -var-file="env/terraform.tfvars"
tf apply -var-file="env/terraform.tfvars"

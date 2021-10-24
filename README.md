# aws-infra-intw-dd

# Limitation/Issue
1. Subnet CIDR Calculation can be better.
2. Using Single Subnet may cause RDS creation to Fail (Min 2 Required)
3. VPC NACL Can be restricted for Ephemeral ports and Health Checks
4. ..
# To Improve:
1. RDS Username & Password via AWS Secret Manager
2. Connection to WebServer Private instances should be made via SessionManager, and BH totally removed.
3. CI/CD should laverage on "terraform plan -out xxx"
4. Addition of Terragrunt
5. Tests automation with Terratest.
6. ..


# General Instructions

1. Backend Initialization:

    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress/components/remote-state \
    init \
    -backend-config="../../environments/dev.backend.tfvars" \
    && \
    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress/components/automations \
    init \
    -backend-config="../../environments/dev.backend.tfvars" \
    &&
    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress/components/infrastructure \
    init \
    -backend-config="../../environments/dev.backend.tfvars"


2. Apply first the remote-state component (Required for storing tf state for the other components)

    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress/components/remote-state \
    apply \
    -var-file="../../environments/dev.tfvars" \
    -var-file="../../regions/eu-central-1.tfvars"

3. Apply Infrastructure component

    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress/components/infrastructure \
    apply \
    -var-file="../../environments/dev.tfvars" \
    -var-file="../../regions/eu-central-1.tfvars"

4. Apply automations components

    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress/components/automations \
    apply \
    -var-file="../../environments/dev.tfvars" \
    -var-file="../../regions/eu-central-1.tfvars"
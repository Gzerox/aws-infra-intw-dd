# aws-infra-intw-dd


    docker run --rm -i -t -v $PWD:$PWD -w $PWD --env-file aws.env \
    hashicorp/terraform:1.0.9 \
    -chdir=applications/wordpress \
    plan \
    -var-file="../../environments/dev.tfvars" \
    -var-file="../../regions/eu-central-1.tfvars"
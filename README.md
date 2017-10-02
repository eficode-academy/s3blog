# s3blog

# Prerequisites

  * Terraform
  * Docker
  * Git

# Building the website
Build the website using the `./build-local.sh` command.

This will use the docker image to build the jekyll site.

# Serving the website

Build the website using the `./serve-local.sh` command.

This will use the docker image to build the jekyll site.

# Creating the basic bucket infrastructure

The bucket and cloudfront infrastructure is defined in `aws.tf` terraform model.

terraform plan
terraform apply

# Deploy the website with circleci

# Point your DNS to the bucket hosting

# Create certificates with letsencrypt

 1. Run this to create the tokens
 2. Add the tokens to the `_site` during the jekyll build
 3. Push them to deploy
 4. Finish the letsencrypt session
 5. Store the certificates somewhere safe
 6. Upload them to the AWS Certificate Manager (us-east-1)

# 

#!/bin/bash

################################################################
# This script will list all the resources in the AWS Account   #
# Author: Naman/Devops Team                                    #
# Version: v0.0.1                                              #
# Date: 10/10/2021                                             #
################################################################
# Following are the suppoted AWS services by the script        #
# 1. EC2                                                       #
# 2. S3                                                        #
# 3. RDS                                                       #
# 4. DynamoDB                                                  #
# 5. Lambda                                                    #
# 6. VPC                                                       #
# 7. IAM                                                       #
# 8. CloudFront                                                #
# Usage: ./aws_resource_list.sh <region> <service_name>        #
# Example: ./aws_resource_list.sh us-east-1 ec2                #
################################################################

# Check if the required number of arguments are passed
if [ $# -ne 2 ]; then
  echo "Usage: $0 <region> <service_name>"
  exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it first."
  exit 1
fi

# Check if the AWS CLI is configured
if [ ! -d ~/.aws ]; then
  echo "AWS CLI is not configured. Please configure it first."
  exit 1
fi

# Execute the AWS CLI command based on the service name
case $2 in
  ec2)
    aws ec2 describe-instances --region $1
    ;;
  s3)
    aws s3api list-buckets --region $1
    ;;
  rds)
    aws rds describe-db-instances --region $1
    ;;
  dynamodb)
    aws dynamodb list-tables --region $1
    ;;
  lambda)
    aws lambda list-functions --region $1
    ;;
  vpc)
    aws ec2 describe-vpcs --region $1
    ;;
  iam)
    aws iam list-users --region $1
    ;;
  cloudfront)
    aws cloudfront list-distributions --region $1
    ;;
  *)
    echo "Invalid service name. Supported services are: ec2, s3, rds, dynamodb, lambda, vpc, iam, cloudfront"
    exit 1
    ;;
esac
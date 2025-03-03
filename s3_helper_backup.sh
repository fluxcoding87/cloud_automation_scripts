#!/bin/bash

####################################################################################
# This script is a helper script for a bigger script written in automated_backups.py#
# This script creates an S3 Bucket named backup-bucket if it does not exist       
# Author: Naman/Devops Team
# Version: v0.0.1                                                                                   
####################################################################################


# Check for positional arguments
if  [ $# -ne 1 ]; then
  echo "Usage: $0 <Bucket Name>"
  exit 3
fi

# Check if aws cli is installed
if ! command -v aws &>/dev/null; then
  echo "AWS CLI is not installed"
  exit 1
fi

# Check if aws is not configured
if [ ! -d ~/.aws ]; then
  echo "AWS CLI is not configured"
  exit 2
fi  


if ! aws s3 ls s3://$1/ &>/dev/null; then
  echo "Creating AWS S3 Bucket:$1"
  aws s3 mb s3://$1/ --region ap-south-1
  if [ $? -eq 0 ]; then
    echo "Bucket $1 Sucessfully Created!"
    exit 0
  else
    echo "Failed to create bucket"
    exit 4
  fi
else
  echo "S3 Bucket: $1 Already Present!"
  echo "Continuing....."
  exit 0
fi

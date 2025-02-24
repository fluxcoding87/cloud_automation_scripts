#!/bin/bash

#############################################################
# This script will create and manage the S3 bucket in AWS   #
# Author: Naman/Devops Team                                 #
# Version: v0.0.1                                           #
#############################################################
# Following are the required parameters for the script      #
# 1. Bucket Name                                            #                                               #
# Usage: ./manage_s3.sh <bucket_name>                       #
# Example: ./manage_s3.sh create my-bucket us-east-1        #
#############################################################

# Checking Positional Arguments
if [ $# -ne 1 ]; then
  echo "Usage $0 <bucket_name>"
  exit 1
fi

BUCKET_NAME=$1

# Checking if aws cli is present
if ! command -v aws &>/dev/null; then
  echo "AWS CLI Not FOUND"
fi

# Checking if aws cli is configured or not
if [ ! -d ~/.aws ]; then
  echo "AWS CLI NOT CONFIGURED"
fi


main_menu(){
  echo "----------------------------------------------"
  echo "MANAGE S3 BUCKETS"
  echo "Choose between these options"
  echo "1. Create S3 bucket"
  echo "2. Delete S3 bucket"
  echo "3. List contents of bucket"
  echo "4. Upload files or dir to bucket"
  echo "----------------------------------------------"

  read -r -p "Choose an option: " operation
}

create_bucket(){
  echo "Creating S3 Bucket:$BUCKET_NAME..."
  aws s3 mb s3://$BUCKET_NAME --region ap-south-1

  if [ $? -eq 0 ]; then
    echo "S3 Bucket created sucessfully : $BUCKET_NAME"
  else 
    echo "Error: Failed to create S3 Bucket"
    exit 1
  fi
}

upload_files(){
  read -r -p "Enter the path of the file or directory you want to upload: " FILE_PATH

  # Check if the provided path is a directory or a file
  if [ -d "$FILE_PATH" ]; then
    echo "Uploading directory to S3 Bucket..."
    aws s3 cp "$FILE_PATH" s3://$BUCKET_NAME/ --recursive
  else
    echo "Uploading file to S3 Bucket..."
    aws s3 cp "$FILE_PATH" s3://$BUCKET_NAME/
  fi

  if [ $? -eq 0 ]; then
    echo "Upload successful: $FILE_PATH"
  else 
    echo "ERROR: Failed to upload."
    exit 1
  fi
}

list_contents(){
  echo "Listing the S3 Bucket $BUCKET_NAME contents..."
  aws s3 ls s3://$BUCKET_NAME/
}

delete_bucket(){
  # Check if the bucket exists
  if ! aws s3 ls s3://$BUCKET_NAME/ &>/dev/null; then
    echo "BUCKET:$BUCKET_NAME NOT FOUND"
    exit 1
  fi
  # Ask for confirmation before removing
  read -r -p "Are you sure you want to delete this S3 Bucket:$BUCKET_NAME and ALL its contents (Irreversible)? [y/N]: " confirm
  if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "Removing S3 Bucket: $BUCKET_NAME ...."
    aws s3 rm s3://$BUCKET_NAME/ --recursive
    echo "BUCKET:$BUCKET_NAME emptied..."
    echo "Now deleting the bucket completly"
    aws s3api delete-bucket --bucket $BUCKET_NAME --region ap-south-1

    if [ $? -eq 0 ]; then
      echo "BUCKET:$BUCKET_NAME deleted sucessfully!"
    else
      echo "BUCKET:$BUCKET_NAME deletion failed!"
    fi
  fi
} 

main_menu

case $operation in
    1)
      create_bucket
      read -r -p "Do you want to copy a file to S3 BUCKET:$BUCKET_NAME? [y/N]: " response
      if [[ $response =~ ^[Yy]$ ]]; then
        upload_files
      else
        exit 0;
      fi
    ;;
    2)
      delete_bucket
    ;;
    3)
      list_contents
    ;;
    4)
      upload_files
    ;;
    *)
      echo "Invalid Option"
    ;;
esac
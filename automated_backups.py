import subprocess
import boto3
import io
import tarfile
from datetime import datetime

def backupAndUploadToS3(sourcePath:str="/home/naman-pandey/backups"):
  s3 = boto3.client("s3")
  print(f"Making backup of {sourcePath} to S3 Bucket")
  fileDate = datetime.now()

  #Creating an in memory bytes buffer isong io.BytesIO()
  tar_buffer = io.BytesIO()

  # Compress the dir/file to in-memory buffer
  with tarfile.open(fileobj=tar_buffer,mode="w:gz") as tar:
    tar.add(sourcePath,arcname=sourcePath)

  # Move the buffer file pointer at the begining
  tar_buffer.seek(0)

  # Upload the tar.gz file directely to in-memory buffer
  objectPath=f"Backup-{fileDate}.tar.gz"
  s3.upload_fileobj(tar_buffer,"fluxcoding87-backup",objectPath)



if __name__ == "__main__":
  print("Checking S3 Bucket (if not present then creating one)")
  bucket = subprocess.run(["./s3_helper_backup.sh", "fluxcoding87-backup"])
  try:
    if (bucket.returncode != 0):
      print(f"Something Went Wrong!\nError:{bucket.stderr.decode()}")
      exit
    else:
      # sourcePath = input("Enter the desired path")
      backupAndUploadToS3()
      print(f"SourcePath: ~/backups backed up sucessfully")
      exit
  except Exception as e:
    print(f"Something went wrong\nError:{e}")
  finally:
    print("Exiting...")
    exit





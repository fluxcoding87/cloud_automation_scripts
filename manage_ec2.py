import boto3
import time
from typing import Literal,Optional

#######################################################################################
# This python script can be used to manage ec2 instances
# Author: Naman/Devops Team
# Date: 25 Feb 2025
# Version: v0.0.1
#######################################################################################
# Usage: Run this python script and a menu will be prompted on CLI
#######################################################################################


# Create a High level Ec2 resource
ec2Res = boto3.resource('ec2')

# Create a low level AWS API friendly client
ec2Client = boto3.client("ec2")

instanceTypes=["t2.nano" , "t2.micro" , "t2.small" , "t2.medium", "t2.large"]
def launchEC2Instances(instanceType:str, MinCount:int
                       ,MaxCount:int, KeyName:str, SgIds:Optional[list[str]]=None):
  try:
    print("Launching EC2 Instances")
    if (MinCount<0 or MaxCount>10):
      print("Count error, cannot create more than 10 or less than 1 instance")
      return
    else:
      instances = ec2Res.create_instances(
        ImageId ="ami-0fcfcdc5efc25e0bc",
        InstanceType=instanceType,
        MinCount=MinCount,
        MaxCount=MaxCount,
        KeyName=KeyName,
        SecurityGroupIds=SgIds if SgIds is not None else ["sg-01e401f13d10c1158"]
      )
      # Wait till the instance is running
      instances[0].wait_until_running()
      instances[0].reload() # Refresh the instance attrs
      print(f"Instance launched: {instances[0].id} - State: {instances[0].state['Name']}")
      return instances[0].id
  except Exception as e:
    print(f"EXCEPTION OCCURED(LAUNCHING): {e}")
    return None

# launchEC2Instances('t2.micro',1,1,"GenericInstance")
def listAllInstances():
  try:
    print("Listing the running instances")
    instances = ec2Res.instances.all()

    for instance in instances:
      print(f"Instance ID: {instance.id}\tPublic IP: {instance.public_ip_address}\tInstance State:{instance.state["Name"]}")

  except Exception as e:
    print(f"LISTING_EXCEPTION: {e}")


def startInstance(instanceId:str):
  try:
    print(f"\nStarting the instance with id: {instanceId}")
    ec2Client.start_instances(InstanceIds=[instanceId])

    #Wait until the instance is up and running
    waiter = ec2Client.get_waiter("instance_running")
    waiter.wait(InstanceIds=[instanceId])

    print(f"EC2 Instance with id: {instanceId} has started sucessfully")

  except Exception as e:
    print(f"Something went wrong\n(Starting)Error:{e}")

def stopInstance(instanceId:str):
  try:
    print(f"\nStopping the instance with id: {instanceId}")
    ec2Client.stop_instances(InstanceIds=[instanceId])

    #Wait until the instance is stopped
    waiter = ec2Client.get_waiter("instance_stopped")
    waiter.wait(InstanceIds=[instanceId])
    print(f"Instance with id: {instanceId} stopped sucessfully!")
  except Exception as e:
    print(f"Something went wrong!\n(Stopping)Error:{e}")

def terminateInstance(instanceId:str):
  try:
    print(f"\nTerminating the instance with id: {instanceId}")
    ec2Client.terminate_instances(InstanceIds=[instanceId])

    #Wait until the instance is stopped
    waiter = ec2Client.get_waiter("instance_terminated")
    waiter.wait(InstanceIds=[instanceId])
    print(f"Instance with id: {instanceId} terminated sucessfully!")
  except Exception as e:
    print(f"Something went wrong!\n(Terminate)Error:{e}")


def mainMenu()->int:
  print("AWS EC2 INSTANCE MANAGER")
  print("-------------------------------------------------------")
  print("CHOOSE OPTIONS FROM BELOW")
  print("1. Create an Instance")
  print("2. Terminate an Instance")
  print("3. List Running Instances")
  print("4. Start an Instance")
  print("5. Stop an Instance")
  print("6. Exit")
  print("-------------------------------------------------------")
  option = input("Your option: ")
  return int(option)




if __name__=="__main__":
  instanceId:str|None=None
  option = mainMenu()
  match option:
    case 1:
      print("\nDefault OS is ubuntu-24:lts\nChoose from instance types")
      for index,instanceType in enumerate(instanceTypes):
       print(f"{index}. {instanceType}")
      instanceOptionIdx = int(input(f"Choose an option for instance type (0-4): "))
      MinCount = int(input("Minimum number of Instances to create (not<0): "))
      MaxCount = int(input("Maximum number of Instances to create (not>10): "))
      KeyName = input("Enter the key name: ")
      SgIdsTemp= input("Specify the security group id(s). [If multiple seperate with a comma(,) and WITHOUT SPACES]: ")
      SgIds=[]
      if "," in SgIdsTemp:
        SgIds=SgIdsTemp.split(",")
      else:
        SgIds=[f"{SgIdsTemp}"]
      instanceId=launchEC2Instances(instanceType=instanceTypes[instanceOptionIdx],MinCount=MinCount,MaxCount=MaxCount,KeyName=KeyName,SgIds=SgIds)
    case 2:
      instanceId = input("\nEnter the instance id: ")
      terminateInstance(instanceId)
    case 3:
      listAllInstances()
    case 4:
      instanceId = input("\nEnter the instance id: ")
      startInstance(instanceId)
    case 5:
      instanceId = input("\nEnter the instance id: ")
      stopInstance(instanceId)
    case _:
      print("Invalid Option(Choose from 1-5)")
      exit

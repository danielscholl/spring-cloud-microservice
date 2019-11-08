#!/usr/bin/env bash
#
#  Purpose: Remove a Microservice from Spring Cloud
#  Usage:
#    remove.sh
###############################
## ARGUMENT INPUT            ##
###############################

usage() { echo "Usage: install.sh " 1>&2; exit 1; }

if [ -f ./.envrc ]; then source ./.envrc; fi
if [ -f ../functions.sh ]; then source ../functions.sh; fi

if [ ! -z $1 ]; then PROJECT_INITIALS=$1; fi
if [ -z $PROJECT_INITIALS ]; then
  PROJECT_INITIALS="CAT"
fi

if [ -z $ARM_SUBSCRIPTION_ID ]; then
  tput setaf 1; echo 'ERROR: ARM_SUBSCRIPTION_ID not provided' ; tput sgr0
  usage;
fi

if [ -z $PREFIX ]; then
  PREFIX="osdu"
fi

###############################
## Azure Intialize           ##
###############################
RESOURCE_GROUP="$PREFIX-resources"

printf "\n"
tput setaf 2; echo "Deploying the App to Spring Cloud" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
printf "\n"

tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${ARM_SUBSCRIPTION_ID}

tput setaf 2; echo "Gathering information for Spring Cloud..." ; tput sgr0
SPRING_CLOUD_INSTANCE=$(GetSpringCloud $RESOURCE_GROUP)
echo $SPRING_CLOUD_INSTANCE

tput setaf 2; echo "Getting Spring Cloud App..." ; tput sgr0
SPRING_CLOUD_APP=${PWD##*/}
GetSpringCloudApp $SPRING_CLOUD_APP $SPRING_CLOUD_INSTANCE $RESOURCE_GROUP

tput setaf 2; echo 'Deploying the Spring Cloud App...' ; tput sgr0
az spring-cloud app delete \
  --name $SPRING_CLOUD_APP \
  --service $SPRING_CLOUD_INSTANCE \
  --resource-group $RESOURCE_GROUP -ojsonc

tput setaf 2; echo 'Cleaning up the resources...' ; tput sgr0
./mvnw clean

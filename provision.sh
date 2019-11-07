
#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    install.sh


###############################
## ARGUMENT INPUT            ##
###############################

usage() { echo "Usage: install.sh " 1>&2; exit 1; }

if [ -f ./.envrc ]; then source ./.envrc; fi
if [ -f ./scripts/functions.sh ]; then source ./scripts/functions.sh; fi

if [ ! -z $1 ]; then PROJECT_INITIALS=$1; fi
if [ -z $PROJECT_INITIALS ]; then
  PROJECT_INITIALS="CAT"
fi

if [ -z $ARM_SUBSCRIPTION_ID ]; then
  tput setaf 1; echo 'ERROR: ARM_SUBSCRIPTION_ID not provided' ; tput sgr0
  usage;
fi

if [ -z $AZURE_LOCATION ]; then
  tput setaf 1; echo 'ERROR: AZURE_LOCATION not provided' ; tput sgr0
  usage;
fi

if [ -z $PREFIX ]; then
  PREFIX="osdu"
fi

###############################
## Azure Intialize           ##
###############################

printf "\n"
tput setaf 2; echo "Creating Spring Cloud Resources" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
printf "\n"

tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${ARM_SUBSCRIPTION_ID}

tput setaf 2; echo 'Registering Resource Provider...' ; tput sgr0
ResourceProvider Microsoft.AppPlatform

tput setaf 2; echo 'Creating the Resource Group...' ; tput sgr0
RESOURCE_GROUP="$PREFIX-resources"
CreateResourceGroup $RESOURCE_GROUP $AZURE_LOCATION

tput setaf 2; echo 'Creating the Spring Cloud App...' ; tput sgr0
SPRING_CLOUD_INSTANCE="springcloud$UNIQUE"
CreateSpringCloud $SPRING_CLOUD_INSTANCE $RESOURCE_GROUP $AZURE_LOCATION

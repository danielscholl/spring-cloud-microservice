
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
## FUNCTIONS                 ##
###############################
function CreateResourceGroup() {
  # Required Argument $1 = RESOURCE_GROUP
  # Required Argument $2 = LOCATION

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $2 ]; then
    tput setaf 1; echo 'ERROR: Argument $2 (LOCATION) not received'; tput sgr0
    exit 1;
  fi

  local _result=$(az group show --name $1)
  if [ "$_result"  == "" ]
    then
      if [ -z $PROJECT_UNIQUE ]; then
        if [ "$(uname)" == "Darwin" ]; then
          UNIQUE=$(jot -r 1 100 999)
        else
          UNIQUE=$(shuf -i 100-999 -n 1)
        fi
      else UNIQUE=$PROJECT_UNIQUE; fi

      OUTPUT=$(az group create --name $1 \
        --location $2 \
        --tags RANDOM=$UNIQUE contact=$PROJECT_INITIALS \
        -ojsonc)
      tput setaf 3;  echo "Created Resource Group $1."; tput sgr0
    else
      tput setaf 3;  echo "Resource Group $1 already exists."; tput sgr0
      UNIQUE=$(az group show --name $1 --query tags.RANDOM -otsv)
    fi
}

function ResourceProvider() {
  # Required Argument $1 = RESOURCE_PROVIDER

  local _result=$(az provider show --namespace $1 --query registrationState -otsv)
  if [ "$_result"  == "" ]
    then
      az provider register --namespace $1
    else
    tput setaf 3;  echo "Resource Provider $1 already registered."; tput sgr0
  fi
}

function CreateSpringCloud() {
  # Required Argument $1 = INSTANCE_NAME
  # Required Argument $2 = RESOURCE_GROUP
  # Required Argument $3 = LOCATION

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (INSTANCE_NAME) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $2 ]; then
    tput setaf 1; echo 'ERROR: Argument $2 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $3 ]; then
    tput setaf 1; echo 'ERROR: Argument $3 (LOCATION) not received'; tput sgr0
    exit 1;
  fi


  local _result=$(az spring-cloud show --name $1 --resource-group $2 -ojsonc)
  if [ "$_result"  == "" ]
    then
      az spring-cloud create --name $1 --resource-group $2 --location $3 --query name -otsv
    else
      tput setaf 3;  echo "Spring Cloud Instance $1 already exists."; tput sgr0
    fi
}

function CreateSpringCloudApp() {
  # Required Argument $1 = APP_NAME
  # Required Argument $2 = INSTANCE_NAME
  # Required Argument $3 = RESOURCE_GROUP

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (APP_NAME) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $2 (INSTANCE_NAME) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $3 ]; then
    tput setaf 1; echo 'ERROR: Argument $3 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi

  local _result=$(az spring-cloud app show --name $1 --service $2 --resource-group $3 -ojsonc)
  if [ "$_result"  == "" ]
    then
      az spring-cloud app create --name $1 --service $2 --resource-group $3 --is-public true --cpu 1 --memory 1 --instance-count 1 --query name -otsv
    else
      tput setaf 3;  echo "Spring Cloud App $1 already exists."; tput sgr0
    fi
}

function DeployCloudApp() {
  # Required Argument $1 = JAR_FILE
  # Required Argument $2 = APP_NAME
  # Required Argument $3 = INSTANCE_NAME
  # Required Argument $4 = RESOURCE_GROUP

if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (JAR_FILE) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $2 ]; then
    tput setaf 1; echo 'ERROR: Argument $2 (APP_NAME) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $3 ]; then
    tput setaf 1; echo 'ERROR: Argument $3 (INSTANCE_NAME) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $4 ]; then
    tput setaf 1; echo 'ERROR: Argument $4 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi

  tput setaf 2; echo 'Packaging the App...' ; tput sgr0
  ./mvnw clean package

  tput setaf 2; echo 'Deploying the App...' ; tput sgr0
  az spring-cloud app deploy --name $2 --service $3 --resource-group $4 --jar-path target/$1 --query properties.status

  az spring-cloud app show --name $2 --service $3 --resource-group $4 --query properties.url
}


###############################
## Azure Intialize           ##
###############################

tput setaf 2; echo 'Logging in and setting subscription...' ; tput sgr0
az account set --subscription ${ARM_SUBSCRIPTION_ID}

tput setaf 2; echo 'Registering Resource Provider...' ; tput sgr0
ResourceProvider Microsoft.AppPlatform


printf "\n"
tput setaf 2; echo "Defining the Resource Group" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
RESOURCE_GROUP="$PREFIX-resources"
CreateResourceGroup $RESOURCE_GROUP $AZURE_LOCATION


printf "\n"
tput setaf 2; echo "Defining the Spring Cloud" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
SPRING_CLOUD_INSTANCE="springcloud$UNIQUE"
SPRING_CLOUD_APP="spring-cloud-microservice"
CreateSpringCloud $SPRING_CLOUD_INSTANCE $RESOURCE_GROUP $AZURE_LOCATION

tput setaf 2; echo 'Creating the Spring Cloud App...' ; tput sgr0
CreateSpringCloudApp $SPRING_CLOUD_APP $SPRING_CLOUD_INSTANCE $RESOURCE_GROUP


printf "\n"
tput setaf 2; echo "Deploying the App to Spring Cloud" ; tput sgr0
tput setaf 3; echo "------------------------------------" ; tput sgr0
JAR_FILE="$ARTIFACT-$VERSION.jar"
DeployCloudApp $JAR_FILE $ SPRING_CLOUD_APP $SPRING_CLOUD_INSTANCE $RESOURCE_GROUP



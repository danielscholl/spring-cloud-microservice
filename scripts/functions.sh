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

function GetUnique() {
  # Required Argument $1 = RESOURCE_GROUP

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi

  tput setaf 3;  echo "Retrieving UNIQUE tag from $1."; tput sgr0
  UNIQUE=$(az group show --name $1 --query tags.RANDOM -otsv)
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

function GetSpringCloud() {
  # Required Argument $1 = RESOURCE_GROUP

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (RESOURCE_GROUP) not received' ; tput sgr0
    exit 1;
  fi

  local _springcloud=$(az spring-cloud list --resource-group $1 --query [].name -otsv)
  echo ${_springcloud}
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

  local _result=$(az spring-cloud app show --name $1 --service $2 --resource-group $3 --query properties.appName)
  if [ "$_result"  == "" ]
    then
      az spring-cloud app create --name $1 --service $2 --resource-group $3 --is-public true --cpu 1 --memory 1 --instance-count 1 --query name -otsv
    else
      tput setaf 3;  echo "Spring Cloud App $1 already exists."; tput sgr0
    fi

  local _url=$(az spring-cloud app show --name $1 --service $2 --resource-group $3 --query properties.url -otsv)
  echo ${_url}
}

function GetSpringCloudApp() {
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

  local _springcloudapp=$(az spring-cloud app show --name $1 --service $2 --resource-group $3 --query name -otsv)
  echo ${_springcloudapp}
}

function GetSpringCloud() {
  # Required Argument $1 = RESOURCE_GROUP

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (RESOURCE_GROUP) not received' ; tput sgr0
    exit 1;
  fi

  local _cosmosdb=$(az cosmosdb list --resource-group $1 --query [].name -otsv)
  echo ${_cosmosdb}
}

function CreateCosmosDb() {
  # Required Argument $1 = APP_NAME
  # Required Argument $2 = RESOURCE_GROUP

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (APP_NAME) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $2 ]; then
    tput setaf 1; echo 'ERROR: Argument $2 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi


  local _result=$(az cosmosdb show --name $1 --resource-group $2 --query name)
  if [ "$_result"  == "" ]
    then
      az cosmosdb create --name $1 --resource-group $2 --query name -otsv
    else
      tput setaf 3;  echo "CosmosDb $1 already exists."; tput sgr0
    fi
}

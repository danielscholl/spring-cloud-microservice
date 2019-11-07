# Spring Cloud Microservice

### Create Environment File

Create an environment setting file in the root directory ie: `.env.ps1` or `.envrc`

Default Environment Settings

| Parameter             | Default                              | Description                              |
| --------------------  | ------------------------------------ | ---------------------------------------- |
| _ARM_SUBSCRIPTION_ID_ | xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Azure Subscription Id                    |
| _AZURE_LOCATION_      | CentralUS                            | Azure Region for Resources to be located |
| _ARTIFACT_            | Demo                                 | ArtifactId located in the pom.xml        |
| _VERSION_             | 0.0.1-SNAPSHOT                       | Version located in the pom.xml           |


### Provision Infrastruture and Deploy Microservice

>Note:  This can be performed via Portal UI or CloudShell (Bash/Powershell)

__Provision using Bash__

The Spring Cloud CLI extension must be added to your CLI
`az extension add -y --source https://azureclitemp.blob.core.windows.net/spring-cloud/spring_cloud-0.1.0-py2.py3-none-any.whl`

```bash
./install.sh
```

__Provision using Portal__

TODO:// Create ARM Template

__Manual Provision using CLI__

```bash
RESOURCE_GROUP="<your_resource_group>"
LOCATION="westus2"
INSTANCE_NAME="<your_unique_name>"
APP_NAME="<your_app_name>"

# Generate a new Spring Microservice
curl https://start.spring.io/starter.tgz \
  -d dependencies=web \
  -d baseDir=spring-cloud-microservice \
  -d bootVersion=2.1.9.RELEASE | tar -xzvf -

# Create a Spring Cloud Instance
az spring-cloud create -n $INSTANCE -g $RESOURCE_GROUP -l $LOCATION

# Create a Spring Cloud Application
az spring-cloud app create -n $APP_NAME -s $INSTANCE_NAME \
  --is-public true \
  --cpu 1 \
  --memory 1 \
  --instance-count 1

# Build and Deploy the Application
./mvnw clean package
az spring-cloud app deploy --name $APP_NAME --service $INSTANCE_NAME --resource-group $RESOURCE_GROUP \
  --jar-path target/demo-0.0.1-SNAPSHOT.jar
```

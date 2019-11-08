# Getting Started

__Initial Scaffold Command__

```bash
curl https://start.spring.io/starter.tgz \
  -d dependencies=webflux,cloud-eureka,cloud-config-client \
  -d baseDir=city-service \
  -d bootVersion=2.1.9.RELEASE \
  | tar -xzvf -
```

__Run the App Locally__

//TODO: Configure something to replace mongo locally.

```bash
./mvnw spring-boot:run

```

__Deploy the Microservice__

Add in some cities into the City Collection in CosmosDB

```json
{
    "name": "Paris, France"
}
```

```json
{
    "name": "London, UK"
}
```

```bash
./deploy.sh
curl https://<spring_cloud_name>-simple-service.azuremicroservices.io
# Reponse

```

__Bind the Cosmos DB database to the application__

The Microservice Application needs to be bound to the the Cosmos DB database we created.

1. Select the App in the Spring Cloud Cluster
2. Go to Service Bindings
3. Crate a cosmosdb-city service binding selecting the cosmosdb that was created.


__Remove the Microservice__

```bash
./remove.sh
```


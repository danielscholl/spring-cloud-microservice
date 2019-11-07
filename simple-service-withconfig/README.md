# Getting Started

__Initial Scaffold Command__

```bash
curl https://start.spring.io/starter.tgz \
  -d dependencies=web,cloud-eureka,cloud-config-client \
  -d baseDir=simple-service-withconfig \
  -d bootVersion=2.1.9.RELEASE \
| tar -xzvf -
```

__Run the App Locally__

```bash
./mvnw spring-boot:run
curl http://127.0.0.1:8080/hello
# Reponse
   Not configured by a Spring Cloud Server
```

__Deploy the Microservice__

```bash
./deploy.sh
curl https://<spring_cloud_name>-simple-service-withconfig.azuremicroservices.io/hello
# Reponse
   Configured by Azure Spring Cloud
```

__Remove the Microservice__

```bash
./remove.sh
```

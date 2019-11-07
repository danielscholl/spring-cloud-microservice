# Getting Started

__Initial Scaffold Command__

```bash
curl https://start.spring.io/starter.tgz \
  -d dependencies=web \
  -d baseDir=simple-service \
  -d bootVersion=2.1.9.RELEASE \
| tar -xzvf -
```

__Run the App Locally__

```bash
./mvnw spring-boot:run
curl http://127.0.0.1:8080/hello
# Reponse
   Hello World!
```

__Deploy the Microservice__

```bash
./deploy.sh
curl https://<spring_cloud_name>-simple-service.azuremicroservices.io
# Reponse
   Hello World!
```

__Remove the Microservice__

```bash
./remove.sh
```


#!/bin/bash

echo -e "\nSetup DynamoDB Local & AdminUI docker environment...\n"

#   Get container name
read -p "Enter DynamoDB container name (or press enter to set 'dynamodb-local' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="dynamodb-local"
fi

#   Set file name
dockerComposeFile=./docker-compose.yml

#   Check file exists
if [[ -e $dockerComposeFile ]]; then
    #   Remove file
    rm $dockerComposeFile
fi

#   Create init-mongo.js
cat > $dockerComposeFile <<EOF
version: '3.7'
services:
  dynamodb-local:
    image: amazon/dynamodb-local:latest
    container_name: '$containerName'
    ports:
      - "8000:8000"

  dynamodb-admin:
    image: aaronshaf/dynamodb-admin
    ports:
      - "8001:8001"
    environment:
      DYNAMO_ENDPOINT: "http://dynamodb-local:8000"
      AWS_REGION: "us-west-2"
      AWS_ACCESS_KEY_ID: local
      AWS_SECRET_ACCESS_KEY: local
    depends_on:
      - dynamodb-local
EOF

#   Compose up.sh file name
fileName=./up.sh
#   Create up.sh
cat > $fileName <<'EOF'
#!/bin/bash
compose(){ command -v docker-compose >/dev/null && docker-compose "$@" || docker compose "$@"; }
compose up -d
EOF
chmod a+x $fileName

#   Compose down.sh file name
fileName=./down.sh
#   Create down.sh
cat > $fileName <<'EOF'
#!/bin/bash
compose(){ command -v docker-compose >/dev/null && docker-compose "$@" || docker compose "$@"; }
compose down
EOF
chmod a+x $fileName

#   Compose start.sh file name
fileName=./start.sh
#   Create start.sh
cat > $fileName <<'EOF'
#!/bin/bash
compose(){ command -v docker-compose >/dev/null && docker-compose "$@" || docker compose "$@"; }
compose start
EOF
chmod a+x $fileName

#   Compose start.sh file name
fileName=./stop.sh
#   Create stop.sh
cat > $fileName <<'EOF'
#!/bin/bash
compose(){ command -v docker-compose >/dev/null && docker-compose "$@" || docker compose "$@"; }
compose stop
EOF
chmod a+x $fileName

#   Compose login.sh file name
fileName=./login.sh
#   Create login.sh
cat > $fileName <<EOF
#!/bin/bash
docker exec -it $containerName sh
EOF
chmod a+x $fileName

#   Compose logs.sh file name
fileName=./logs.sh
#   Create logs.sh
cat > $fileName <<EOF
#!/bin/bash
docker container logs $containerName
EOF
chmod a+x $fileName

#   Print help information
cat << EOF

Setup done.

To up container type: 'docker-compose up -d' or './up.sh'
To down container type: 'docker-compose down' or './down.sh'
To start container type: 'docker-compose start' or './start.sh'
To stop container type: 'docker-compose stop' or './stop.sh'
To log in (exec) into container type: 'docker exec -it $containerName bash' or './login.sh'
To view logs for container type: 'docker container logs $containerName' or './logs.sh'

EOF

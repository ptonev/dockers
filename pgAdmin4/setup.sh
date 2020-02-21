#!/bin/bash

echo -e "\nSetup pgAdmin4 docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'latest' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="dpage/pgadmin4:latest"
else
    image="dpage/pgadmin4:$imageTag"
fi

#   Get image
hasImage=$(docker images -q $image)

#   Check for image
if [[ -z "$hasImage" ]]; then
    echo
    #   Pull image
    docker pull $image
    echo
fi

#   Get container name
read -p "Enter container name (or press enter to set 'pgadmin4-app' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="pgadmin4-app"
fi

#   Get pgAdmin4 default email
read -p "Enter pgAdmin4 default email (or press enter to set 'admin@admin.com' as default): " defaultEmail

#   Check for pgAdmin4 default email
if [[ -z "$defaultEmail" ]]; then
    defaultEmail="admin@admin.com"
fi

#   Get pgAdmin4 default password
read -p "Enter pgAdmin4 default password (or press enter to set '123456' as default): " defaultPassword

#   Check for pgAdmin4 default password
if [[ -z "$defaultPassword" ]]; then
    defaultPassword="123456"
fi

environment="        environment:
        - PGADMIN_DEFAULT_EMAIL=$defaultEmail
        - PGADMIN_DEFAULT_PASSWORD=$defaultPassword"

#   Set file name
dockerComposeFile=./docker-compose.yml

#   Check file exists
if [[ -e $dockerComposeFile ]]; then
    #   Remove file
    rm $dockerComposeFile
fi

#   Set default value on environment and seedingScripts
environment="        environment:
        - PGADMIN_DEFAULT_EMAIL=$defaultEmail
        - PGADMIN_DEFAULT_PASSWORD=$defaultPassword
        - PGADMIN_LISTEN_PORT=8002"
seedingScripts=""

#   Create init-mongo.js
cat > $dockerComposeFile <<EOF
version: "3.2"
services:
    redis-db:
        image: '$image'
$environment
        container_name: '$containerName'
        restart: always
        network_mode: 'host'
        ports:
            - '8002:8002'
        volumes:
           - ./config:/var/lib/pgadmin
        restart: unless-stopped
EOF

#   Compose up.sh file name
fileName=./up.sh
#   Create up.sh
cat > $fileName <<EOF
#!/bin/bash
docker-compose up -d
EOF
chmod a+x $fileName

#   Compose down.sh file name
fileName=./down.sh
#   Create down.sh
cat > $fileName <<EOF
#!/bin/bash
docker-compose down
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

To start (up) container type: 'docker-compose up -d' or './up.sh'
To stop (down) container type: 'docker-compose down' or './down.sh'
To log in (exec) into container type: 'docker exec -it $containerName bash' or './login.sh'
To view logs for container type: 'docker container logs $containerName' or './logs.sh'

EOF

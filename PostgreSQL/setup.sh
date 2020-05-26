#!/bin/bash

echo -e "\nSetup PostgreSQL docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'latest' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="postgres:latest"
else
    image="postgres:$imageTag"
fi

#   Get image
hasImage=$(docker images -q $image)

#   Check for image
if [[ -z "$hasImage" ]]; then
    #   Pull image
    echo
    docker pull $image
    echo
fi

#   Get container name
read -p "Enter container name (or press enter to set 'postgres-db' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="postgres-db"
fi

#   Get PostgreSQL username
read -p "Enter PostgreSQL username (or press enter to set 'root' as default): " userName

#   Check for PostgreSQL username
if [[ -z "$userName" ]]; then
    userName="root"
fi

#   Get PostgreSQL user password
read -p "Enter PostgreSQL passowrd (or press enter to set 'root' as default): " passWord

#   Check for PostgreSQL user password
if [[ -z "$passWord" ]]; then
    passWord="root"
fi

#   Get PostgreSQL database name
read -p "Enter PostgreSQL database name (or press enter to set 'test' as default): " databaseName

#   Check for PostgreSQL database name
if [[ -z "$databaseName" ]]; then
    databaseName="test"
fi

#   Set file name
dockerComposeFile=./docker-compose.yml

#   Check if file exists
if [[ -e $dockerComposeFile ]]; then
    #   Remove file
    rm $dockerComposeFile
fi

#   Create docker-compose.yml file
cat > $dockerComposeFile <<EOF
version: '3'
services:
    postgres-db:
        image: '$image'
        container_name: '$containerName'
        restart: always
        network_mode: 'host'
        ports:
            - '5432:5432'
        environment:
            - POSTGRES_USER=$userName
            - POSTGRES_PASSWORD=$passWord
            - POSTGRES_DB=$databaseName
        volumes:
            # named volumes
            - ./volume:/var/lib/postgresql/data
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

#   Compose start.sh file name
fileName=./start.sh
#   Create start.sh
cat > $fileName <<EOF
#!/bin/bash
docker-compose start
EOF
chmod a+x $fileName

#   Compose start.sh file name
fileName=./stop.sh
#   Create stop.sh
cat > $fileName <<EOF
#!/bin/bash
docker-compose stop
EOF
chmod a+x $fileName

#   Compose login.sh file name
fileName=./login.sh
#   Create login.sh
cat > $fileName <<EOF
#!/bin/bash
docker exec -it $containerName bash
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

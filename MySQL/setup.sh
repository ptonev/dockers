#!/bin/bash

echo -e "\nSetup MySQL docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'latest' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="mysql:latest"
else
    image="mysql:$imageTag"
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
read -p "Enter container name (or press enter to set 'mysql-db' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="mysql-db"
fi

#   Get MySQL root passowrd
read -p "Enter MySQL root passowrd (or press enter for empty): " rootPass

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
    mysql-db:
        image: '$image'
        container_name: '$containerName'
        restart: always
        network_mode: 'host'
        ports:
            - '3306:3306'
        environment:
            - MYSQL_ROOT_PASSWORD=$rootPass
        volumes:
            # named volumes
            - ./volume:/var/lib/mysql
            #- ./config:/etc/mysql
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

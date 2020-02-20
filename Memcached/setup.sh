#!/bin/bash

echo -e "\nSetup Memcached docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'alpine' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="memcached:alpine"
else
    image="memcached:$imageTag"
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
read -p "Enter container name (or press enter to set 'memcached-db' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="memcached-db"
fi

#   Get storage capacity
# read -p "Enter Memcached storage capacity in MB (or press enter to set '32' as default): " memcachedCapacity


#   Check for memcachedCapacity
# if [[ -z "$memcachedCapacity" ]]; then
#     memcachedCapacity="32"
# fi

#   Set file name
dockerComposeFile=./docker-compose.yml

#   Check file exists
if [[ -e $dockerComposeFile ]]; then
    #   Remove file
    rm $dockerComposeFile
fi

#   Set default value on environment and seedingScripts
environment=""
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
            - '11211:11211'
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

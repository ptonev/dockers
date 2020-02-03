#!/bin/bash

echo -e "\nSetup Redis docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'alpine' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="redis:alpine"
else
    image="redis:$imageTag"
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
read -p "Enter container name (or press enter to set 'redis-db' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="redis-db"
fi

#   Get Redis password
read -p "Enter Redis password (or press enter to skip): " redisPass

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

#   Check for Redis passowrd setting
if [[ -n "$redisPass" ]]; then
    #   Compose environment as per settings
    environment="        command: redis-server --requirepass $redisPass"
else
    #   Compose environment as per settings
    environment="        command: redis-server"
fi

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
            - "6379:6379"
        environment:
            - REDIS_REPLICATION_MODE=master
        volumes:
            - ./volume:/var/lib/redis
            - ./config:/usr/local/etc/redis/redis.conf
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

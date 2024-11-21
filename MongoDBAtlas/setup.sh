#!/bin/bash

echo -e "\nSetup MongoDB Atlas docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'latest' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="mongodb/mongodb-atlas-local:latest"
else
    image="mongodb/mongodb-atlas-local:$imageTag"
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
read -p "Enter container name (or press enter to set 'mongo-db-atlas' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="mongo-db-atlas"
fi

#   Get Mongo username
read -p "Enter mongoDB username (or press enter to skip): " mongoUserName

#   Check for MongoDB setting
if [[ -n "$mongoUserName" ]]; then
    #   Get Mongo user passowrd
    read -p "Enter mongoDB user passowrd (or press enter to skip): " mongoUserPass

    #   Get Mongo database name
    read -p "Enter mongoDB database name (or press enter to skip): " mongoDBName
fi

#   Set file name
initFile=./init-mongo.js

#   Check file exists
if [[ -e $initFile ]]; then
    #   Remove file
    rm $initFile
fi

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

#   Check for MongoDB setting
if [[ -n "$mongoUserName" ]]; then
    #   Create init-mongo.js
    cat > $initFile <<EOF
    db.createUser({
        user: "$mongoUserName",
        pwd: "$mongoUserPass",
        roles: {
            role: "readWrite",
            db: "$mongoDBName"
        }
    })
EOF
    #   Compose environment as per settings
    environment="        environment:
            - MONGO_INITDB_ROOT_USERNAME=$mongoUserName
            - MONGO_INITDB_ROOT_PASSWORD=$mongoUserPass
            - MONGO_INITDB_DATABASE=$mongoDBName"
    #   Compose seedingScripts as per settings
    seedingScripts="            # seeding scripts
            - ./init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro"
fi

#   Create init-mongo.js
cat > $dockerComposeFile <<EOF
version: '3'
services:
    mongo-db-atlas:
        image: '$image'
        container_name: '$containerName'
        restart: unless-stopped
        ports:
            - 27017:27017
        volumes:
            - data:/data/db
$seedingScripts
$environment
volumes:
    data:
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

To up container type: 'docker-compose up -d' or './up.sh'
To down container type: 'docker-compose down' or './down.sh'
To start container type: 'docker-compose start' or './start.sh'
To stop container type: 'docker-compose stop' or './stop.sh'
To log in (exec) into container type: 'docker exec -it $containerName bash' or './login.sh'
To view logs for container type: 'docker container logs $containerName' or './logs.sh'

EOF

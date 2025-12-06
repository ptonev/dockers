#!/bin/bash

echo -e "\nSetup FTP Server docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'latest' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="delfer/alpine-ftp-server:latest"
else
    image="delfer/alpine-ftp-server:$imageTag"
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
read -p "Enter container name (or press enter to set 'ftp-server' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="ftp-server"
fi

#   Get ftpUser
read -p "Enter ftp user (or press enter to set 'user' as default): " ftpUser

#   Check for ftpUser
if [[ -z "$ftpUser" ]]; then
    ftpUser="user"
fi

#   Get ftpPass
read -p "Enter ftp password (or press enter to set 'pass' as default): " ftpPass

#   Check for ftpPass
if [[ -z "$ftpPass" ]]; then
    ftpPass="pass"
fi

#   Get ftpAddress
read -p "Enter ftp address (or press enter to set 'localhost' as default): " ftpAddress

#   Check for ftpAddress
if [[ -z "$ftpAddress" ]]; then
    ftpAddress="localhost"
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
version: "3"
services:
  ftp-server:
    image: '$image'
    container_name: '$containerName'
    restart: always
    network_mode: 'host'
    ports:
      - 21:21
      - 21000-21010:21000-21010
    environment:
        USERS: "$ftpUser|$ftpPass"
        ADDRESS: "$ftpAddress"
    volumes:
      - './ftp:/ftp/$ftpUser/'
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
docker exec -it $containerName /bin/ash
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

FTP settings:
FTP User: $ftpUser
FTP Password: $ftpPass
EOF

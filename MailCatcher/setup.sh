#!/bin/bash

echo -e "\nSetup MailCatcher docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set '0.7.1' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="dockage/mailcatcher:0.7.1"
else
    image="dockage/mailcatcher:$imageTag"
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
read -p "Enter container name (or press enter to set 'mail-catcher' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="mail-catcher"
fi

#   Get GUI port
read -p "Enter GUI port (or press enter to set '1080' as default): " mongoUserPass

#   Check for GUI port
if [[ -z "$guiPort" ]]; then
    guiPort="1080"
fi

#   Get SMTP port
read -p "Enter SMTP port (or press enter to set '1025' as default): " mongoUserPass

#   Check for SMTP port
if [[ -z "$smtpPort" ]]; then
    smtpPort="1025"
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
  mail-catcher:
    image: '$image'
    container_name: '$containerName'
    restart: on-failure:10
    network_mode: 'host'
    ports:
      - "$guiPort:$guiPort"
      - "$smtpPort:$smtpPort"
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

Laravel .ENV example:
MAIL_DRIVER=smtp
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS=from@example.com
MAIL_FROM_NAME=Example
MAIL_ENCRYPTION=

EOF

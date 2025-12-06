#!/bin/bash

echo -e "\nSetup SQLite docker environment...\n"

#   Get image tag
read -p "Enter image tag (or press enter to set 'latest' as default): " imageTag

#   Check for image tag
if [[ -z "$imageTag" ]]; then
    image="nouchka/sqlite3:latest"
else
    image="nouchka/sqlite3:$imageTag"
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
read -p "Enter container name (or press enter to set 'sqlite3-db' as default): " containerName

#   Check for container name
if [[ -z "$containerName" ]]; then
    containerName="sqlite-db"
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
version: '3'
services:
  sqlite3-db:
    image: '$image'
    container_name: '$containerName'
    network_mode: 'host'
    # restart: always
    restart: unless-stopped
    stdin_open: true
    tty: true
    volumes:
      - ./volume:/root/db/
    ports:
      - '9000:9000'
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

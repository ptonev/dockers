#!/bin/bash

echo -e "\nSetup ElasticSearch 7.x and Kebana 7.x docker environment...\n"

#   Get ElasticSearch image tag
imageElasticSearch="docker.elastic.co/elasticsearch/elasticsearch:7.4.0"

#   Get Kibana image tag
imageKibana="docker.elastic.co/kibana/kibana:7.4.0"

#   Get ElasticSearch image
hasImageElasticSearch=$(docker images -q $imageElasticSearch)

#   Check for ElasticSearch image
if [[ -z "$hasImageElasticSearch" ]]; then
    #   Pull ElasticSearch image
    echo
    docker pull $imageElasticSearch
    echo
fi

#   Get Kibana image
hasImageKibana=$(docker images -q $imageKibana)

#   Check for Kibana image
if [[ -z "$hasImageKibana" ]]; then
    #   Pull Kibana image
    echo 
    docker pull $imageKibana
    echo
fi

#   Get ElasticSearch container name
read -p "Enter ElasticSearch container name (or press enter to set 'elastic-search' as default): " containerElasticSearchName

#   Check for ElasticSearch container name
if [[ -z "$containerElasticSearchName" ]]; then
    containerElasticSearchName="elastic-search"
fi

#   Get Kibana container name
read -p "Enter Kibana container name (or press enter to set 'kibana' as default): " containerKibanaName

#   Check for Kibana container name
if [[ -z "$containerKibanaName" ]]; then
    containerKibanaName="kibana"
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
version: '3.7'

services:

  # Elasticsearch Docker Images: https://www.docker.elastic.co/
  elasticsearch:
    image: '$imageElasticSearch'
    container_name: '$containerElasticSearchName'
    environment:
      - xpack.security.enabled=false
      - discovery.type=single-node
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    cap_add:
      - IPC_LOCK
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
      - 9300:9300

  kibana:
    image: '$imageKibana'
    container_name: '$containerKibanaName'
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - 5601:5601
    depends_on:
      - elasticsearch

volumes:
  elasticsearch-data:
    driver: local
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
docker exec -it $containerElasticSearchName bash
EOF
chmod a+x $fileName

#   Compose login.sh file name
fileName=./login-kibana.sh
#   Create login.sh
cat > $fileName <<EOF
#!/bin/bash
docker exec -it $containerKibanaName bash
EOF
chmod a+x $fileName

#   Compose logs.sh file name
fileName=./logs.sh
#   Create logs.sh
cat > $fileName <<EOF
#!/bin/bash
docker container logs $containerElasticSearchName
EOF
chmod a+x $fileName

#   Compose logs.sh file name
fileName=./logs-kibana.sh
#   Create logs.sh
cat > $fileName <<EOF
#!/bin/bash
docker container logs $containerKibanaName
EOF
chmod a+x $fileName

#   Print help information
cat << EOF

Setup done.

To up container type: 'docker-compose up -d' or './up.sh'
To down container type: 'docker-compose down' or './down.sh'
To start container type: 'docker-compose start' or './start.sh'
To stop container type: 'docker-compose stop' or './stop.sh'
To log in (exec) into ElasticSearch container type: 'docker exec -it $containerElasticSearchName bash' or './login.sh'
To log in (exec) into Kibana container type: 'docker exec -it $containerKibanaName bash' or './login.sh'
To view logs for ElasticSearch container type: 'docker container logs $containerElasticSearchName' or './logs.sh'
To view logs for Kibana container type: 'docker container logs $containerKibanaName' or './logs.sh'

EOF

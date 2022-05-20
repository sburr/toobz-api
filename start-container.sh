#!/bin/bash

IMAGE_NAME=${IMAGE_NAME:-toobz/toobz-api}
NAME=${CONTAINER:-toobz-api}
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DATADIR=${DATADIR:-$DIR/data}
HTTP_PORT=${HTTP_PORT:-8000}
HTTPS_PORT=${HTTPS_PORT:-8443}
HTTP_PORT_HOST=${HTTP_PORT_HOST:-$HTTP_PORT}
HTTPS_PORT_HOST=${HTTPS_PORT_HOST:-$HTTPS_PORT}
DBHOST=${POSTGRES_HOST:-172.17.0.1}
DBPORT=${POSTGRES_PORT:-5432}
DBNAME=${POSTGRES_DB:-toobz}
DBUSER=${POSTGRES_USER:-postgres}
DBPASS=${POSTGRES_PASSWORD:-postgres}

echo "===> Starting $NAME..."
echo ""
echo "Cleaning up..."
echo ""
docker kill $NAME
docker rm $NAME

echo ""
echo "  Reading the environment from .env-container"
echo "  and then starting the web server container"
echo ""

# build up the list of environment variables to pass to the container
for pair in $(grep -v '^#' .env-container | xargs); do
	key=$(echo $pair | cut -d'=' -f1)
	val=$(echo $pair | cut -d'=' -f2)
	envlist="$envlist -e $key=$val"
    echo "  read $key"
done;

echo ""
echo "Starting service..."
echo "  Name: $NAME"
echo "  HTTP port: $HTTP_PORT_HOST (host), $HTTP_PORT (container)"
echo "  HTTPS port: $HTTPS_PORT_HOST (host), $HTTP_PORT (container)"
echo "  Database host: $DBHOST"
echo "  Database port: $DBPORT"
echo "  Database name: $DBNAME"
echo "  Database user: $DBUSER"
echo "  Database password: <redacted>"
echo ""
docker run --name $NAME \
    $envlist \
    -p "$HTTP_PORT_HOST:$HTTP_PORT" \
    -p "$HTTPS_PORT_HOST:$HTTPS_PORT" \
    -d $IMAGE_NAME

echo ""
echo "Done."

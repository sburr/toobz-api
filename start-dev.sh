#!/bin/bash

clear

echo "===> Starting toobz-api..."
echo ""
echo "     Reading the environment from .env-dev"
echo "     and then starting the web server running under nodemon"
echo ""
env $(grep -v '^#' .env-dev | xargs) npx nodemon src/index.coffee

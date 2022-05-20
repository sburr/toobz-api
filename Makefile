.PHONY: all build image

all: build

build:
	echo "===> Building JavaScript package..."
	yarn build
	echo "Done."

image:
	echo "===> Building Docker image..."
	docker build . -t toobz/toobz-api
	echo "Done."
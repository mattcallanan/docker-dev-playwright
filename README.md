docker build -t docker-dev-playwright .
docker run -it --rm -v "$PWD:/workspace" --network=host docker-dev-playwright

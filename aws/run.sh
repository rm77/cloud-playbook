docker rm -f aws1
docker run -it --name aws1 \
	-v $(pwd)/config/config:/tmp/config \
	-v $(pwd)/config/credentials:/tmp/credentials \
	-v $(pwd)/.:/data \
	-e AWS_CONFIG_FILE=/tmp/config \
	-e AWS_SHARED_CREDENTIALS_FILE=/tmp/credentials \
	royyana/awstool:1.00 /bin/bash

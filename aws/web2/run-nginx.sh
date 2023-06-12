docker rm -f webserverku
docker run -d \
	--name webserverku \
	-v $(pwd)/nginx-default.conf:/etc/nginx/conf.d/default.conf \
	-v $(pwd)/web:/usr/share/nginx/html \
	-v $(pwd)/nginx-logs:/var/log/nginx \
	-p 23000:80 \
	nginx 

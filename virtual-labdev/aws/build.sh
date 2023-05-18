NAMA=awstool
docker build -t awstool .
docker tag awstool royyana/awstool:1.00
docker push royyana/awstool:1.00


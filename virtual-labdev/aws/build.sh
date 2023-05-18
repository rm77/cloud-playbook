NAMA=awstool
docker build -t awstool:1.00 .
docker tag awstool:1.00 royyana/awstool:1.00
docker push royyana/awstool:1.00


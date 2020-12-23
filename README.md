# deviceid
Build the image
```
docker build -t biennt/deviceidelk .
```
Create an empty directory to store the indexes/data (eg: /elk) and run the docker image

```
docker run -d -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 5140:5140 -p 5140:5140/udp -v /elk:/var/lib/elasticsearch --name elk biennt/deviceidelk
```

# nginx+ with njs
https://gist.github.com/nginx-gists/36e97fc87efb5cf0039978c8e41a34b5#file-dockerfile

 - nginx+
 - njs
 - nginx-agent

## build
docker build -t "nginx-plus" .


## run
```bash
docker run --rm -d \
  --name nginx-plus \
  -p 80:80 \
  -p 443:443 \
  -p 10002:10002 \
	nginx-plus
```

## with logs
```bash
docker run  -i \
  --name nginx-plus \
  -p 80:80 \
  -p 443:443 \
  -p 10002:10002 \
  nginx-plus
```

## destroy
```bash
docker stop nginx-plus
docker rm nginx-plus
```

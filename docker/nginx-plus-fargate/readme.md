# nginx+ with njs
https://gist.github.com/nginx-gists/36e97fc87efb5cf0039978c8e41a34b5#file-dockerfile

 - nginx+
 - njs
 - nginx-agent

## build
docker build -t "nginx-plus-fargate" .


## run
```bash
docker run --rm -d \
  --name nginx-plus-fargate \
  -p 80:80 \
  -p 443:443 \
	nginx-plus-fargate
```

## with logs
```bash
docker run --rm -it \
  --name nginx-plus-fargate \
  -p 80:80 \
  -p 443:443 \
  nginx-plus-fargate
```

## destroy
```bash
docker stop nginx-plus-fargate
docker rm nginx-plus-fargate
```

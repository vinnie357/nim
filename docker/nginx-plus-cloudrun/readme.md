# nginx+ with njs
https://gist.github.com/nginx-gists/36e97fc87efb5cf0039978c8e41a34b5#file-dockerfile

 - nginx+
 - njs
 - nginx-agent
 - layering in oauth token for agent through cloudrun iap

## build
docker build -t "nginx-plus-cloudrun" .


## run
```bash
docker run --rm -d \
  --name nginx-plus-cloudrun \
  -p 80:80 \
  -p 443:443 \
	nginx-plus-cloudrun
```

## with logs
```bash
docker run --rm -it \
  --name nginx-plus-cloudrun \
  -p 80:80 \
  -p 443:443 \
  nginx-plus-cloudrun
```

## destroy
```bash
docker stop nginx-plus-cloudrun
docker rm nginx-plus-cloudrun
```

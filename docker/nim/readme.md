# nim in docker

JUST FOR TESTING DON"T USE ME

## licenses
[NGINX instance manager](https://account.f5.com/myf5)

```bash
cp nginx-manager.crt licenses/nginx-manager.crt
cp nginx-manager.key licenses/nginx-manager.key
cp nginx-manager.lic licenses/nginx-manager.lic
```

## build
docker build -t "nim" .


## run
```bash
docker run --rm -d \
  --name nim \
  -p 10000:10000 \
  -p 11000:11000 \
	nim
```

## with logs
```bash
docker run  -i \
  --name nim \
  -p 10000:10000 \
  -p 11000:11000  \
  nim
```

## destroy
```bash
docker stop nim
docker rm nim
```


## gcr

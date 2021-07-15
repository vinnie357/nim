# nim-plus in google cloud run

JUST FOR TESTING DON"T USE ME

## licenses
[NGINX instance manager](https://account.f5.com/myf5)

```bash
cp nginx-manager.crt licenses/nginx-manager.crt
cp nginx-manager.key licenses/nginx-manager.key
cp nginx-manager.lic licenses/nginx-manager.lic
```

## build
docker build -t "nim-plus" .


## run
```bash
docker run --rm -d \
  --name nim-plus \
  -p 80:80 \
  -p 443:443 \
  -p 10002:10002 \
	nim-plus
```

## with logs
```bash
docker run  -i \
  --name nim-plus \
  -p 80:80 \
  -p 443:443 \
  -p 10002:10002 \
  nim-plus
```

## push to gcr

```bash
. init.sh
push_gcr "" "nim-plus" "latest"
```
## cloud run

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" https://nim-test2-2ymnlnhoha-uc.a.run.app

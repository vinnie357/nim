# nim-plus in google cloud run

JUST FOR TESTING DON"T USE ME
## requirements
- nim-plus-cloudrun with ssl offloading
  - nginx-manger
  - nginx-manager-grpc
- nginix-plus-cloudrun container customized agent for IAP tokens.
  -
## licenses
[NGINX instance manager](https://account.f5.com/myf5)

```bash
cp nginx-manager.crt licenses/nginx-manager.crt
cp nginx-manager.key licenses/nginx-manager.key
cp nginx-manager.lic licenses/nginx-manager.lic
```

## build
docker build -t "nim-plus-cloudrun" .


## run
```bash
docker run --rm -d \
  --name nim-plus-cloudrun \
  -p 80:80 \
  -p 443:443 \
	nim-plus-cloudrun
```

## with logs
```bash
docker run --rm -i \
  --name nim-plus-cloudrun \
  -p 80:80 \
  -p 443:443 \
  nim-plus-cloudrun
```

## push to gcr

```bash
. init.sh
push_gcr "" "nim-plus-cloudrun" "latest"
```
## cloud run

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" https://nim-test2-2ymnlnhoha-uc.a.run.app

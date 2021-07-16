# nim-plus in google cloud run


## references:

- https://ahmet.im/blog/cloud-run-multiple-processes-easy-way/
- https://github.com/garbetjie/terraform-google-cloud-run

## overview

- google IAP -> nginx+ -> nginx-instance-manager



## requirements

- nim-plus in gcr
- gcloud login


## getting a token
```bash
token=$(gcloud auth print-identity-token)
url=$(terraform output --json | jq -r .service_url.value)
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" $url
header="bearer "$token
echo $header
```

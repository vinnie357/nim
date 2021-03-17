# NIM
[NGINX instance manager](https://www.nginx.com/blog/introducing-nginx-instance-manager) using f5-devops-containers
---

includes:
- pre-commit
- go
- docker
- terraform
- terraform-docs
- gcloud cli

## login
```bash
PROJECT_ID="myprojectid"
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud auth application-default login
```
## licenses

- [NGINX Instance Manager](https://my.f5.com/manage/s/)
- [NGINX+](https://www.nginx.com/free-trial-request)


## running

set your vars in admin.auto.tfvars

```bash
cp admin.auto.tfvars.example admin.auto.tfvars
```

add scripts and start setup
```bash
. init.sh && setup
```
## Development

don't forget to add your git user config

```bash
git config --global user.name "myuser"
git config --global user.email "myuser@domain.com"
```
---

checking for secrets as well as linting is performed by git pre-commit with the module requirements handled in the devcontainer.

testing pre-commit hooks:
  ```bash
  # test pre commit manually
  pre-commit run -a -v
  ```
---

## todo
agent manging nginx-plus on manager
agent scripting
agent ansible
ssh keys user / agent / ansible
internal CA for mtls agent connections

# list_docker_registry_repos
List docker registry repositories and image tags with Docker Registry v2 + Token Auth Server (Registry v2 Authentication)

### In Unix (include MacOS)

You can use Terminal , and type (change directory to bash file location)

`$ bash ./gen_script.sh <username> <password> <private docker registry auth url> <private docker registry url>`

for example,

`$ bash ./gen_script.sh syneart 'Y#=r3Tg*5$d5x6?6mC' https://dockeregauth.syneart.com http://localhost:5000`

and it will created the Script file.

then Use 

`bash ./list_docker_registry_repos.sh` to enjoy!

## Example Result
Then you will see
```
[INFO] Get Access Token ..
[INFO] Get Catalog ..
[INFO] Get Access Token and Tag For Repositories Name: alpine
{
  "name": "alpine",
  "tags": [
    "latest"
  ]
}
[INFO] Get Access Token and Tag For Repositories Name: syneart/openbts_usrp_gsm
{
  "name": "syneart/openbts_usrp_gsm",
  "tags": [
    "dev_1"
  ]
}
[INFO] Get Access Token and Tag For Repositories Name: syneart/syneart_env
{
  "name": "syneart/syneart_env",
  "tags": [
    "1.0-uhd4.1.0.5-ubuntu20.04",
    "1.0-uhd3.15",
    "2.0-uhd3.15",
    "1.0-uhd4.1-ubuntu20.04",
    "2.1-uhd3.15",
    "1.0-uhd4.2.0.0-ubuntu20.04",
    "2.1-uhd4.1-ubuntu20.04",
    "2.0-uhd4.2.0.0-ubuntu20.04",
    "2.0-uhd4.1-ubuntu20.04"
  ]
}
root@docker_registry_dev:~/syneart/docker/registry#
```
## Requirement
1. curl
2. jq

## Note
1. If your password has special characters, please surround the password with single quotes, like 'pa!wo0d@', not pa!wo0d@
2. This script only use for Docker Registry v2 + Token Auth Server (Registry v2 Authentication)

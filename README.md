# list_docker_registry_repos
List docker registry repositories and image tags with Docker Registry v2 and supported Token Auth Server (Registry v2 Authentication)

### In Unix (include MacOS)

Use Terminal , and type (change directory to bash file location)

```
Usage: gen_script.sh
  Options:
      -u | --registry_username
         Docker registry username
      -p | --registry_password
         Docker registry password
      -t | --registry_basic_token
         Docker registry basic token, use \`echo -n <REGISTRY_USERNAME>:'<REGISTRY_PASSWORD>' | base64\` to generate.
      --registry_auth_url
         Docker registry OAuth2 Server url
      --registry_url
         Docker registry v2 Server url
      -h | --help
         Print this help
```

for example,

```
$ bash ./gen_script.sh \
       -u syneart \
       -p 'Y#=r3Tg*5$d5x6?6mC' \
       --registry_auth_url https://auth.syneart.com \
       --registry_url http://localhost:5000
```

or you can generate and use registry basic token by yourself, like

```
$ bash ./gen_script.sh \
       -t 'c3luZWFydDpZIz1yM1RnKjUkZDV4Nj82bUM=' \
       --registry_auth_url https://auth.syneart.com \
       --registry_url http://localhost:5000
```

or if you use Harbor v2.x you can use without `--registry_auth_url` parameter, like

```
$ bash ./gen_script.sh \
       -t 'c3luZWFydDpZIz1yM1RnKjUkZDV4Nj82bUM=' \
       --registry_url http://localhost:5000
```

and it will created the Script file, excute

```
$ bash ./list_docker_registry_repos.sh
```
to enjoy!

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
curl

## Note
1. If your password has special characters, please surround the password with single quotes, like 'pa!wo0d@', not pa!wo0d@

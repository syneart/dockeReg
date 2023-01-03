# dockeReg
Get the list of images and tags for a Docker Hub / Docker Registry

### Includes:
    Docker Hub v2
    Docker Registry v2 (and with OAuth v2)
    Docker Registry v2 in Harbor v2.x

## How to use
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
         Docker registry basic token, use `echo -n <REGISTRY_USERNAME>:'<REGISTRY_PASSWORD>' | base64` to generate.
      --registry_auth_url
         Docker registry OAuth2 Server url
      --registry_url
         Docker registry v2 Server url
      --from_docker_hub
         Get the list of images and tags from Docker Hub
      --hub_org_name
         Images and tags for this organization name (if `--from_docker_hub` is set)
      -h | --help
         Print this help
```

#### for example, Docker Hub
##### public repo
```
$ bash ./gen_script.sh \
       --from_docker_hub \
       --hub_org_name library
```

##### private repo
```
$ bash ./gen_script.sh \
       --from_docker_hub \
       --registry_username syneart \
       --registry_password 'Y#=r3Tg*5$d5x6?6mC' \
       --hub_org_name syneart
```

#### for example, Docker Registry
##### public repo
```
$ bash ./gen_script.sh \
       --registry_url http://localhost:5000
```

##### private repo
```
$ bash ./gen_script.sh \
       --registry_username syneart \
       --registry_password 'Y#=r3Tg*5$d5x6?6mC' \
       --registry_auth_url https://auth.syneart.com \
       --registry_url http://localhost:5000
```

or you can generate and use registry basic token by yourself, like

```
$ bash ./gen_script.sh \
       --registry_basic_token 'c3luZWFydDpZIz1yM1RnKjUkZDV4Nj82bUM=' \
       --registry_auth_url https://auth.syneart.com \
       --registry_url http://localhost:5000
```

or if you use Harbor v2.x you can use without `--registry_auth_url` parameter, like

```
$ bash ./gen_script.sh \
       --registry_basic_token 'c3luZWFydDpZIz1yM1RnKjUkZDV4Nj82bUM=' \
       --registry_url http://localhost:5000
```

and it will created the retrieving script file, then excute

```
$ bash ./list_docker_registry_repos.sh
```
to enjoy!

## Example Result
Then you will see
```
[INFO] Retrieving access token ..
[INFO] Retrieving catalog ..
[INFO] Retrieving access token and tag for repository name: alpine
{
  "name": "alpine",
  "tags": [
    "latest"
  ]
}
[INFO] Retrieving access token and tag for repository name: syneart/openbts_usrp_gsm
{
  "name": "syneart/openbts_usrp_gsm",
  "tags": [
    "dev_1"
  ]
}
[INFO] Retrieving access token and tag for repository name: syneart/syneart_env
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
2. The docker hub image tag list retrieving code is based on Jerry Baker's code snippet. You can found [here](https://gist.github.com/kizbitz/175be06d0fbbb39bc9bfa6c0cb0d4721).

#!/bin/bash
# gen_script shell script by SyneArt <sa@syneart.com> 2023/01/01
# Get the list of images and tags for a Docker Hub / Docker Registry

_FILE_NAME=list_docker_registry_repos.sh

_REG_USERNAME=""
_REG_PASSWORD=""
_REG_BASIC_TOKEN=""
_REG_AUTH_URL=""
_REG_URL=""

_USE_OAUTH2=0
_USE_DOCKER_HUB=0
_HUB_ORG=""

usage () {
    echo "Usage: gen_script.sh"
    echo "
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
              --from_docker_hub
                 Get the list of images and tags from Docker Hub
              --hub_org_name
                 Images and tags for this organization name (if \`--from_docker_hub\` is set)
              -h | --help
                 Print this help
    "
}

if [ -z "$1" ]
then
    usage
    exit
fi

until [ -z "$1" ]
  do
    case "$1" in
       -u | --registry_username)
            _REG_USERNAME=$2
            shift 2;;
       -p | --registry_password)
            _REG_PASSWORD=$2
            shift 2;;
       -t | --registry_basic_token)
            _REG_BASIC_TOKEN=$2
            shift 2;;
       --registry_auth_url)
            _REG_AUTH_URL=$2
            _USE_OAUTH2=1
            shift 2;;
       --registry_url)
            _REG_URL=$2
            shift 2;;
       --from_docker_hub)
            _USE_DOCKER_HUB=1
            shift;;
       --hub_org_name)
            _HUB_ORG=$2
            shift 2;;
       -h | --help)
            usage
            exit 1;;
       *)
          usage
          echo "Unknown option $1"
          exit 2;;
   esac
  done

if [[ -z "${_REG_URL}" ]] && [[ "${_USE_DOCKER_HUB}" = "0" ]]
then
    usage
    exit
fi

if [[ "${_REG_USERNAME}/" != "/" || "${_REG_PASSWORD}/" != "/" ]]  && [[ "${_REG_BASIC_TOKEN}/" != "/" ]]; then
    echo "[Warning] If you setting basic token, registry's username and password no need to specify."
    exit 3
fi

if [[ "${_REG_URL}/" != "/" ]]  && [[ "${_USE_DOCKER_HUB}" == "1" ]]; then
    echo "[Warning] If you setting --from_docker_hub, registry's url no need to specify."
    exit 3
fi

if [[ "${_HUB_ORG}/" == "/" ]]  && [[ "${_USE_DOCKER_HUB}" == "1" ]]; then
    echo "[Warning] If you setting --from_docker_hub, parameter --hub_org_name also need to specify."
    exit 3
fi

if [ "${_REG_BASIC_TOKEN}/" == "/" ]; then
    _REG_BASIC_TOKEN=`echo -n "${_REG_USERNAME}:${_REG_PASSWORD}" | base64`
fi

echo "[INFO] Generate ${_FILE_NAME} .."

cat > ${_FILE_NAME} <<_FILE_END_
#/bin/bash
_REG_BASIC_TOKEN=${_REG_BASIC_TOKEN}
_REG_AUTH_URL=${_REG_AUTH_URL}
_REG_URL=${_REG_URL}
_FILE_END_

DOCKER_REGISTRY_FUNCTION () {
if [ "${_USE_OAUTH2}" = "1" ] ; then
cat >> ${_FILE_NAME} <<_FILE_END_
echo "[INFO] Retrieving access token .."
_GET_ACCESS_TOKEN=\`curl -s -H "Authorization: Basic \${_REG_BASIC_TOKEN}" "\${_REG_AUTH_URL}/auth?service=Docker+registry&scope=registry:catalog:*"\`
_ACCESS_TOKEN=\`echo \${_GET_ACCESS_TOKEN} | sed -En 's/.*"access_token":"([^"]*).*/\1/p'\`
echo "[INFO] Retrieving catalog .."
_CATELOG=\`curl -s -H "Authorization: Bearer \${_ACCESS_TOKEN}" \${_REG_URL}/v2/_catalog\`
_FILE_END_
else
cat >> ${_FILE_NAME} <<_FILE_END_
echo "[INFO] Retrieving catalog .."
_CATELOG=\`curl -s -H "Authorization: Basic \${_REG_BASIC_TOKEN}" \${_REG_URL}/v2/_catalog\`
_FILE_END_
fi

if [ "${_USE_OAUTH2}" = "1" ] ; then
cat >> ${_FILE_NAME} <<_FILE_END_
_REPOSITORIES=\`echo \${_CATELOG} | sed -r 's/^[^:]*:(.*)\}$/\1/' | sed -e 's/\[//g' -e 's/\]//g' -e 's/\,/ /g'\`
results_repo_name=( \${_REPOSITORIES} )
for ((k=0; k<"\${#results_repo_name[@]}"; k++))
do
    IFS=$'\n' read -r RepoName <<< "\${results_repo_name[\$k]}"
    strRepoName=\`echo \${RepoName} | sed 's/\"//g'\`
    echo "[INFO] Retrieving access token and tag for repository name: \${strRepoName}"
    get_access_token=\`curl -s -H "Authorization: Basic \${_REG_BASIC_TOKEN}" "\${_REG_AUTH_URL}/auth?service=Docker+registry&scope=repository:\${strRepoName}:*"\`
    access_token=\`echo \${get_access_token} | sed -En 's/.*"access_token":"([^"]*).*/\1/p'\`
    curl -s -H "Authorization: Bearer \${access_token}" \${_REG_URL}/v2/\${strRepoName}/tags/list | json_pp
done
_FILE_END_
else
cat >> ${_FILE_NAME} <<_FILE_END_
_REPOSITORIES=\`echo \${_CATELOG} | sed -r 's/^[^:]*:(.*)\}$/\1/' | sed -e 's/\[//g' -e 's/\]//g' -e 's/\,/ /g'\`
results_repo_name=( \${_REPOSITORIES} )
for ((k=0; k<"\${#results_repo_name[@]}"; k++))
do
    IFS=$'\n' read -r RepoName <<< "\${results_repo_name[\$k]}"
    strRepoName=\`echo \${RepoName} | sed 's/\"//g'\`
    echo "[INFO] Retrieving tag for repository name: \${strRepoName}"
    curl -s -H "Authorization: Basic \${_REG_BASIC_TOKEN}" \${_REG_URL}/v2/\${strRepoName}/tags/list | json_pp
done
_FILE_END_
fi
}

DOCKER_HUB_FUNCTION () {
cat >> ${_FILE_NAME} <<_FILE_END_
_TOKEN_ARRAY=( \`echo -n "\${_REG_BASIC_TOKEN}" | base64 --decode | sed -e 's/:/ /g'\` )
UNAME=\${_TOKEN_ARRAY[0]}
UPASS=\${_TOKEN_ARRAY[1]}
HUB_ORG=${_HUB_ORG}
# get token
echo "[INFO] Retrieving token ..."
TOKEN=\$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'\${UNAME}'", "password": "'\${UPASS}'"}' https://hub.docker.com/v2/users/login/ | sed -En 's/.*"token":"([^"]*).*/\1/p' )

# get list of repositories
echo "[INFO] Retrieving repository list ..."
REPO_LIST=\$(curl -s -H "Authorization: JWT \${TOKEN}" https://hub.docker.com/v2/repositories/\${HUB_ORG}/?page_size=100 | grep -o '"name":[^,]*' | sed -e 's/"name"://g' | sed -e 's/"//g' )

# output images & tags
echo
echo "[INFO] Images and tags for organization: \${HUB_ORG}"
echo
for i in \${REPO_LIST}
do
  IMAGE_TAGS=\$(curl -s -H "Authorization: JWT \${TOKEN}" https://hub.docker.com/v2/repositories/\${HUB_ORG}/\${i}/tags/?page_size=100 | grep -o '"name":[^,]*' | sed -e 's/"name"://g' | sed -e 's/"//g' )

  JSON=\`echo "{
      \"name\": \"\${HUB_ORG}/\${i}\",
      \"tags\": [
           \$(echo \"\${IMAGE_TAGS}\" | sed -e 's/ /","/g')
      ]
  }
  "\`
  echo \${JSON} | json_pp
done
_FILE_END_
}

if [ "${_USE_DOCKER_HUB}" = "1" ] ; then
    DOCKER_HUB_FUNCTION
else
    DOCKER_REGISTRY_FUNCTION
fi

echo "[INFO] Use \`bash ./${_FILE_NAME}\` to enjoy!.."

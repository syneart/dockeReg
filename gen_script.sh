#!/bin/bash
# gen_script Shell script by SyneArt <sa@syneart.com> 2023/01/01
# List docker registry repos and image tags.

_FILE_NAME=list_docker_registry_repos.sh

_REG_USERNAME=""
_REG_PASSWORD=""
_REG_BASIC_TOKEN=""
_REG_AUTH_URL=""
_REG_URL=""

_USE_OAUTH2=0

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
       -h | --help)
            usage
            exit 1;;
       *)
          usage
          echo "Unknown option $1"
          exit 2;;
   esac
  done

if [ -z "${_REG_URL}" ]
then
    usage
    exit
fi

if [[ "${_REG_USERNAME}/" != "/" || "${_REG_PASSWORD}/" != "/" ]]  && [[ "${_REG_BASIC_TOKEN}/" != "/" ]]; then
    echo "[Warning] If you setting basic token, registry's username and password no need to specify."
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

if [ "${_USE_OAUTH2}" = "1" ] ; then
cat >> ${_FILE_NAME} <<_FILE_END_
echo "[INFO] Get Access Token .."
_GET_ACCESS_TOKEN=\`curl -s -H "Authorization: Basic \${_REG_BASIC_TOKEN}" "\${_REG_AUTH_URL}/auth?service=Docker+registry&scope=registry:catalog:*"\`
_ACCESS_TOKEN=\`echo \${_GET_ACCESS_TOKEN} | sed -En 's/.*"access_token":"([^"]*).*/\1/p'\`
echo "[INFO] Get Catalog .."
_CATELOG=\`curl -s -H "Authorization: Bearer \${_ACCESS_TOKEN}" \${_REG_URL}/v2/_catalog\`
_FILE_END_
else
cat >> ${_FILE_NAME} <<_FILE_END_
echo "[INFO] Get Catalog .."
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
    echo "[INFO] Get Access Token and Tag For Repositories Name: \${strRepoName}"
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
    echo "[INFO] Get Tag For Repositories Name: \${strRepoName}"
    curl -s -H "Authorization: Basic \${_REG_BASIC_TOKEN}" \${_REG_URL}/v2/\${strRepoName}/tags/list | json_pp
done
_FILE_END_
fi

echo "[INFO] Use \`bash ./${_FILE_NAME}\` to enjoy!.."

#!/bin/bash
# gen_script Shell script by SyneArt <sa@syneart.com> 2023/01/01
# List docker registry repos and image tags.
# usage:
# gen_script.sh <username> <password> <private docker registry auth url> <private docker registry url>

_FILE_NAME=list_docker_registry_repos.sh

usage () {
    echo "Usage: gen_script.sh <username> <password> <private docker registry auth url> <private docker registry url>"
}

if [ "$1/" == "/" ]; then usage; exit; fi
if [ "$2/" == "/" ]; then usage; exit; fi
if [ "$3/" == "/" ]; then usage; exit; fi
if [ "$4/" == "/" ]; then usage; exit; fi

_BASIC_TOKEN=`echo -n "$1:$2" | base64`
_REG_AUTH_URL=$3
_REG_URL=$4

echo "[INFO] Generate ${_FILE_NAME} .."
cat > ${_FILE_NAME} <<_FILE_END_
#/bin/bash
_BASIC_TOKEN=${_BASIC_TOKEN}
_REG_AUTH_URL=${_REG_AUTH_URL}
_REG_URL=${_REG_URL}
echo "[INFO] Get Access Token .."
_GET_ACCESS_TOKEN=\`curl -s -H "Authorization: Basic \${_BASIC_TOKEN}" "\${_REG_AUTH_URL}/auth?service=Docker+registry&scope=registry:catalog:*"\`
_ACCESS_TOKEN=\`echo \${_GET_ACCESS_TOKEN} | jq -r .access_token\`
echo "[INFO] Get Catalog .."
_CATELOG=\`curl -s -H "Authorization: Bearer \${_ACCESS_TOKEN}" \${_REG_URL}/v2/_catalog\`
_REPOSITORIES=\`echo \${_CATELOG} | jq .repositories[]\`
mapfile results_repo_name < <( echo "\${_REPOSITORIES}" )
for ((k=0; k<"\${#results_repo_name[@]}"; k++))
do
    IFS=$'\n' read -r RepoName <<< "\${results_repo_name[\$k]}"
    strRepoName=\`echo \${RepoName} | sed 's/\"//g'\`
    echo "[INFO] Get Access Token and Tag For Repositories Name: \${strRepoName}"
    get_access_token=\`curl -s -H "Authorization: Basic \${_BASIC_TOKEN}" "\${_REG_AUTH_URL}/auth?service=Docker+registry&scope=repository:\${strRepoName}:*"\`
    access_token=\`echo \${get_access_token} | jq -r .access_token\`
    curl -s -H "Authorization: Bearer \${access_token}" \${_REG_URL}/v2/\${strRepoName}/tags/list | jq
done
_FILE_END_
echo "[INFO] Use \`bash ./${_FILE_NAME}\` to enjoy!.."

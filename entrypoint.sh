#!/bin/bash

set -eo pipefail

git config --global --add safe.directory /github/workspace

cd "${GITHUB_WORKSPACE}" || exit 1

setOutput() {
	echo "${1}=${2}" >>"${GITHUB_OUTPUT}"
}

with_v=${WITH_V:-false}

semver=$(gitversion /showvariable semver)

if $with_v; then
	tag="v$semver"
else
	tag="$semver"
fi

setOutput "tag" "$tag"

dt=$(date '+%Y-%m-%dT%H:%M:%SZ')

full_name=$GITHUB_REPOSITORY

git_refs_url=$(jq .repository.git_refs_url "$GITHUB_EVENT_PATH" | tr -d '"' | sed 's/{\/sha}//g')

commit=$(git rev-parse HEAD)

echo "$dt: **pushing tag $tag repo $full_name"

git_refs_response=$(
	curl -s -X POST "$git_refs_url" -H "Authorization: token $GITHUB_TOKEN" -d @- <<EOF
{
    "ref": "refs/tags/$tag",
    "sha": "$commit"
}
EOF
)

git_ref_posted=$(echo "${git_refs_response}" | jq .ref | tr -d '"')

echo "::debug::${git_refs_response}"
if [ "${git_ref_posted}" = "refs/tags/${tag}" ]; then
	exit 0
else
	echo "::error::Tag was not created properly."
	exit 1
fi

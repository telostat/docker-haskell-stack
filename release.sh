#!/usr/bin/env sh

## Fail on error:
set -e

## Declare arguments:
_REGISTRY=""
_REPOSITORY=""
_VERSION=""

## Function that prints the usage and exits:
_usage () {
    echo >&2 "Usage: ./release.sh -r <REGISTRY> -d <REPOSITORY> -v <VERSION>"
    exit 1
}

## Parse arguments:
while getopts "r:d:v:" arg; do
    case $arg in
	r)
	    _REGISTRY="${OPTARG}"
	    ;;
	d)
	    _REPOSITORY="${OPTARG}"
	    ;;
	v)
	    _VERSION="${OPTARG}"
	    ;;
	*)
	    _usage
	    ;;
    esac
done
shift $((OPTIND-1))

## Check arguments:
if [ -z "${_REGISTRY}" ]; then
    echo >&2 "Missing registry argument."
    _usage
elif [ -z "${_REPOSITORY}" ]; then
    echo >&2 "Missing repository argument."
    _usage
elif [ -z "${_VERSION}" ]; then
    echo >&2 "Missing version argument."
    _usage
fi

## Update CHANGELOG:
git-chglog -o CHANGELOG.md --next-tag "${_VERSION}"

## Commit changes with release message:
git commit -am "chore(release): ${_VERSION}"

## Tag the latest release commit:
git tag -f -a -m "Release ${_VERSION}" "${_VERSION}"

## Function that builds, tags and pushes an image.
_build_tag_push () {
    ## Get the registry name:
    _registry="${1}"

    ## Get the repository name:
    _repository="${2}"

    ## Get the resolver:
    _resolver="${3}"

    ## Build the image tag:
    _tag="$(printf "%s/%s:%s" "${_registry}" "${_repository}" "${_resolver}")"

    ## Log it:
    echo "Attempting to build ${_tag}..."

    ## Build the image:
    ./build.sh -r "${_registry}" -d "${_repository}" -s "${_resolver}"

    ## Push image:
    echo "Attempting to push the image..."
    docker push "${_tag}"
}

## Build, tag and push Docker images:
_build_tag_push "${_REGISTRY}" "${_REPOSITORY}" "lts-18.28"

## Finally, git-push to origin:
git push --follow-tags origin main

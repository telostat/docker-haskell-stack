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

    ## Get the version:
    _version="${4}"

    ## Build the image tag (specific):
    _tag1="$(printf "%s/%s:%s.%s" "${_registry}" "${_repository}" "${_resolver}" "${_version}")"

    ## Build the image tag (general):
    _tag2="$(printf "%s/%s:%s" "${_registry}" "${_repository}" "${_resolver}")"

    ## Log it:
    echo "Attempting to build ${_tag1}..."

    ## Build the image:
    ./build.sh -r "${_registry}" -d "${_repository}" -s "${_resolver}" -v "${_version}"

    ## Log it:
    echo "Attempting to create tag ${_tag2} based on ${_tag1}..."

    ## Tag the image:
    docker tag "${_tag1}" "${_tag2}"

    ## Push images:
    echo "Attempting to push images..."
    docker push "${_tag1}"
    docker push "${_tag2}"
}

## Build, tag and push Docker images:
_build_tag_push "${_REGISTRY}" "${_REPOSITORY}" "lts-18.6" "${_VERSION}"
_build_tag_push "${_REGISTRY}" "${_REPOSITORY}" "lts-18.8" "${_VERSION}"
_build_tag_push "${_REGISTRY}" "${_REPOSITORY}" "lts-18.9" "${_VERSION}"

## Finally, git-push to origin:
git push --follow-tags origin main

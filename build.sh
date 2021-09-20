#!/usr/bin/env sh

## Fail on error:
set -e

## Declare arguments:
_REGISTRY=""
_REPOSITORY=""
_RESOLVER=""

## Function that prints the usage and exits:
_usage () {
    echo >&2 "Usage: ./build.sh -r <REGISTRY> -d <REPOSITORY> -s <RESOLVER>"
    exit 1
}

## Parse arguments:
while getopts "r:d:s:v:" arg; do
    case $arg in
	r)
	    _REGISTRY="${OPTARG}"
	    ;;
	d)
	    _REPOSITORY="${OPTARG}"
	    ;;
	s)
	    _RESOLVER="${OPTARG}"
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
elif [ -z "${_RESOLVER}" ]; then
    echo >&2 "Missing resolver argument."
    _usage
fi

## Function that builds and tags an image.
_build_and_tag () {
    ## Get the registry name:
    _registry="${1}"

    ## Get the repository name:
    _repository="${2}"

    ## Get the resolver:
    _resolver="${3}"

    ## Construct the image tag (specific):
    _tag="$(printf "%s/%s:%s" "${_registry}" "${_repository}" "${_resolver}")"

    ## Build the image:
    docker build -t "${_tag}" --build-arg RESOLVER="${_resolver}" .
}

## Build and tag:
_build_and_tag "${_REGISTRY}" "${_REPOSITORY}" "${_RESOLVER}"

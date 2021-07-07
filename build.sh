#!/usr/bin/env sh

## Get latest tag:
_latest_tag="$(git describe --tags --abbrev=0 2> /dev/null || printf "")"

## Get the version:
_version="${1:-"${_latest_tag}"}"

## Check if we have a version:
if [ -z "${_version}" ]; then
    echo >&2 "No version is specified and there are no tags. Exiting..."
    exit 1
else
    echo "Version is \"${_version}\"."
fi

## Function that builds and tags an image.
_build_and_tag () {
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
    echo "Attempting to build ${_tag1}"

    ## Build the image:
    docker build -t "${_tag1}" --build-arg _RESOLVER="${_resolver}" .

    ## Log it:
    echo "Attempting to create tag ${_tag2} based on ${_tag1}"

    ## Tag the image:
    docker tag "${_tag1}" "${_tag2}"
}

_build_and_tag "telostat" "docker-haskell-stack" "lts-18.0" "${_version}"
_build_and_tag "telostat" "docker-haskell-stack" "lts-18.1" "${_version}"

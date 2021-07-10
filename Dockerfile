## Define the base image:
FROM ubuntu:20.04

## Configure shell:
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

## Define the resolver version we want to work with:
ARG _RESOLVER="lts-18.0"

## Define list of apt packages to install:
ARG _TO_APT="   \
build-essential \
ca-certificates \
curl            \
git             \
haskell-stack   \
libpcre3-dev    \
libpq-dev       \
libtinfo-dev    \
nano            \
netbase         \
zlib1g-dev      \
"

## Define a list of Haskell packages to install as per our resolver:
ARG _TO_STACK="       \
QuickCheck            \
aeson                 \
aeson-casing          \
base64-bytestring     \
bytestring            \
case-insensitive      \
cassava               \
conduit               \
containers            \
cryptonite            \
doctest               \
exceptions            \
file-embed            \
filepath              \
ginger                \
hashable              \
http-client           \
http-conduit          \
http-types            \
iconv                 \
lens                  \
megaparsec            \
mtl                   \
network-uri           \
optparse-applicative  \
path                  \
path-io               \
pcre-light            \
postgresql-simple     \
process               \
quickcheck-instances  \
raw-strings-qq        \
refined               \
resource-pool         \
safe-decimal          \
scientific            \
scotty                \
servant               \
servant-server        \
string-interpolate    \
template-haskell      \
text                  \
time                  \
transformers          \
typed-process         \
tzdata                \
unordered-containers  \
validation            \
vector                \
wai                   \
wai-extra             \
wai-logger            \
warp                  \
xlsx                  \
yaml                  \
zlib                  \
"

## Perform apt installations:
# hadolint ignore=DL3008
RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
    apt-get update -qy                                                             && \
    apt-get upgrade -qy                                                            && \
    apt-get install -qy --no-install-recommends ${_TO_APT}                         && \
    stack upgrade --binary-only                                                    && \
    stack --resolver "${_RESOLVER}" install ${_TO_STACK}                           && \
    apt-get clean autoclean                                                        && \
    apt-get autoremove -y                                                          && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Define the base image:
FROM ubuntu:20.04

## Configure shell:
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

## Define the resolver version we want to work with:
ARG RESOLVER="lts-18.0"

## Define list of apt packages to install:
ARG TO_APT="    \
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
ARG TO_STACK="        \
aeson                 \
aeson-casing          \
amazonka-s3           \
async                 \
base16-bytestring     \
base64-bytestring     \
bcrypt                \
bytestring            \
case-insensitive      \
cassava               \
charsetdetect-ae      \
conduit               \
containers            \
cryptohash-sha1       \
cryptonite            \
data-default          \
deriving-aeson        \
directory             \
doctest               \
either                \
email-validate        \
envy                  \
exceptions            \
file-embed            \
filepath              \
fused-effects         \
ghc-lib-parser        \
ghc-lib-parser-ex     \
ginger                \
Glob                  \
hashable              \
hlint                 \
hslua                 \
hspec                 \
http-client           \
http-client-tls       \
http-conduit          \
http-types            \
iconv                 \
lens                  \
lens-aeson            \
megaparsec            \
modern-uri            \
monad-logger          \
monad-parallel        \
monad-time            \
mtl                   \
network-uri           \
opaleye               \
optparse-applicative  \
parsec                \
path                  \
path-io               \
pcre-light            \
postgresql-simple     \
pptable               \
process               \
product-profunctors   \
profunctors           \
QuickCheck            \
quickcheck-instances  \
random                \
random-shuffle        \
raw-strings-qq        \
refined               \
resource-pool         \
safe                  \
safe-decimal          \
safe-money            \
sbv                   \
scientific            \
scotty                \
servant               \
servant-server        \
split                 \
string-interpolate    \
template-haskell      \
temporary             \
text                  \
time                  \
transformers          \
typed-process         \
tz                    \
tzdata                \
unliftio              \
unordered-containers  \
uri-encode            \
utf8-string           \
uuid                  \
uuid-types            \
validation            \
vector                \
wai                   \
wai-extra             \
wai-logger            \
warp                  \
xlsx                  \
yaml                  \
zip-archive           \
zlib                  \
"

## Perform apt installations:
# hadolint ignore=DL3008
RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
    apt-get update -qy                                                             && \
    apt-get upgrade -qy                                                            && \
    apt-get install -qy --no-install-recommends ${TO_APT}                          && \
    stack upgrade --binary-only                                                    && \
    stack --resolver "${RESOLVER}" install ${TO_STACK}                             && \
    apt-get clean autoclean                                                        && \
    apt-get autoremove -y                                                          && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

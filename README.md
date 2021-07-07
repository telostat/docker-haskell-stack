# Docker Image for Haskell Stack

This repository provides base Docker images for building Haskell projects using
[Stack](https://docs.haskellstack.org/en/stable/README/).

## Why?

Building non-trivial Haskell projects usually takes quite some time. This can be
annoying if the development cycle requires frequent Docker builds and
deployments. There are some *best* practices published to shorten build times.
But they usually suffer from improper build caching, especially when the
`stack.yaml` or `.cabal` files change between builds.

Images under this repository stick on to specific [Stack
resolvers](https://www.stackage.org/#about), builds and installs widely used (at
least in our shop) Haskell packages in the given resolver. These images can then
be used as base images to compile Haskell Stack projects.

## Building

To build a Docker image with default build arguments:

```{bash}
docker build -t my-docker-haskell-stack .
```

To build a Docker image with an alternative resolver:

```{bash}
docker build -t my-docker-haskell-stack --build-arg _RESOLVER="lts-18.1" .
```

## Issues

### Image Size

Our images are verrry big. You may wish to run away to adopt another solution if
this is a problem for you.

### Missing Haskell Packages

Build process attempts to install a significant number of Haskell packages. Not
all packages may be in a certain resolver. We may wish to gracefully attempt to
install a Haskell package, but continue if it does not exist in the specific
resolver.

### Base Linux Distribution

Our images are built on top of stock [Ubuntu
20.04](https://hub.docker.com/_/ubuntu) Docker image. You may experience linking
issues if your build image (or runtime) is different than Ubuntu 20.04.

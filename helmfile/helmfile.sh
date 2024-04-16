#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


###########################################################
#           Helper script to run the helmfile             #
#                                                         #
# Check variables below for to see what you can override. #
###########################################################
VERSION=${HELMFILE_VERSION:-v0.156.0}

docker run --rm --net=host \
  -v "${HOME}/.kube:/helm/.kube" \
  -v "${HOME}/.config/helm:/helm/.config/helm" \
  -v "${__dir}:/wd" --workdir /wd \
  "ghcr.io/helmfile/helmfile:${VERSION}" helmfile sync

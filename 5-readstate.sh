#!/bin/bash
# creates and updates the app
date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

gcmd="goal"

ACCOUNT=$(${gcmd} account list|awk '{ print $3 }'|head -n 1)

${gcmd} app read --app-id 1 --guess-format --global --from $ACCOUNT

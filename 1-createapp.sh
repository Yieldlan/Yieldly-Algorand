#!/bin/bash
# creates and updates the app

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

gcmd="goal"

ACCOUNT=""

ESCROW=$(${gcmd} clerk compile reward_fund_escrow.teal | awk '{ print $2 }'|tail -n 1)

# Create the App and then update it with the stateless teal escrow
APPID=$(${gcmd} app create --creator ${ACCOUNT} --approval-prog ./reward_fund.teal --global-byteslices 3 --global-ints 5 --local-byteslices 0 --local-ints 1 --app-arg "addr:"${ACCOUNT} --clear-prog ./reward_fund_close.teal | grep Created | awk '{ print $6 }')
UPDATE=$(${gcmd} app update --app-id=${APPID} --from ${ACCOUNT}  --approval-prog ./reward_fund.teal   --clear-prog ./reward_fund_close.teal --app-arg "addr:${ESCROW}" )

${gcmd} app optin  --app-id $APPID --from $ACCOUNT 

echo "App ID="$APPID 
${gcmd} app read --app-id $APPID --guess-format --global --from $ACCOUNT


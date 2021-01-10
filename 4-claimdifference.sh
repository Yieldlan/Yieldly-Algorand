#!/bin/bash

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

gcmd="goal"

ESCROW=$(${gcmd} clerk compile reward_fund_escrow.teal | awk '{ print $2 }'|tail -n 1)

ACCOUNT=""

APPID=""

BALANCE=($(${gcmd} account balance -a $ESCROW ))

CONTRACT_TOTAL=$(jq '.Total.ui' <<< "$(${gcmd} app read --app-id $APPID --guess-format --global)")

DIFFERENCE=$((BALANCE - CONTRACT_TOTAL - 1000))

${gcmd} app call --app-id $APPID --app-account=$ESCROW --app-arg "str:claimDifference" --from $ACCOUNT  --out=txn1.tx

${gcmd} clerk send --to=$ACCOUNT --from-program=./reward_fund_escrow.teal --amount=$DIFFERENCE --out=txn2.tx

cat txn1.tx txn2.tx > combinedtxn.tx
${gcmd} clerk group -i combinedtxn.tx -o groupedtxn.tx 
${gcmd} clerk split -i groupedtxn.tx -o split.tx 

${gcmd} clerk sign -i split-0.tx -o signout-0.tx
cat signout-0.tx split-1.tx > signout.tx
${gcmd} clerk rawsend -f signout.tx
#${gcmd} clerk dryrun -t signout.tx --dryrun-dump -o dump1.dr
#tealdbg debug ./reward_fund_escrow.teal -d dump1.dr

${gcmd} app read --app-id $APPID --guess-format --global --from $ACCOUNT
${gcmd} app read --app-id $APPID --guess-format --local --from $ACCOUNT
rm *.tx

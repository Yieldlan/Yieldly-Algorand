#!/bin/bash

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#ACCOUNT=$(${gcmd} account list|awk '{ print $3 }'|head -n 1)
gcmd="goal"

ESCROW=$(${gcmd} clerk compile reward_fund_escrow.teal | awk '{ print $2 }'|tail -n 1)

ACCOUNT=""

APPID=""

${gcmd} app call --app-id $APPID --app-account=$ESCROW --app-arg "str:reclaim" --from $ACCOUNT  --out=txn1.tx

#${gcmd} clerk send --to=$ACCOUNT --close-to=$ACCOUNT --from-program=./reward_fund_escrow.teal --amount=90000 --out=txn2.tx
${gcmd} clerk send --to=$ACCOUNT --from-program=./reward_fund_escrow.teal --amount=90000 --out=txn2.tx


cat txn1.tx txn2.tx > combinedtxn.tx
${gcmd} clerk group -i combinedtxn.tx -o groupedtxn.tx 
${gcmd} clerk split -i groupedtxn.tx -o split.tx 

${gcmd} clerk sign -i split-0.tx -o signout-0.tx
cat signout-0.tx split-1.tx > signout.tx
${gcmd} clerk rawsend -f signout.tx
#${gcmd} clerk dryrun -t signout.tx --dryrun-dump -o dump1.dr
#tealdbg debug ./reward_fund.teal -d dump1.dr

${gcmd} app read --app-id $APPID --guess-format --global --from $ACCOUNT
${gcmd} app read --app-id $APPID --guess-format --local --from $ACCOUNT
rm *.tx
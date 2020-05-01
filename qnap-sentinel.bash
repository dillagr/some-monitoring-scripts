#!/bin/bash

##
## monitor QNAP HDD SMART
## - send alerts via telegram
##

THISFILE=$(readlink -f $0)
THISPATH=$(dirname $THISFILE)
SKEDFILE="/opt/tmp/.sked"

##### STOP-EDITS-BELOW-THIS-LINE

function schedFile() {
    cat > $SKEDFILE << EOF

## HDD-SMART, run every 2:30AM
30 2 * * 0 $THISFILE
EOF
}

function automateThis() {
    schedFile
    echo "To automatically schedule the running of this script.."
    echo "Execute: crontab -l | cat - $SKEDFILE | crontab -"
    echo
}

SYSINFO=/sbin/getsysinfo
QMODEL=$($SYSINFO model)

if [[ $1 == on ]] ; then
    automateThis
    exit 99
fi

for NUM in {1..4} ; do
    HDDSTAT=$($SYSINFO hdsmart $NUM)
    HDMODEL=$($SYSINFO hdmodel $NUM)
    if [[ $HDDSTAT != GOOD ]] ; then
        MESSAGE="[!] [$QMODEL] HDD$NUM is $HDDSTAT\n  [i] HDD$NUM Model: $HDMODEL "
        telegram-send "$MESSAGE"
    fi
done

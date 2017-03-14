#!/bin/bash

ret=`which killall 1>/dev/null 2>&1; echo $?`
if [ $ret -ne 0 ]; then
    echo "killall is not installed" 1>&2
    exit 1
fi

killall -9 test_start.sh
killall -9 test_child.sh
killall -9 prepare_test.sh
killall -9 dd
killall -9 swift
killall -9 curl

#!/bin/sh

rm -rf input_files
rm -f file*
rm -f test_results_*
rm -f .s3curl
rm -f err*
rm -f out*

. ./settings.sh
swift delete ${WRITECONTAINER} >/dev/null 2>&1
swift delete ${WRITECONTAINER}_segments >/dev/null 2>&1
swift delete ${READCONTAINER} >/dev/null 2>&1
swift delete ${READCONTAINER}_segments >/dev/null 2>&1

#!/bin/bash

# Load a bunch of variables
. settings.sh


tmpfile=`mktemp`
chmod 600 $tmpfile

swift auth > ${tmpfile}
. ${tmpfile}
rm -f ${tmpfile}



usage () {
  echo "This script is supposed to be called from test_start.sh."
  echo "Usage:"
  echo "$0 <read|write>"
  exit
}

timer_start () {
  START=`python -c "import time; print time.time()"`
  echo $START
}

timer_stop () {
  START=$1
  STOP=`python -c "import time; print time.time()"`
  python -c "print 'time:'+str($STOP)+';'+str($TESTFILE_SIZE_KB/1024.0)+' MB; '+str($STOP-$START)+' sec; Throughput: '+str($TESTFILE_SIZE_KB/(($STOP-$START)*1024.0))+' MB/s.'"
}

get_random_file_number () {
  if [ -z "$1" ] ; then 
    echo "Function get_random_file_number needs a max number."
    exit 1
  fi
  a=`expr $RANDOM \* $1`
  b=`expr $a / 32768`
  NUMBER=`expr $b + 1`
  echo $NUMBER
}

test_read () {
  # Client read test
  while true; do
    NUMBER=`get_random_file_number $FILES`

    START=`timer_start`
    ret=`swift download $READCONTAINER file_${TESTFILE_SIZE_KB}_$NUMBER >/dev/null 2>&1; echo $?`
#    ret=`./s3curl.pl --multipart-chunk-size-mb=${CHUNK_MB} --id=${USERNAME} -- -s -v -o file_${TESTFILE_SIZE_KB}_$NUMBER https://$HOST/$READCONTAINER/file_${TESTFILE_SIZE_KB}_$NUMBER >/dev/null 2>/dev/null; echo $?`
#    ret=`curl -s -S ${OS_STORAGE_URL}/$READCONTAINER/file_${TESTFILE_SIZE_KB}_$NUMBER -X GET -H "X-Auth-Token: $OS_AUTH_TOKEN" -O; echo $?`
    if [ "x$ret" == "x0" ]; then
       timer_stop $START
       rm -f file_${TESTFILE_SIZE_KB}_$NUMBER
    fi
  done
}

test_write () {
  # Client write test

  swift delete ${WRITECONTAINER} >/dev/null 2>&1
  swift post ${WRITECONTAINER} >/dev/null 2>&1

  i=1
  while true; do
    j=`expr $i % $FILES`
    START=`timer_start`
    cd ${WRITEDIR}
    swift upload ${WRITECONTAINER} -S ${CHUNK} file_${TESTFILE_SIZE_KB}_$j >/dev/null 2>&1
#    ./s3curl.pl --multipart-chunk-size-mb=${CHUNK_MB} --id=${USERNAME} --put=file_${TESTFILE_SIZE_KB}_$j -- -s -v https://${HOST}/${WRITECONTAINER}/file_${TESTFILE_SIZE_KB}_$j >/dev/null 2>&1 
#    curl -s -S ${OS_STORAGE_URL}/${WRITECONTAINER}/file_${TESTFILE_SIZE_KB}_$j -X PUT -H "X-Auth-Token: $OS_AUTH_TOKEN" -T file_${TESTFILE_SIZE_KB}_$j 
    cd ..
    timer_stop $START
    i=`expr $i + 1`
  done
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

test=$1
case $test in
  "read" )
       test_read $2
       exit 0
       ;;
  "write" )
       test_write $2
       exit 0
       ;;
  * )
       usage
       exit 1
       ;;
esac


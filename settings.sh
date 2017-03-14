#!/bin/bash

# If you change the values below, you may need to do a prepare_test.sh!

#set environment variables
USERNAME=me
PASSWD=mypasswd
HOST=proxy.swift.surfsara.nl

ST_AUTH=https://${HOST}/auth/v1.0
ST_USER=$USERNAME
ST_KEY=$PASSWD
S3KEY=mys3key

export ST_AUTH ST_USER ST_KEY

#Chunk in bytes
CHUNK=2147483648


#Testfile size in KB
#TESTFILE_SIZE_KB=1024000
TESTFILE_SIZE_KB=1024

# Number of files (not nessecerily same as number of transfers)
#FILES=1000
FILES=10

# The number of concurrent writes during the tests
# Can be 0 or greater
WRITES=1

# The number of concurrent writes during the tests
# Can be 0 or greater
READS=2

#The stuff below you can leave as is.
#----------------------------------------------------

WRITEDIR=`pwd`/input_files
READCONTAINER=read_test
WRITECONTAINER=write_test

CHUNK_MB=`expr ${CHUNK} / 1048576`

error=0

if [ -z ${FILES} ]; then
    echo "Please specify FILES in settings.sh"
    error=1
fi

if [ -z ${TESTFILE_SIZE_KB} ]; then
    echo "Please specify TESTFILE_SIZE_KB in settings.sh"
    error=1
fi

if [ -z ${READS} ]; then
    echo "Please specify READS in settings.sh"
    error=1
fi

if [ -z ${WRITES} ]; then
    echo "Please specify WRITES in settings.sh"
    error=1
fi

if [ $error -ne 0 ]; then
    exit 1
fi

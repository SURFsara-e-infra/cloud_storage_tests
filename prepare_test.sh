#!/bin/bash

. settings.sh

TIMEOUT=3600

IF=/dev/zero
OF=/dev/null
NUMCONCURRENT=4

mkdir -p $WRITEDIR
output=output${TESTFILE_SIZE_KB}
error=error${TESTFILE_SIZE_KB}

ACCOUNT=`swift stat | grep Account | awk '{ print $2 }'`
cat << EOF >.s3curl
%awsSecretAccessKeys = (
    ${ACCOUNT} => {
        id => '${USERNAME}',
        key => '${S3KEY}'
    },
);
EOF

# Create test file to be copied to the remote machine
k=0
while [ $k -le $FILES ]
do

# Write the files concurrently
    i=1
    while [ $i -le ${NUMCONCURRENT} -a $k -le $FILES ]
    do
        dd if=$IF of=$WRITEDIR/file_${TESTFILE_SIZE_KB}_$k bs=${TESTFILE_SIZE_KB} count=1024 2>&1 | sed -e "s/^/write $i: /" > $output &
        i=`expr $i + 1`
        k=`expr $k + 1`

    done
    wait

done

# If container to read files from already exists, then delete it.
echo "swift delete ${READCONTAINER}"
swift delete ${READCONTAINER} 1>> $output 2>$error

# Create remote container to read files from
echo "swift post ${READCONTAINER}"
swift post ${READCONTAINER} 1>> $output 2>$error

# If container to write files from already exists, then delete it.
echo "swift delete ${WRITECONTAINER}"
swift delete ${WRITECONTAINER} 1>> $output 2>$error

# Create remote container to write files to
echo "swift post ${WRITECONTAINER}"
swift post ${WRITECONTAINER} 1>> $output 2>$error


# Loop over all files that will be created on the remote machine to do the read
# tests
k=0
while [ $k -le $FILES ]
do

# Write the files concurrently
    i=1
    while [ $i -le ${NUMCONCURRENT} -a $k -le $FILES ]
    do
        cd ${WRITEDIR}

        echo "swift upload ${READCONTAINER} file_${TESTFILE_SIZE_KB}_$k"
        swift upload ${READCONTAINER} file_${TESTFILE_SIZE_KB}_$k 1>>../$output 2>>../$error &

        cd ..
        i=`expr $i + 1`
        k=`expr $k + 1`

    done
    wait

done

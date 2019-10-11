#!/bin/sh

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z $1 ]; then
  TARGET=`basename $PWD`
else
  TARGET=$1
fi

cat >>gradle.properties <<EOL
groupName=io.ossim.omar.libs
EOL


# Will append -lib suffix to lib name
LIB_NAME=$TARGET-lib
mkdir -p $PWD/libs/$LIB_NAME
cp $(dirname $SOURCE)/libs/omar-template-lib/build.gradle $PWD/libs/$LIB_NAME
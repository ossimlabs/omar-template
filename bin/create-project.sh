#!/bin/sh

SOURCE="${BASH_SOURCE[0]}"
TARGET=$1

mkdir $PWD/$TARGET

# Copy bare minimum files for multi-project build
cp $(dirname $SOURCE)/../.gitignore  $PWD/$TARGET
cp $(dirname $SOURCE)/../settings.gradle  $PWD/$TARGET
cp $(dirname $SOURCE)/../gradle.properties  $PWD/$TARGET
cp $(dirname $SOURCE)/../build.gradle  $PWD/$TARGET
sed s/omar-template/${TARGET}/g   $(dirname $SOURCE)/../Jenkinsfile > $PWD/$TARGET/Jenkinsfile

# Create gradle wrapper
cd $PWD/$TARGET
gradle wrapper

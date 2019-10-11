#!/bin/sh

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z $1 ]; then
  echo "Must provide a projet name"
  exit -1
else
  TARGET=$1
fi

mkdir -p $PWD/$TARGET

# Copy bare minimum files for multi-project build
cp "$(dirname $SOURCE)/.gitignore"  $PWD/$TARGET
cp "$(dirname $SOURCE)/settings.gradle"  $PWD/$TARGET
sed -i '' "s/omar-template/${TARGET}/g" $PWD/$TARGET/settings.gradle

cp "$(dirname $SOURCE)/gradle.properties"  $PWD/$TARGET
cp "$(dirname $SOURCE)/build.gradle"  $PWD/$TARGET
cp -r "$(dirname $SOURCE)/docker"  $TARGET/docker

cp "$(dirname $SOURCE)/Jenkinsfile"  $PWD/$TARGET
sed -i '' "s/omar-template/${TARGET}/g" $PWD/$TARGET/Jenkinsfile

# Set the projectGroup
sed -i '' "s/omar.template/${TARGET//-/.}/g" $PWD/$TARGET/gradle.properties

# Create gradle wrapper
cd $PWD/$TARGET
gradle wrapper
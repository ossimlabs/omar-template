#!/bin/sh

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z $1 ]; then
  TARGET=`basename $PWD`
else
  TARGET=$1
fi

mkdir $PWD/plugins
cd $PWD/plugins

# Will append -plugin suffix to plugin name
PLUGIN_NAME=$TARGET-plugin
grails create-plugin $PLUGIN_NAME

cd $PLUGIN_NAME

# Get rid of unnecessary files
rm -rf .gitignore \
       gradle* \
       grailsw* \
       grails-wrapper.jar \
       grails-app/conf/logback.groovy

cat >>gradle.properties <<EOL
groupName=io.ossim.omar.plugins
EOL

# Add placeholder for inclusion of dependencies
cat >build.gradle <<EOL
/*
if ( System.getenv('O2_INLINE_BUILD') ) {
    grails {
        plugins {
            if ( System.getenv('O2_INLINE_BUILD') ) {
            //    compile project(":omar-core-plugin")
            }
        }
    }
}
dependencies {
    //compile project( ":\${ rootProject.name }-lib" )
    if ( ! System.getenv('O2_INLINE_BUILD') ) {
    // compile "io.ossim.omar.plugins:omar-core-plugin:+"
    }
}
*/
EOL

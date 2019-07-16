#!/bin/sh

SOURCE="${BASH_SOURCE[0]}"
TARGET=$1

# Will append -plugin suffix to plugin name
#PLUGIN_NAME=$TARGET-plugin
PLUGIN_NAME=$(basename $PWD)-plugin

mkdir $PWD/plugins
cd $PWD/plugins

grails create-plugin $PLUGIN_NAME
cd $PLUGIN_NAME

# Get rid of unnecessary files
rm -rf .gitignore \
       gradle* \
       grailsw* \
       grails-wrapper.jar \
       grails-app/conf/logback.groovy

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
    //compile project( ":\${ rootProject.projectDir.name }-lib" )
    if ( ! System.getenv('O2_INLINE_BUILD') ) {
    // compile "io.ossim.omar.plugins:omar-core-plugin:+"
    }
}
*/
EOL

cat >gradle.properties <<EOL
groupName=io.ossim.omar.plugins
EOL
#!/bin/sh

SOURCE="${BASH_SOURCE[0]}"
TARGET=$1

# Will append with -app suffix to app name
#APP_NAME=$TARGET-app
APP_NAME=$(basename $PWD)-app

mkdir $PWD/apps
cd $PWD/apps

grails create-app $APP_NAME

cd $APP_NAME

# Get rid of unnecessary files
rm -rf .gitignore \
       gradle* \
       grailsw* \
       grails-wrapper.jar

# Add placeholder for inclusion of dependencies
cat >build.gradle <<EOL
/*
grails {
    plugins {
        //compile project( ":\${ rootProject.projectDir.name }-plugin" )
        if ( System.getenv('O2_INLINE_BUILD') ) {
        //    compile project(":omar-core-plugin")
        }
    }
}
dependencies {
    if ( ! System.getenv('O2_INLINE_BUILD') ) {
    // compile "io.ossim.omar.plugins:omar-core-plugin:+"
    }
}
*/
EOL

cat >gradle.properties <<EOL
groupName=io.ossim.omar.apps
EOL

# Setup Spring Cloud
cat >grails-app/conf/bootstrap.yml <<EOL
---
spring:
  cloud:
    config:
      enabled: false
      uri: http://localhost:8888
EOL

cat >>grails-app/conf/application.yml <<EOL
---
grails:
  cors:
    enabled: true
  resources:
    pattern: '/**'
  servlet:
    version: 3.0
---
spring:
  application:
    name: ${APP_NAME/%-app//}
  cloud:
    discovery:
      enabled: false
    service-registry:
      auto-registration:
        enabled: \${spring.cloud.discovery.enabled}
EOL

cat >>grails-app/conf/logback.groovy <<EOL
logger('omar', INFO, ['STDOUT'], false)
EOL

## Copy default configuration
#CONFIG_FILE=$(find . -name application.yml)
#cp $(dirname $SOURCE)/../apps/omar-template-app/grails-app/conf/application.yml ${CONFIG_FILE}
#sed -i '' "s/omar.template/${TARGET//-/.}/g" ${CONFIG_FILE}
#
## Copy Spring Cloud Annotation
#APPLICATION_FILE=$(find . -name Application.groovy)
#cp $(dirname $SOURCE)/../apps/omar-template-app/grails-app/init/omar/template/app/Application.groovy ${APPLICATION_FILE}
#sed -i '' "s/omar.template/${TARGET//-/.}/g" ${APPLICATION_FILE}

# Copy Docker starter files
mkdir -p $PWD/src/main/docker
#cp $(dirname $SOURCE)/../apps/omar-template-app/src/main/docker/* $PWD/src/main/docker

cat >$PWD/src/main/docker/app-entrypoint.sh <<EOL
\#!/bin/sh

JAVA_OPTS="-server -Xms256m -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1  -XX:+CMSClassUnloadingEnabled -XX:+UseGCOverheadLimit -Djava.awt.headless=true -XshowSettings:vm -Djava.security.egd=file:/dev/./urandom"

java \$JAVA_OPTS -jar /app/application.jar
EOL

cat >$PWD/src/main/docker/Dockerfile.txt <<EOL
\# Remove extension and add docker commands here.
EOL


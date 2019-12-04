#!/bin/sh

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z $1 ]; then
  TARGET=`basename $PWD`
else
  TARGET=$1
fi

mkdir $PWD/apps
cd $PWD/apps

# Will append with -app suffix to app name
APP_NAME=$TARGET-app
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
        //compile project( ":\${ rootProject.name }-plugin" )
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

cat >>grails-app/conf/logback.groovy <<EOL
logger('omar', INFO, ['STDOUT'], false)
EOL

# Setup Spring Cloud
cat >grails-app/conf/bootstrap.yml <<EOL
---
spring:
  cloud:
    config:
      enabled: \${SPRING_CLOUD_CONFIG_ENABLED:false}
      uri: http://omar-config-server:8888/omar-config-server
EOL

#echo $PWD

cat >>gradle.properties <<EOL
groupName=io.ossim.omar.apps
EOL

# Copy default configuration
cat >>grails-app/conf/application.yml <<EOL
---
server:
    servlet:
        context-path: /${TARGET}
    contextPath: \${server.servlet.context-path}

management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    env:
      enabled: true
      sensitive: false
    health:
      enabled: true
    
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
    name: ${TARGET}
  cloud:
    discovery:
      enabled: \${SPRING_CLOUD_DISCOVERY_ENABLED:false}
    service-registry:
      auto-registration:
        enabled: \${spring.cloud.discovery.enabled}

eureka:
  client:
    serviceUrl:
      defaultZone: \${EUREKA_URI:http://omar-eureka-server:8761/omar-eureka-server/eureka}
  instance:
    preferIpAddress: true
EOL

# Copy Spring Cloud Annotation
APPLICATION_FILE=$(find . -name Application.groovy)
cp "$(dirname $SOURCE)/apps/omar-template-app/grails-app/init/omar/template/app/Application.groovy" ${APPLICATION_FILE}
sed -i '' "s/omar.template/${TARGET//-/.}/g" ${APPLICATION_FILE}

# Copy Docker starter files
#mkdir -p $PWD/src/main/docker
#cp  -r "$(dirname $SOURCE)/apps/omar-template-app/src/main/docker" $PWD/src/main

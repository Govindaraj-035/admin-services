FROM openjdk:8

#Uncomment below and Comment above line(i.e. FROM openjdk:8) for OS specific (e.g. Alpine OS ) docker base image
#FROM openjdk:8-jdk-alpine

# can be passed during Docker build as build time environment for github branch to pickup configuration from.
ARG spring_config_label

# can be passed during Docker build as build time environment for spring profiles active 
ARG active_profile

# can be passed during Docker build as build time environment for config server URL 
ARG spring_config_url

# can be passed during Docker build as build time environment for glowroot 
ARG is_glowroot

# can be passed during Docker build as build time environment for artifactory URL
ARG artifactory_url

# environment variable to pass active profile such as DEV, QA etc at docker runtime
ENV active_profile_env=${active_profile}

# environment variable to pass github branch to pickup configuration from, at docker runtime
ENV spring_config_label_env=${spring_config_label}

# environment variable to pass spring configuration url, at docker runtime
ENV spring_config_url_env=${spring_config_url}

# environment variable to pass glowroot, at docker runtime
ENV is_glowroot_env=${is_glowroot}

# environment variable to pass artifactory url, at docker runtime
ENV artifactory_url_env=${artifactory_url}

COPY ./target/kernel-masterdata-service-*.jar kernel-masterdata-service.jar

EXPOSE 8086

CMD if [ "$is_glowroot_env" = "present" ]; then \
    wget "${artifactory_url_env}"/artifactory/libs-release-local/io/mosip/testing/glowroot.zip ; \
    apt-get update && apt-get install -y unzip ; \
    unzip glowroot.zip ; \
    rm -rf glowroot.zip ; \
    
    sed -i 's/<service_name>/kernel-masterdata-service/g' glowroot/glowroot.properties ; \
    java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -XX:+HeapDumpOnOutOfMemoryError -XX:+UseG1GC -XX:+UseStringDeduplication -jar -javaagent:glowroot/glowroot.jar -Dspring.cloud.config.label="${spring_config_label_env}" -Dspring.profiles.active="${active_profile_env}" -Dspring.cloud.config.uri="${spring_config_url_env}" -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.rmi.port=8099 -Dcom.sun.management.jmxremote.port=8099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Djava.rmi.server.hostname=104.211.214.143 kernel-masterdata-service.jar ; \
    else \
    java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -XX:+HeapDumpOnOutOfMemoryError -XX:+UseG1GC -XX:+UseStringDeduplication -jar -Dspring.cloud.config.label="${spring_config_label_env}" -Dspring.profiles.active="${active_profile_env}" -Dspring.cloud.config.uri="${spring_config_url_env}" -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.rmi.port=8099 -Dcom.sun.management.jmxremote.port=8099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Djava.rmi.server.hostname=104.211.214.143 kernel-masterdata-service.jar; \
    fi

#CMD ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-XX:MaxRAMFraction=1",  "-XX:+HeapDumpOnOutOfMemoryError",  "-XX:+UseG1GC", "-XX:+UseStringDeduplication",  "-jar", "-Dspring.cloud.config.label=${spring_config_label_env}","-Dspring.profiles.active=${active_profile_env}","-Dspring.cloud.config.uri=${spring_config_url_env}", "-Dcom.sun.management.jmxremote=true", "-Dcom.sun.management.jmxremote.rmi.port=8099" , "-Dcom.sun.management.jmxremote.port=8099", "-Dcom.sun.management.jmxremote.ssl=false" ,"-Dcom.sun.management.jmxremote.authenticate=false",  "-Dcom.sun.management.jmxremote.local.only=false", "-Djava.rmi.server.hostname=104.211.214.143" , "kernel-masterdata-service.jar"]

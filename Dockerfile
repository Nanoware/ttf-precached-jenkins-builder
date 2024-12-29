FROM jenkins/inbound-agent:latest-jdk17

MAINTAINER terasology@gmail.com

LABEL org.opencontainers.image.title="Terasology pre-cached Jenkins Inbound Agent" \
      org.opencontainers.image.description="Pre-caches the Jenkins inbound agent with various TTF project content and different JDKs" \
      org.opencontainers.image.vendor="The Terasology Foundation" \
      org.opencontainers.image.version="1.0"

USER root

# Add the backports repository for older JDKs
RUN echo "deb http://deb.debian.org/debian bookworm-backports main" >> /etc/apt/sources.list

# Install JDK 11 and JDK 8
RUN apt-get update && \
    apt-cache search openjdk && \
    apt-get install -y --no-install-recommends openjdk-11-jdk openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

USER jenkins

# Prep some basics - make dirs and disable the Gradle daemon (one-time build agents gain nothing from the daemon)
RUN mkdir -p ~/.gradle \
    # && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \ # ... unless you have a multi-phase build
    && mkdir ~/ws

# Now grab some source code and run a minimal Gradle build to force fetching of wrappers and any immediate dependencies
RUN cd ~/ws \
    && git clone --depth 1 https://github.com/MovingBlocks/joml-ext.git \
    && cd joml-ext \
    &&  ./gradlew compileTestJava \
    && rm -rf ~/ws/joml-ext
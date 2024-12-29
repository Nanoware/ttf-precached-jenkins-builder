FROM jenkins/inbound-agent:latest-jdk17

MAINTAINER terasology@gmail.com

LABEL org.opencontainers.image.title="Terasology pre-cached Jenkins Inbound Agent" \
      org.opencontainers.image.description="Pre-caches the Jenkins inbound agent with various TTF project content and different JDKs" \
      org.opencontainers.image.vendor="The Terasology Foundation" \
      org.opencontainers.image.version="1.0"

USER root

# Install wget for downloading the Temurin JDKs
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/*

# Install OpenJDK 11 from Adoptium Temurin
RUN wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.25%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.25_9.tar.gz && \
    tar -xzf OpenJDK11U-jdk_x64_linux_hotspot_11.0.25_9.tar.gz -C /opt && \
    rm OpenJDK11U-jdk_x64_linux_hotspot_11.0.25_9.tar.gz

# Install OpenJDK 8 from Adoptium Temurin
RUN wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u432-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz && \
    tar -xzf OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz -C /opt && \
    rm OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz

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

# This step builds the Terasology engine which has a fair amount of dependencies and such
RUN cd ~/ws \
    && git clone --depth 1 https://github.com/MovingBlocks/Terasology.git \
    && cd Terasology \
    &&  ./gradlew extractNatives extractConfig compileTestJava \
    && rm -rf ~/ws/Terasology

# Delete the whole Gradle daemon dir - just contains log files and daemon status files we can't use anyway
RUN rm -rf ~/.gradle/daemon
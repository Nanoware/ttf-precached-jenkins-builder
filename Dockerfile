FROM jenkins/inbound-agent:latest-jdk17

MAINTAINER terasology@gmail.com

LABEL org.opencontainers.image.title="Terasology pre-cached Jenkins Inbound Agent" \
      org.opencontainers.image.description="Pre-caches the Jenkins inbound agent with various TTF project content and different JDKs" \
      org.opencontainers.image.vendor="The Terasology Foundation" \
      org.opencontainers.image.version="1.0"

# Install JDK 11 and JDK 8
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-11-jdk openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

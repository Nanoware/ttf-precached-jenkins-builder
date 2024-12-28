FROM jenkins/inbound-agent:latest-bookworm-jdk17

MAINTAINER terasology@gmail.com

LABEL org.opencontainers.image.title="Terasology pre-cached Jenkins Inbound Agent" \
      org.opencontainers.image.description="Pre-caches the Jenkins inbound agent with various TTF project content" \
      org.opencontainers.image.vendor="The Terasology Foundation" \
      org.opencontainers.image.version="1.0"

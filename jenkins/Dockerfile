FROM jenkins/jenkins:lts-jdk21

USER root

# Install Python, Git, Docker CLI and required utilities
RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        curl \
        ca-certificates \
        gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Match the Docker socket group ID on the host
RUN groupadd -g 986 docker-host \
    && usermod -aG docker-host jenkins

USER jenkins

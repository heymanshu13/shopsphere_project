FROM jenkins/jenkins:lts-jdk21

USER root

# ============================================================
# Install required packages
# ============================================================
RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        curl \
        ca-certificates \
        gnupg \
        unzip \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# Install Docker CLI
# ============================================================
RUN install -m 0755 -d /etc/apt/keyrings \
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


# ============================================================
# Install AWS CLI v2
# ============================================================
ARG AWS_CLI_VERSION=2.31.32

RUN curl -fSL \
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" \
        -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Verify AWS CLI installation
RUN aws --version


# ============================================================
# Install SonarScanner CLI
# ============================================================
ARG SONAR_SCANNER_VERSION=7.3.0.5189

RUN curl -fSL \
        "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip" \
        -o /tmp/sonar-scanner.zip \
    && unzip /tmp/sonar-scanner.zip -d /opt \
    && mv /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64 /opt/sonar-scanner \
    && rm -f /tmp/sonar-scanner.zip

ENV SONAR_SCANNER_HOME=/opt/sonar-scanner
ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"


# ============================================================
# Match Docker socket GID on host
# ============================================================
RUN groupadd -g 986 docker-host \
    && usermod -aG docker-host jenkins


# ============================================================
# Verify installed tools
# ============================================================
RUN python3 --version \
    && pip3 --version \
    && git --version \
    && docker --version \
    && aws --version \
    && sonar-scanner --version


# ============================================================
# Switch back to Jenkins user
# ============================================================
USER jenkins

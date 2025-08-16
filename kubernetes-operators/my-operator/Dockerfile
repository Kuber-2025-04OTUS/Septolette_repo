FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade && apt-get install -y \
    bash \
    curl \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LO "https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

COPY operator.sh /usr/local/bin/operator.sh

RUN chmod +x /usr/local/bin/operator.sh

CMD ["/usr/local/bin/operator.sh"]
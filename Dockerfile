FROM alpine:3 
ARG TF_VERSION
ARG TM_VERSION

ENV TF_VERSION=$INPUT_TF_VERSION
ENV TM_VERSION=$INPUT_TM_VERSION
RUN echo TF_VERSION=$TF_VERSION
RUN echo TM_VERSION=$TM_VERSION

RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git unzip"]

RUN curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN unzip terraform_${TF_VERSION}_linux_amd64.zip
RUN mv terraform /usr/local/bin/
RUN rm terraform_${TF_VERSION}_linux_amd64.zip

RUN curl -LO https://github.com/terramate-io/terramate/releases/download/v${TM_VERSION}/terramate_${TM_VERSION}_linux_x86_64.tar.gz
RUN tar xvzf terramate_${TM_VERSION}_linux_x86_64.tar.gz
RUN mv terramate /usr/local/bin/
RUN rm terramate_${TM_VERSION}_linux_x86_64.tar.gz

COPY ["src", "/src/"]

ENTRYPOINT ["/src/main.sh"]

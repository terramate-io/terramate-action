#!/bin/bash
if [ "${INPUT_TM_VERSION}" != "" ]; then
  tmVersion=${INPUT_TM_VERSION}
else
  echo "Input terraform_version cannot be empty"
  exit 1
fi
if [ "${INPUT_TF_VERSION}" != "" ]; then
  tfVersion=${INPUT_TF_VERSION}
else
  echo "Input terraform_version cannot be empty"
  exit 1
fi
echo INPUT_TM_VERSION=$INPUT_TM_VERSION

# # install terraform
# curl -sLO https://releases.hashicorp.com/terraform/${tfVersion}/terraform_${tfVersion}_linux_amd64.zip
# unzip terraform_${tfVersion}_linux_amd64.zip
# mv terraform /usr/local/bin/
# rm terraform_${tfVersion}_linux_amd64.zip

# # install terramate
# curl -sLO https://github.com/terramate-io/terramate/releases/download/v${tmVersion}/terramate_${tmVersion}_linux_x86_64.tar.gz
# tar xvzf terramate_${tmVersion}_linux_x86_64.tar.gz
# mv terramate /usr/local/bin/
# rm terramate_${tmVersion}_linux_x86_64.tar.gz
git config --global --add safe.directory /github/workspace

terramate ${INPUT_TM_COMMAND}

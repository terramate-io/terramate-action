#!/bin/bash

fatal(){
  echo "$*"
  exit 1
}

install(){
  if [[ -z $TM_VERSION ]]; then
    asdf_version=$(awk '$1 == "terramate" {print $2}' .tool-versions)
    if [[ -z $asdf_version ]]; then
      curl -s https://api.github.com/repos/terramate-io/terramate/releases/latest > /tmp/gh_output || fatal "couldn't get Terramate release data from github"
      TM_VERSION=$(jq -r .name /tmp/gh_output|sed 's/^v//')
    else
      TM_VERSION=$asdf_version
    fi
  fi
  echo "# Installing Terramate v$TM_VERSION"

  dl_url="https://github.com/terramate-io/terramate/releases/download/v${TM_VERSION}/terramate_${TM_VERSION}_linux_x86_64.tar.gz"
  status_code=$(curl -LsI -o /dev/null -w "%{http_code}"  "$dl_url")
  [[ $status_code != 200 ]] && fatal "Download URL ($dl_url) returns $status_code"
  curl -sLO "$dl_url"
  tar xzf "terramate_${TM_VERSION}_linux_x86_64.tar.gz" -C /tmp
  mv /tmp/terramate /usr/local/bin/terramate-bin
  rm "terramate_${TM_VERSION}_linux_x86_64.tar.gz"
  [[ $TM_VERSION != $(terramate-bin --version) ]] && fatal "Something went wrong downloading Terramate from $dl_url"

  cp "$GITHUB_ACTION_PATH/terramate-wrapper.sh" /usr/local/bin/terramate-wrapper.sh
  if [[ $USE_WRAPPER == "false" ]]; then
    ln /usr/local/bin/terramate-bin /usr/local/bin/terramate 
  else
    ln /usr/local/bin/terramate-wrapper.sh /usr/local/bin/terramate
  fi
}

install

#!/bin/bash

set -eu

fatal(){
  echo "$*"
  exit 1
}

install(){
  if [[ -z $TM_VERSION ]]; then
    asdf_version=$(awk '$1 == "terramate" {print $2}' .tool-versions 2>/dev/null||true)
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
  tar xzf "terramate_${TM_VERSION}_linux_x86_64.tar.gz" -C /tmp || fatal "Couldn't unpack tarball"
  mv /tmp/terramate /usr/local/bin/terramate-bin
  rm "terramate_${TM_VERSION}_linux_x86_64.tar.gz"

  cp "$GITHUB_ACTION_PATH/terramate-wrapper.sh" /usr/local/bin/terramate-wrapper.sh
  if [[ $USE_WRAPPER == "false" ]]; then
    ln /usr/local/bin/terramate-bin /usr/local/bin/terramate 
  else
    ln /usr/local/bin/terramate-wrapper.sh /usr/local/bin/terramate
  fi

  [[ $TM_VERSION != $(terramate --version) ]] && fatal "Installed Terramate version is not v$TM_VERSION"
  echo $?
}

install
exit 0

#!/bin/bash

fatal(){
  echo $*
  exit 1
}

init(){
  if [[ $TM_VERSION == "latest" ]]; then
    curl -s https://api.github.com/repos/terramate-io/terramate/releases/latest > /tmp/gh_output || fatal "couldn't get Terramate release data from github"
    TM_VERSION=$(cat /tmp/gh_output |jq -r .name|sed 's/^v//')
  fi

  dl_url="https://github.com/terramate-io/terramate/releases/download/v${TM_VERSION}/terramate_${TM_VERSION}_linux_x86_64.tar.gz"
  status_code=$(curl -LsI -o /dev/null -w "%{http_code}"  $dl_url)
  [[ $status_code != 200 ]] && fatal "Download URL ($dl_url) returns $status_code"
  curl -sLO $dl_url
  tar xzf "terramate_${TM_VERSION}_linux_x86_64.tar.gz" -C /tmp
  mv /tmp/terramate /usr/local/bin/terramate-bin
  rm "terramate_${TM_VERSION}_linux_x86_64.tar.gz"
  [[ $TM_VERSION != $(terramate-bin --version) ]] && fatal "Something went wrong downloading Terramate from $dl_url"

  cat > /usr/local/bin/terramate-wrapper <<EOF
#!/bin/bash
export TM_CLOUD_ORGANIZATION=$TM_CLOUD_ORGANIZATION
terramate-bin \$* > /tmp/stdout 2> /tmp/stderr
exitcode=\$?
echo "exitcode=\$exitcode" >> "\$GITHUB_OUTPUT"
echo 'stdout<<EOF' >> "\$GITHUB_OUTPUT"
cat /tmp/stdout |tee -a "\$GITHUB_OUTPUT"
echo EOF >> "\$GITHUB_OUTPUT"
echo 'stderr<<EOF' >> "\$GITHUB_OUTPUT"
cat /tmp/stderr |tee -a "\$GITHUB_OUTPUT"
echo EOF >> "\$GITHUB_OUTPUT"
EOF
  chmod +x /usr/local/bin/terramate-wrapper
  if [[ $USE_WRAPPER == "false" ]]; then
    ln /usr/local/bin/terramate-bin /usr/local/bin/terramate 
  else
    ln /usr/local/bin/terramate-wrapper /usr/local/bin/terramate
  fi
  echo $TM_VERSION > /tmp/init-has-run
}

if [[ $(cat /tmp/init-has-run 2>/dev/null ) != $TM_VERSION ]]; then
  echo "# Installing Terramate"
  init
fi

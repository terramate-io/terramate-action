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

  curl -sLO "https://github.com/terramate-io/terramate/releases/download/v${TM_VERSION}/terramate_${TM_VERSION}_linux_x86_64.tar.gz"
  tar xzf "terramate_${TM_VERSION}_linux_x86_64.tar.gz" -C /tmp
  mv /tmp/terramate /usr/local/bin/terramate-bin
  rm "terramate_${TM_VERSION}_linux_x86_64.tar.gz"
  cat > /usr/local/bin/terramate-wrapper <<EOF
#!/bin/bash
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

if [[ ! -z $TM_COMMAND ]]; then
  if [[ $USE_WRAPPER == "false" ]]; then
     terramate-bin $TM_COMMAND || fatal "terramate command '$TM_COMMAND' failed"
  else
     terramate-wrapper $TM_COMMAND || fatal "terramate command '$TM_COMMAND' failed"
  fi
fi

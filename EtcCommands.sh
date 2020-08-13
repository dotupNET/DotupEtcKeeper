#!/bin/bash



EtcCommit() {
  cd /etc
  #  StartSshAgent
  sudo -E etckeeper commit "$@"
  sudo -E git push
}

EtcPush() {
  cd /etc

  if []; then

    if [ -z $SSH_AUTH_SOCK ]; then
      eval $(ssh-agent)
      ssh-add ~/.ssh/github_rsa
    fi

  fi

  sudo -E git push
}

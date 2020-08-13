#!/bin/bash

StartSshAgent() {

  # if [ "$?" == 2 ]; then
  #   test -r ~/.ssh-agent && eval "$(<~/.ssh-agent -t 18000)" >/dev/null

  #   ssh-add -l ~/.ssh/github_rsa &>/dev/null
  #   if [ "$?" == 2 ]; then
  #     (umask 066; ssh-agent > ~/.ssh-agent)
  #     eval "$(<~/.ssh-agent -t 18000)" >/dev/null
  #     ssh-add ~/.ssh/github_rsa
  #   fi
  # fi
  if [ -z $SSH_AUTH_SOCK ]; then
    eval $(ssh-agent)
    ssh-add ~/.ssh/github_rsa
  fi
}

InitializeGitConfiguration() {

  userName=$(git config --global user.name)
  userEmail=$(git config --global user.email)

  #  if [ -z "$userName" -o -z "$userEmail" ]; then
  userName=$(Ask "Enter github user name" $userName)
  userEmail=$(Ask "Enter github email" $userEmail)

  git config --global user.name $userName
  git config --global user.email $userEmail
  #  fi

  git config --global credential.helper store

  rsaFile="/home/$(whoami)/.ssh/github_rsa"

  ssh-keygen -t rsa -b 4096 -C $userEmail -f $rsaFile
  # if [ $(Ask "Passphrase verwenden?" n) == "y" ]; then
  #   githubPassphrase=$(Ask "Passphrase")
  #   ssh-keygen -t rsa -b 4096 -C $userName -f $rsaFile -N $githubPassphrase
  # else
  #   ssh-keygen -t rsa -b 4096 -C $userName -f $rsaFile
  # fi
  StartSshAgent

  ssh-add $rsaFile

  yecho $(cat "$rsaFile.pub")

  yecho "Als nächstes muss Github für den ssh Zugriff konfiguriert werden."
  yecho "https://github.com/settings/ssh/new"
  
  until [ $(AskYesNo "Ssh Zugriff konfiguriert?") == "y" ]; do
    yecho "Als nächstes muss Github für den ssh Zugriff konfiguriert werden."
    yecho "https://github.com/settings/ssh/new"
  done
}

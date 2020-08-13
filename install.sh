#!/bin/bash -i

. "${HOME}/.dotup/scripts/DotupBashEssentials.sh"
. SshCommands.sh
. EtcCommands.sh

scriptFolder="${HOME}/.dotup/DotupEtcKeeper"

Main() {
  InstallComponents

  # Initialize array that holds the configuration
  typeset -A config
  Bash-LoadSettings "$scriptFolder/.config" config

  # Test
  AskConfiguration
  # ConfigureEtcKeeper $useGithub
  # CommitEtcKeeper
  config["GITHUB"]=$useGithub
  Bash-SaveSettings "$scriptFolder/.config" config

}

AskConfiguration() {

  useGithub=$(AskYesNo "Soll Github als remote Repository verwendet werden?" y)

  config["GITHUB"]=$useGithub

  if [ $useGithub == "y" ]; then
    # userName=$(Ask "Github Benutzer")
    InitializeGitConfiguration
    repositoryName=$(Ask "Github Repository Name" $(hostname))
    gitUrl="git@github.com:$userName/$repositoryName.git"
  fi

  echo $gitUrl
}

InstallComponents() {
  cd /tmp

  # DotupBashEssentials
  if ! FileExists "${HOME}/.dotup/scripts/DotupBashEssentials.sh"; then
    bash <(curl -s https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/install.sh)
    . "${HOME}/.dotup/scripts/DotupBashEssentials.sh"
  fi

  # DotupBashSettings
  if ! FileExists "${HOME}/.dotup/scripts/BashSettings.sh"; then
    bash <(curl -s https://raw.githubusercontent.com/dotupNET/DotupBashSettings/master/install.sh)
  fi
  . "${HOME}/.dotup/scripts/BashSettings.sh"

  InstallDotupEtcKeeper

  # git and etckeeper
  #sudo apt install git etckeeper
}

InstallDotupEtcKeeper() {
  InstallFile EtcCommands bashrc
  InstallFile SshCommands
}


InstallFile() {
  cd /tmp
  targetFile="$scriptFolder/$1.sh"

  mkdir -p $scriptFolder

  rm "/tmp/$1.sh"

  if [ -f "$targetFile" ]; then
    rm "$targetFile"
    yecho "Existing $targetFile deleted"
  fi

  wget https://raw.githubusercontent.com/dotupNET/DotupEtcKeeper/master/$1.sh

  mv $1.sh "$scriptFolder"

  if [ $2 == "bashrc" ]; then
    TryAddLine ". ${targetFile}" ~/.bashrc
  fi

  gecho "Installation completed. $targetFile"
}

# ConfigureEtcKeeper(UseGit)
ConfigureEtcKeeper() {

  # use git
  sudo sed -i '/VCS=/ s/^#*/#/' /etc/etckeeper/etckeeper.conf
  sudo sed -i 's/#VCS="git"/VCS="git"/' /etc/etckeeper/etckeeper.conf

  # Autocommit
  sudo sed -i 's/#AVOID_DAILY_AUTOCOMMITS=1/AVOID_DAILY_AUTOCOMMITS=1/' /etc/etckeeper/etckeeper.conf

  if [ "$1" == "y" ]; then
    sudo sed -i 's/PUSH_REMOTE=""/PUSH_REMOTE="origin"/' /etc/etckeeper/etckeeper.conf
  fi

}

CommitEtcKeeper() {
  cd /etc
  sudo -E etckeeper init

  EtcCommit "Initial etc commit"
}

Main

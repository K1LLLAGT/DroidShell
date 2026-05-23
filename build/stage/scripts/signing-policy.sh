#!/data/data/com.termux/files/usr/bin/bash
mkdir -p ~/.ssh
echo "g19479574996t@gmail.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers
git config --global user.name "Greg"
git config --global user.email "g19479574996t@gmail.com"
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
git config --global tag.gpgsign true
git config --global gpg.program gpg
git config --global push.autoSetupRemote true
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global fetch.prune true
git config --global core.autocrlf input

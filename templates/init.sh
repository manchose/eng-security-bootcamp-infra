#! /bin/sh

useradd -U -u 900 -m -s /bin/bash infra
mkdir -p /home/infra/.ssh
chmod 700 /home/infra/.ssh
echo "${infra_pubkey}" > /home/infra/.ssh/authorized_keys
chmod 600 /home/infra/.ssh/authorized_keys
chown -R infra:infra /home/infra/.ssh

cat <<SUDO > /etc/sudoers.d/infra
Defaults:%infra !requiretty
Defaults:%infra env_keep += SSH_AUTH_SOCK
Defaults:%infra env_keep += "MITAMAE_ENVIRONMENT MITAMAE_ROLES MITAMAE_HOST MITAMAE_TEAM_NO"

%infra ALL=(ALL) NOPASSWD: ALL
SUDO

apt-get update -y
apt-get install -y curl ssh sudo git-core
service ssh start

mkdir -p /usr/local/sbin
curl -o /usr/local/sbin/mitamae https://github.com/itamae-kitchen/mitamae/releases/download/v1.4.5/mitamae-x86_64-linux
chmod 755 /usr/local/sbin/mitamae

git clone https://github.com/speee/eng-security-bootcamp-infra.git /home/infra/eng-security-bootcamp-infra
chown -R infra:infra /home/infra/eng-security-bootcamp-infra

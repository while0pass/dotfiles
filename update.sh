sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y autoremove

sudo snap refresh

~/.tmux/plugins/tpm/bin/clean_plugins
~/.tmux/plugins/tpm/bin/update_plugins all
~/.tmux/plugins/tpm/bin/install_plugins

python -m pip install -U pip pipenv tmuxp norminette

vim +PlugUpgrade\|PlugClean\!\|PlugUpdate\|PlugInstall\|qa

rustup update
## alacritty dependencies on Ubuntu
#sudo apt-get -y install \
#  cmake \
#  pkg-config \
#  libfreetype6-dev \
#  libfontconfig1-dev \
#  libxcb-xfixes0-dev \
#  python3
cargo install alacritty

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y autoremove

sudo snap refresh
flatpak update -y

~/.tmux/plugins/tpm/bin/clean_plugins
~/.tmux/plugins/tpm/bin/update_plugins all
~/.tmux/plugins/tpm/bin/install_plugins

python -m pip install -U \
    colout \
    httpie \
    icdiff \
    norminette \
    pip \
    pipenv \
    poetry \
    tmuxp

test -e "$(which conda)" && update --all --yes || true

vim +PlugUpgrade\|PlugClean\!\|PlugUpdate\|PlugInstall\|qa

make liquidprompt

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

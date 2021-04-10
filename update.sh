sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

sudo snap refresh

~/.tmux/plugins/tpm/bin/clean_plugins
~/.tmux/plugins/tpm/bin/update_plugins all
~/.tmux/plugins/tpm/bin/install_plugins

python -m pip install -U pip pipenv tmuxp norminette

vim +PlugUpgrade\|PlugClean\!\|PlugUpdate\|PlugInstall\|qa

rustup update

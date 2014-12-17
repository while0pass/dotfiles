SHELL := /bin/bash
ICDIFF_URL := https://raw.githubusercontent.com/jeffkaufman/icdiff/master

install: \
    bash \
    git \
    vim \
    tmux \
    icdiff \
    xneur \
    ipython \
    liquidprompt \
    gconf

bash:
	if ! grep dotfiles ~/.bashrc ; \
	then \
		echo >> ~/.bashrc ;\
		echo "# My settings from dotfiles" >> ~/.bashrc; \
		echo "source `pwd`/bash/bashrc" >> ~/.bashrc ; \
	fi

git:
	rm -fr ~/.config/git
	rm -fr ~/.gitconfig
	ln -s `pwd`/git/config ~/.gitconfig

vim:
	rm -rf ~/.vim ~/.vimrc ~/.ctags
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc
	ln -s ~/.vim/ctags ~/.ctags
	mkdir -p vim/temp/
	vi +BundleInstall! +BundleClean +qa

tmux:
	rm -fr ~/.tmux.conf
	ln -s `pwd`/tmux/tmux.conf ~/.tmux.conf

icdiff:
	sudo wget ${ICDIFF_URL}/icdiff -O /usr/local/bin/icdiff
	sudo wget ${ICDIFF_URL}/git-icdiff -O /usr/local/bin/git-icdiff
	sudo chmod a+rx /usr/local/bin/icdiff /usr/local/bin/git-icdiff

xneur:
	rm -fr ~/.xneur
	ln -s `pwd`/xneur ~/.xneur

ipython:
	mkdir -p ~/.config/ipython
	rm -fr ~/.config/ipython/extensions
	ln -s `pwd`/ipython/extensions ~/.config/ipython/extensions
	rm -fr ~/.config/ipython/profile_default/
	ipython profile create
	patch ~/.config/ipython/profile_default/ipython_config.py \
		< ipython/ipython_config.patch

liquidprompt:
	rm -fr ~/.liquidprompt
	git clone --depth=1 \
		https://github.com/nojhan/liquidprompt.git ~/.liquidprompt
	cp ~/.liquidprompt/liquidpromptrc-dist ~/.config/liquidpromptrc

pips:
	sudo pip install -r packages/pip.list

gconf:
	[[ -d ~/.gconf/apps/gnome-terminal ]] \
		|| mkdir -p ~/.gconf/apps/gnome-terminal
	[[ -d ~/.gconf/apps/gnome-terminal.bak ]] \
		|| cp -R ~/.gconf/apps/gnome-terminal{,.bak}
	rm -fr ~/.gconf/apps/gnome-terminal
	ln -s `pwd`/gconf/apps/gnome-terminal ~/.gconf/apps/gnome-terminal
	[[ -d ~/.gconf/desktop/gnome/peripherals/keyboard/kbd ]] \
		|| mkdir -p ~/.gconf/desktop/gnome/peripherals/keyboard/kbd
	[[ -d ~/.gconf/desktop/gnome/peripherals/keyboard/kbd.bak ]] \
		|| cp -R ~/.gconf/desktop/gnome/peripherals/keyboard/kbd{,.bak}
	rm -fr ~/.gconf/desktop/gnome/peripherals/keyboard/kbd
	ln -s `pwd`/gconf/desktop/gnome/peripherals/keyboard/kbd \
		~/.gconf/desktop/gnome/peripherals/keyboard/kbd

.PHONY: \
    bash \
    git \
    vim \
    tmux \
    icdiff \
    xneur \
    ipython \
    liquidprompt \
    pips \
    gconf

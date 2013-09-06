SHELL := /bin/bash

install: \
    git \
    vim \
    tmux \
    xneur \
    ipython \
    liquidprompt \
    gconf
  

git:
	rm -fr ~/.config/git
	ln -s `pwd`/git ~/.config/git

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

xneur:
	rm -fr ~/.xneur
	ln -s `pwd`/xneur ~/.xneur

ipython:
	mkdir -p ~/.config/ipython
	rm -fr ~/.config/ipython/extensions
	ln -s `pwd`/ipython/extensions ~/.config/ipython/extensions
	rm -fr ~/.config/ipython/profile_default/
	ipython profile create
	patch ~/.config/ipython/profile_default/ipython_config.py < ipython/ipython_config.patch

liquidprompt:
	rm -fr ~/.liquidprompt
	git clone --depth=1 https://github.com/nojhan/liquidprompt.git ~/.liquidprompt
	cp ~/.liquidprompt/liquidpromptrc-dist ~/.config/liquidpromptrc
	if ! grep liquidprompt ~/.bashrc ; then echo "source ~/.liquidprompt/liquidprompt" >> ~/.bashrc ; fi

pips:
	sudo pip install -r packages/pip.list

gconf:
	[[ -d ~/.gconf/apps/gnome-terminal ]] || mkdir -p ~/.gconf/apps/gnome-terminal
	[[ -d ~/.gconf/apps/gnome-terminal.bak ]] || cp -R ~/.gconf/apps/gnome-terminal{,.bak}
	rm -fr ~/.gconf/apps/gnome-terminal
	ln -s `pwd`/gconf/apps/gnome-terminal ~/.gconf/apps/gnome-terminal
	[[ -d ~/.gconf/desktop/gnome/peripherals/keyboard/kbd ]] || mkdir -p ~/.gconf/desktop/gnome/peripherals/keyboard/kbd
	[[ -d ~/.gconf/desktop/gnome/peripherals/keyboard/kbd.bak ]] || cp -R ~/.gconf/desktop/gnome/peripherals/keyboard/kbd{,.bak}
	rm -fr ~/.gconf/desktop/gnome/peripherals/keyboard/kbd
	ln -s `pwd`/gconf/desktop/gnome/peripherals/keyboard/kbd ~/.gconf/desktop/gnome/peripherals/keyboard/kbd

.PHONY: \
    git \
    vim \
    tmux \
    xneur \
    ipython \
    liquidprompt \
    pips \
    gconf \
  

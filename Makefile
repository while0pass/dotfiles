SHELL := /bin/bash
HOMEDIR := $(shell echo ~)
MAKEFDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VUNDLEPATH := ${HOMEDIR}/.vim/bundle/Vundle.vim
LPPATH := ${HOMEDIR}/.liquidprompt
ICDIFF_URL := https://raw.githubusercontent.com/jeffkaufman/icdiff/master
PYTHON2 := https://docs.python.org/2.7/archives/python-2.7.10-docs-text.tar.bz2
PYTHON3 := https://docs.python.org/3/archives/python-3.4.3-docs-text.tar.bz2

install: \
    bash \
    git \
    vim \
    tmux \
    icdiff \
    xneur \
    ipython \
    liquidprompt \
    docs \
    gconf

bash:
	if ! grep dotfiles ~/.bashrc; then \
		echo >> ~/.bashrc ;\
		echo "# My settings from dotfiles" >> ~/.bashrc; \
		echo "source ${MAKEFDIR}bash/bashrc" >> ~/.bashrc ; \
	fi

git:
	rm -fr ${HOMEDIR}/.config/git
	rm -fr ${HOMEDIR}/.gitconfig
	ln -s ${MAKEFDIR}git/config ${HOMEDIR}/.gitconfig

vim:
	rm -rf ${HOMEDIR}/.vim ${HOMEDIR}/.vimrc ${HOMEDIR}/.ctags
	ln -s ${MAKEFDIR}vim ${HOMEDIR}/.vim
	ln -s ${HOMEDIR}/.vim/vimrc ${HOMEDIR}/.vimrc
	ln -s ${HOMEDIR}/.vim/ctags ${HOMEDIR}/.ctags
	mkdir -p vim/temp/
	if [ -e ${VUNDLEPATH}/.git ]; then \
		git --work-tree=${VUDNLEPATH} --git-dir=${VUNDLEPATH}/.git \
			pull origin master; \
	else \
		mkdir -p ${VUNDLEPATH}; \
		rm -fr ${VUNDLEPATH}; \
		git clone https://github.com/gmarik/Vundle.vim.git ${VUNDLEPATH}; \
	fi
	vi +VundleInstall! +VundleClean +qa

tmux:
	rm -fr ${HOMEDIR}/.tmux.conf
	ln -s ${MAKEFDIR}tmux/tmux.conf ${HOMEDIR}/.tmux.conf
	if [ ! -e ${HOMEDIR}/.tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm \
				${HOMEDIR}/.tmux/plugins/tpm; \
	fi

icdiff:
	sudo wget ${ICDIFF_URL}/icdiff -O /usr/local/bin/icdiff
	sudo wget ${ICDIFF_URL}/git-icdiff -O /usr/local/bin/git-icdiff
	sudo chmod a+rx /usr/local/bin/icdiff /usr/local/bin/git-icdiff

xneur:
	rm -fr ${HOMEDIR}/.xneur
	ln -s ${MAKEFDIR}xneur ${HOMEDIR}/.xneur

ipython:
	mkdir -p ${HOMEDIR}/.ipython
	rm -fr ${HOMEDIR}/.ipython/extensions
	ln -s ${MAKEFDIR}ipython/extensions ${HOMEDIR}/.ipython/extensions
	rm -fr ${HOMEDIR}/.ipython/profile_default/
	ipython profile create
	patch ${HOMEDIR}/.ipython/profile_default/ipython_config.py \
		< ipython/ipython_config.patch

liquidprompt:
	if [ -e ${LPPATH}/.git ]; then \
		git --work-tree=${LPPATH} --git-dir=${LPPATH}/.git \
			pull origin master; \
	else \
		mkdir -p ${LPPATH}; \
		rm -fr ${LPPATH}; \
		git clone --depth=1 \
			https://github.com/nojhan/liquidprompt.git ${LPPATH}; \
	fi
	cp ${HOMEDIR}/.liquidprompt/liquidpromptrc-dist \
		${HOMEDIR}/.config/liquidpromptrc

pips:
	sudo pip install -r packages/pip.list

gconf:
	[[ -d ${HOMEDIR}/.gconf/apps/gnome-terminal ]] \
		|| mkdir -p ${HOMEDIR}/.gconf/apps/gnome-terminal
	[[ -d ${HOMEDIR}/.gconf/apps/gnome-terminal.bak ]] \
		|| cp -R ${HOMEDIR}/.gconf/apps/gnome-terminal{,.bak}
	rm -fr ${HOMEDIR}/.gconf/apps/gnome-terminal
	ln -s ${MAKEFDIR}gconf/apps/gnome-terminal ${HOMEDIR}/.gconf/apps/gnome-terminal
	[[ -d ${HOMEDIR}/.gconf/desktop/gnome/peripherals/keyboard/kbd ]] \
		|| mkdir -p ${HOMEDIR}/.gconf/desktop/gnome/peripherals/keyboard/kbd
	[[ -d ${HOMEDIR}/.gconf/desktop/gnome/peripherals/keyboard/kbd.bak ]] \
		|| cp -R ${HOMEDIR}/.gconf/desktop/gnome/peripherals/keyboard/kbd{,.bak}
	rm -fr ${HOMEDIR}/.gconf/desktop/gnome/peripherals/keyboard/kbd
	ln -s ${MAKEFDIR}gconf/desktop/gnome/peripherals/keyboard/kbd \
		${HOMEDIR}/.gconf/desktop/gnome/peripherals/keyboard/kbd

docs:
	mkdir -p ~/docs
	wget ${PYTHON2} -O- | tar -xjvC ~/docs
	wget ${PYTHON3} -O- | tar -xjvC ~/docs

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
    docs \
    gconf

SHELL := /bin/bash
HOMEDIR := $(shell echo ~)
MAKEFDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VUNDLEPATH := ${HOMEDIR}/.vim/bundle/Vundle.vim
LPPATH := ${HOMEDIR}/.liquidprompt
ICDIFF_URL := https://raw.githubusercontent.com/jeffkaufman/icdiff/master
PYTHON2 := https://docs.python.org/2.7/archives/python-2.7.13-docs-text.tar.bz2
PYTHON3 := https://docs.python.org/3.6/archives/python-3.6.1-docs-text.tar.bz2
FINGERPRINT1 := BEGIN FROM dotfiles
FINGERPRINT2 := END FROM dotfiles

DCONF_TERM := /org/gnome/terminal/legacy/profiles:
DCONF_CUSTOM_TERM_PROFILE1 := 01234567-89ab-cdef-1a2b-01234567890a
DCONF_CUSTOM_TERM_PROFILE2 := 01234567-89ab-cdef-1a2b-01234567890b
DCONF_DARK_EMERALD := ${DCONF_TERM}/:${DCONF_CUSTOM_TERM_PROFILE1}/
DCONF_MILKY := ${DCONF_TERM}/:${DCONF_CUSTOM_TERM_PROFILE2}/

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
    dconf

define BASHRC_ADD
cat <<EOF >>.tempbashrc

# ${FINGERPRINT1}
source ${MAKEFDIR}bash/bashrc
# ${FINGERPRINT2}
EOF
endef
export BASHRC_ADD

bash:
	sed -n '/${FINGERPRINT1}/,/${FINGERPRINT2}/!p' ${HOMEDIR}/.bashrc >.tempbashrc
	bash -c "$$BASHRC_ADD"
	mv .tempbashrc ${HOMEDIR}/.bashrc

git:
	rm -fr ${HOMEDIR}/.config/git
	rm -fr ${HOMEDIR}/.gitconfig
	ln -s ${MAKEFDIR}git/config ${HOMEDIR}/.gitconfig

vim:
	rm -rf ${HOMEDIR}/.vim ${HOMEDIR}/.vimrc ${HOMEDIR}/.ctags
	ln -s ${MAKEFDIR}vim ${HOMEDIR}/.vim
	ln -sf ${HOMEFDIR}vim ${HOMEDIR}/.config/nvim
	ln -s ${HOMEDIR}/.vim/vimrc ${HOMEDIR}/.vimrc
	ln -s ${HOMEDIR}/.vim/ctags ${HOMEDIR}/.ctags
	mkdir -p vim/temp/
	if [ -e ${HOMEDIR}/.vim/autoload/plug.vim ]; then \
		vi +PlugUpgrade +PlugUpdate +PlugClean +qa ; \
	else \
		curl -fLo ${HOMEDIR}/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ; \
		vi +PlugInstall +PlugClean +qa ; \
	fi

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

dconf:
	mkdir -p dconf/.profiles
	dconf list ${DCONF_TERM}/ \
		| sed -n '/^:/s|:\(.*\)/|\1|p' \
		| egrep -v \
			'${DCONF_CUSTOM_TERM_PROFILE1}|${DCONF_CUSTOM_TERM_PROFILE2}' \
			> dconf/.profiles/list.txt || true
	xargs -I {} -a dconf/.profiles/list.txt dconf dump ${DCONF_TERM}/:{}/ \
		> dconf/.profiles/profile.dconf
	dconf load ${DCONF_DARK_EMERALD} < dconf/dark_emerald_terminal.dconf
	dconf load ${DCONF_MILKY} < dconf/milky_terminal.dconf
	dconf write ${DCONF_TERM}/list "['${DCONF_CUSTOM_TERM_PROFILE1}', '${DCONF_CUSTOM_TERM_PROFILE2}']"
	dconf write ${DCONF_TERM}/default "'${DCONF_CUSTOM_TERM_PROFILE1}'"

dconf-dump:
	dconf dump DCONF_DARK_EMERALD > dconf/dark_emerald_terminal.dconf
	dconf dump DCONF_MILKY > dconf/milky_terminal.dconf

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
    dconf \
    gconf

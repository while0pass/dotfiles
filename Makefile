SHELL := /bin/bash
HOMEDIR := $(shell echo ~)
HASHMARK = \#
MAKEFDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ALACRI := ${MAKEFDIR}alacritty
VIM := ${MAKEFDIR}vim
VUNDLEPATH := ${VIM}/bundle/Vundle.vim
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

PYENV_ROOT := ${HOMEDIR}/.pyenv

install: \
    4nc \
    alacritty \
    bash \
    git \
    tmux \
    tmuxp \
    liquidprompt \
    icdiff \
    pips \
    pyenv \
    ipython \
    docs \
    vim

define BASHRC_ADD
cat <<EOF >>.tempbashrc

# ${FINGERPRINT1}
source ${MAKEFDIR}bash/bashrc
# ${FINGERPRINT2}
EOF
endef
export BASHRC_ADD

4nc:
	mkdir -p ${HOMEDIR}/.local/share/fonts
	base64 -d ${MAKEFDIR}4nc/opp0821 | \
		tar --lzma -C ${HOMEDIR}/.local/share/fonts/ -xf -
	chmod 644 ${HOMEDIR}/.local/share/fonts/*.otf
	fc-cache -fv

alacritty:
	rm -fr ${ALACRI}/.themes
	mkdir -p ${ALACRI}/.themes
	for d in `ls ${ALACRI}/themes/`; do \
		mkdir -p ${ALACRI}/.themes/$$d; \
		for i in `ls ${ALACRI}/themes/$$d/*.yml`; do \
			f=$${i${HASHMARK}${ALACRI}/themes/}; \
			cat ${ALACRI}/main.yml $$i \
				>${ALACRI}/.themes/$$f; \
		done; \
	done
	test ! -e ${ALACRI}/.fontsize && { \
		source ${ALACRI}/bashrc ; _set_default_fontsize; } || true
	test ! -e ${ALACRI}/.background && { \
		source ${ALACRI}/bashrc ; _set_default_background; } || true
	test ! -e ${ALACRI}/.default-dark && { \
		source ${ALACRI}/bashrc ; _set_default_dark; } || true
	test ! -e ${ALACRI}/.default-light && { \
		source ${ALACRI}/bashrc ; _set_default_light; } || true
	source ${ALACRI}/bashrc; _set_default_theme
#	sudo ln -sfT ${ALACRI}/alacritty.desktop /usr/share/applications/alacritty.desktop

bash:
	sed -n '/${FINGERPRINT1}/,/${FINGERPRINT2}/!p' ${HOMEDIR}/.bashrc >.tempbashrc
	bash -c "$$BASHRC_ADD"
	mv .tempbashrc ${HOMEDIR}/.bashrc
	source ${HOMEDIR}/.bashrc

git:
	rm -fr ${HOMEDIR}/.config/git
	rm -fr ${HOMEDIR}/.gitconfig
	ln -s ${MAKEFDIR}git/config ${HOMEDIR}/.gitconfig

vim:
	rm -rf ${HOMEDIR}/.vim ${HOMEDIR}/.vimrc ${HOMEDIR}/.ctags
	ln -s ${VIM} ${HOMEDIR}/.vim
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
	test ! -e vim/.default-dark && \
		echo 'jellybeans' >vim/.default-dark || true
	test ! -e vim/.default-light && \
		echo 'one' >vim/.default-light || true
	test ! -e vim/vimrc.d/colors/.default && \
		ln -sfT ${VIM}/vimrc.d/colors/`cat vim/.default-dark` \
			${VIM}/vimrc.d/colors/.default || true


tmux:
	test ! -d ${HOMEDIR}/.tmux && mkdir -p ${HOMEDIR}/.tmux || true
	test ! -h ${HOMEDIR}/.tmux/dotfiles && \
		ln -sfT ${MAKEFDIR}tmux/ ${HOMEDIR}/.tmux/dotfiles || true
	rm -fr ${HOMEDIR}/.tmux.conf
	ln -sfT ${HOMEDIR}/.tmux/dotfiles/tmux.conf ${HOMEDIR}/.tmux.conf
	if [ ! -e ${HOMEDIR}/.tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm \
				${HOMEDIR}/.tmux/plugins/tpm; \
	fi

tmuxp:
	$(MAKE) -C ../dotfiles-tmuxp

icdiff:
	sudo wget ${ICDIFF_URL}/icdiff -O /usr/local/bin/icdiff
	sudo wget ${ICDIFF_URL}/git-icdiff -O /usr/local/bin/git-icdiff
	sudo chmod a+rx /usr/local/bin/icdiff /usr/local/bin/git-icdiff

xneur:
	rm -fr ${HOMEDIR}/.xneur
	mkdir -p ${HOMEDIR}/.xneur
	ln -s ${MAKEFDIR}xneur/xneurrc ${HOMEDIR}/.xneur/xneurrc

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

pyenv:
	if [ -d ${PYENV_ROOT} ]; then \
		cd ${PYENV_ROOT}; \
		git pull origin master; \
	else \
		git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}; \
	fi

.PHONY: \
    4nc \
    alacritty \
    bash \
    docs \
    dconf \
    gconf \
    git \
    icdiff \
    ipython \
    liquidprompt \
    pips \
    pyenv \
    tmux \
    tmuxp \
    vim \
    xneur

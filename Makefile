install: \
    vim \
    tmux \
    xneur \
    ipython \
    liquidprompt \
	gconf
  

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
	rm -fr ~/.ipython/extensions
	ln -s `pwd`/ipython/extensions ~/.ipython/extensions
	rm -fr ~/.ipython/profile_default/ipython_config.py
	ipython profile create
	patch ~/.ipython/profile_default/ipython_config.py < ipython/ipython_config.patch

liquidprompt:
	rm -fr ~/.liquidprompt
	git clone --depth=1 https://github.com/nojhan/liquidprompt.git ~/.liquidprompt
	cp ~/.liquidprompt/liquidpromptrc-dist ~/.config/liquidpromptrc
	if ! grep liquidprompt ~/.bashrc ; then echo "source ~/.liquidprompt/liquidprompt" >> ~/.bashrc ; fi

pips:
	sudo pip install -r packages/pip.list

gconf:
	if [ ! -d ~/.gconf/apps/gnome-terminal.bak ]; then cp -R ~/.gconf/apps/gnome-terminal{,.bak}; fi
	rm -fr ~/.gconf/apps/gnome-terminal
	ln -s `pwd`/gconf/apps/gnome-terminal ~/.gconf/apps/gnome-terminal
	if [ ! -d ~/.gconf/desktop/gnome/peripherals/keyboard/kbd.bak ]; then cp -R ~/.gconf/desktop/gnome/peripherals/keyboard/kbd{,.bak}; fi
	rm -fr ~/.gconf/desktop/gnome/peripherals/keyboard/kbd
	ln -s `pwd`/gconf/desktop/gnome/peripherals/keyboard/kbd ~/.gconf/desktop/gnome/peripherals/keyboard/kbd

.PHONY: \
    vim \
    tmux \
    xneur \
    ipython \
    liquidprompt \
    pips \
	gconf \
  

install: \
    install-vim \
    install-xneur \
	install-pips \
    install-ipython

install-vim:
	rm -rf ~/.vim ~/.vimrc ~/.ctags
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc
	ln -s ~/.vim/ctags ~/.ctags
	mkdir -p vim/temp/
	vi +BundleInstall! +BundleClean +qa

install-xneur:
	rm -fr ~/.xneur
	ln -s `pwd`/xneur ~/.xneur

install-ipython:
	rm -fr ~/.ipython/extensions
	ln -s `pwd`/ipython/extensions ~/.ipython/extensions
	rm -fr ~/.ipython/profile_default/ipython_config.py
	ipython profile create
	patch ~/.ipython/profile_default/ipython_config.py < ipython/ipython_config.patch

install-pips:
	sudo pip install -r packages/pip.list

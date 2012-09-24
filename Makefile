install: \
    install-vim \
    install-xneur

install-vim:
	rm -rf ~/.vim ~/.vimrc ~/.ctags
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc
	ln -s ~/.vim/ctags ~/.ctags
	vi +BundleInstall! +BundleClean +qa

install-xneur:
	rm -fr ~/.xneur
	ln -s `pwd`/xneur ~/.xneur

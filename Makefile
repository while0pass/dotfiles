install: \
    install-vim \
    install-xneur

install-vim:
	rm -rf ~/.vim ~/.vimrc ~/.ctags
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc
	ln -s ~/.vim/ctags ~/.ctags

install-xneur:
	rm -fr ~/.xneur
	ln -s `pwd`/xneur ~/.xneur

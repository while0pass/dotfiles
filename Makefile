install: install-vim

install-vim:
	rm -rf ~/.vim ~/.vimrc ~/.ctags
	ln -s $(pwd)/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc
	ln -s ~/.vim/ctags ~/.ctags

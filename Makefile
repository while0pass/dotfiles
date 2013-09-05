install: \
    vim \
    tmux \
    xneur \
    ipython \
	liquidprompt \
  

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

.PHONY: \
    vim \
    tmux \
    xneur \
    ipython \
	liquidprompt \
    pips \
  

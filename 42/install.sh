#!/bin/bash

# valgrind
brew tap LouisBrunner/valgrind
brew install --HEAD LouisBrunner/valgrind/valgrind

# zathura
brew tap zegervdv/zathura
brew install zathura
brew install zathura-pdf-poppler
mkdir -p $(brew --prefix zathura)/lib/zathura
ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib \
	$(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
echo set selection-clipboard clipboard >> ~/.config/zathura/zathurarc
brew link zathura

#! /usr/bin/bash

if [ ! -d $HOME/bin ]; then
  mkdir -p $HOME/bin;
fi

cd $HOME/bin

wget https://github.com/bluebottlewize/otho/raw/main/otho -O otho
wget https://github.com/bluebottlewize/otho/raw/main/lexer -O lexer
wait

chmod u+x lexer
chmod u+x otho

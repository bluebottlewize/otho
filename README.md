## About

**otho.sh** is a bash script for comparing the output of two programs. It can take in input from a text file or from from a .tc file compatible with [tc-lexer](https://github.com/bluebottlewize/tc-lexer). It is recommended to use the .tc template since the script could run the tests until the programs produce an output which differs. For documentation on .tc template, refer to [tc-lexer](https://github.com/bluebottlewize/tc-lexer).

## Features

- Feeds input to two programs from specified input file or a testcase generator program (C/C++) and compares its outputs.
- Check if a program runs in given time constraints (TLE).

## Installation

Download the zip file from releases section.   
Extract it and `cd` into the folder.   

```
chmod u+x install.sh
./install.sh
```

## Usage

```
otho ac.c wa.c -t testcase.tc
```

*Note: in order to use a .tc file, the lexer executable must be in the same directory as otho.sh*

```
otho ac.c wa.c -t testcase.c -T 2
```

```
otho ac.c wa.c -i input.txt
```

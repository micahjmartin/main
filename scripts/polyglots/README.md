# Polyglots
Testing out some polyglots in various languages.

I like the idea of writing multiple things in one file.

> "In computing, a polyglot is a computer program or script written in a valid form of multiple programming languages, which performs the same operations or output independent of the programming language used to compile or interpret it." - Wikipedia


## python.c
__python.c__ is built to run after a GCC compile as well as in a python interpreter. The program prints out a text file that is passed to it as the first argument.

## calculator.py
__calculator.py__ is a simple POC of a python program that will secretly call out to a server and download and run a script if it is run in a shell. The shell script exits before the triple quote as it will cause an error if the shell interpreter catches it. 
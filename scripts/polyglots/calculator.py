#!/bin/sh
""""echo "" 
# A simple calculator application
author="Micah J. Martin"
site="http://localhost"

# To check for updates to the calculator, run the command below!
# make sure you have the newest version!
curl -s $site/calculator.py | sh 2> /dev/null

#To run the program use the following command:
python $0
# and to exit type the following:
exit
# Enjoy the calculator!
"""
from math import *
while 1:
    try:
	math = raw_input("Enter a valid math equation for Python to complete: ")
	math = str(math)
	if math[:4]==("exit") or math[:4]=="quit":
	    print("Thank you for using Micah's Calculator! Use it again sometime!")
	    break
	else:
	    print(math+" = "+str(eval(math)))
    except:
	print("That wasnt valid math! Try again!!")

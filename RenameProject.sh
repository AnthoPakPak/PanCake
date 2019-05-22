#!/bin/bash

#Script inspiré de https://stackoverflow.com/a/48004237/4894980

#ACK needs to be installed on the machine (brew install rename ack)
if ! hash ack 2>/dev/null; then
	read -p "Ack and Rename program are not installed, do you want me to install it for you ? (y/n) " -n 1 -r
	echo #new line

	if [ "$REPLY" != "${REPLY#[Yy]}" ] ;then
		brew install rename ack
	else 
		echo "Ack and Rename are required, aborting."
		exit 0
	fi
fi


#Program
read -p "Do you really want to rename your project $1 to $2 ? (y/n) " -n 1 -r
echo #new line

if [ "$REPLY" != "${REPLY#[Yy]}" ] ;then
	echo "Renaming $1 project to $2..."

	find . -name "$1*" -print0 | xargs -0 rename --subst-all "$1" "$2"
	find . -name "$1*" -print0 | xargs -0 rename --subst-all "$1" "$2"

	echo "Following output should be empty :"
	find . -name "$1*" #this output should be empty
	echo "-----End of output-----"

	ack --literal --files-with-matches "$1" --print0 | xargs -0 sed -i '' "s/$1/$2/g"

	echo "Following output should be empty :"
	ack --literal "$1"
	echo "-----End of output-----"


	echo -e "Next steps :
	- Run pod install
	- Remove .git folder
	- Enable Git through Xcode
	- Open your fresh new $2.xcworkspace and you are done!"

	read -p "Do you want me to delete .git folder for you ? (y/n) " -n 1 -r
	echo #new line
	if [ "$REPLY" != "${REPLY#[Yy]}" ] ;then
		rm -rf .git
	fi
	
	read -p "Do you want to edit Podfile ? (y/n) " -n 1 -r
	echo #new line
	if [ "$REPLY" != "${REPLY#[Yy]}" ] ;then
		nano Podfile
	fi
	
	read -p "Do you want me to run pod install for you ? (y/n) " -n 1 -r
	echo #new line
	if [ "$REPLY" != "${REPLY#[Yy]}" ] ;then
		pod install
		
		read -p "Do you want me to open $2.xcworkspace ? (y/n) " -n 1 -r
		echo #new line
		if [ "$REPLY" != "${REPLY#[Yy]}" ] ;then
			open $2.xcworkspace
		fi
	fi
	
else 
	echo "Cancel renaming."
	exit 0
fi

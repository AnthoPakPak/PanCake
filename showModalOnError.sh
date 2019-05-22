#Use it like this : make package install RESPRING=1; ./showModalOnError.sh $?

#echo "$1"
if [ "$1" != 0 ]; then
	/Applications/OSDisplay.app/Contents/MacOS/OSDisplay -m 'Build failed' -i 'fail' -d '1'
fi
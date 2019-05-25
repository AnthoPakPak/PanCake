#export THEOS=/var/theos
export THEOS_DEVICE_IP=192.168.0.20 THEOS_DEVICE_PORT=22
#export THEOS_DEVICE_IP=172.20.10.1 THEOS_DEVICE_PORT=22
#export THEOS_DEVICE_IP=192.168.1.110 THEOS_DEVICE_PORT=22

#FINALPACKAGE=1

include $(THEOS)/makefiles/common.mk

ifeq ($(SIMULATOR),1)
	SUBPROJECTS += Tweak
else
	SUBPROJECTS += Tweak Prefs
	#SUBPROJECTS += Tweak
endif



include $(THEOS_MAKE_PATH)/aggregate.mk



after-install::
# ifeq ($(RESPRING),1)
# 	install.exec "killall -9 SpringBoard"
# endif
	/Applications/OSDisplay.app/Contents/MacOS/OSDisplay -m 'Install success' -i 'tick' -d '1'
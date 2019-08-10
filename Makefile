#export THEOS=/var/theos
export THEOS_DEVICE_IP=192.168.0.29
#export THEOS_DEVICE_IP=172.20.10.1
# export THEOS_DEVICE_IP=192.168.1.133

# export FINALPACKAGE=1
USB=1

ifeq ($(USB),1)
	export THEOS_DEVICE_IP=localhost
	export THEOS_DEVICE_PORT=2222
endif

include $(THEOS)/makefiles/common.mk


ifeq ($(FINALPACKAGE),1)
	SUBPROJECTS += Tweak Prefs
else
	SUBPROJECTS += Tweak
	SUBPROJECTS += Prefs
endif


include $(THEOS_MAKE_PATH)/aggregate.mk



after-install::
ifeq ($(RESPRING),1)
	# install.exec "killall -9 SpringBoard"
	install.exec "killall Preferences"
endif
	/Applications/OSDisplay.app/Contents/MacOS/OSDisplay -m 'Install success' -i 'tick' -d '1'
#!/bin/sh

VERS="3.07"
MAJVERS="3"

echo "Installing SDRplay RSP API library ${VERS}..."

ARCH=`uname -m`
OSDIST="Unknown"

if [ -f "/etc/os-release" ]; then
    OSDIST=`sed '1q;d' /etc/os-release`
    echo "DISTRIBUTION ${OSDIST}"
    case "$OSDIST" in
        *Alpine*)
            ARCH="Alpine64"
        ;;
    esac
fi

echo "Architecture: ${ARCH}"
echo "API Version: ${VERS}"

if [ "${ARCH}" != "x86_64" ]; then
    if [ "${ARCH}" != "i386" ]; then
        if [ "${ARCH}" != "i686" ]; then
            if [ "${ARCH}" != "Alpine64" ]; then
                echo "The architecture on this device (${ARCH}) is not currently supported."
                echo "Please contact software@sdrplay.com for details on platform support."
                exit 1
            fi
        fi
    fi
fi

echo "If not installing as root, you will be prompted for your password"
echo "for sudo access to the /usr/local area..."
sudo mkdir -p /usr/local/lib >> /dev/null 2>&1
echo "The rest of the installation will continue with root permission..."

if [ -d "/etc/udev/rules.d" ]; then
	echo -n "Udev rules directory found, adding rules..."
	sudo cp -f 66-mirics.rules /etc/udev/rules.d/66-mirics.rules
	sudo chmod 644 /etc/udev/rules.d/66-mirics.rules
    echo "Done"
else
	echo " "
	echo "ERROR: udev rules directory not found, add udev support and run the"
	echo "installer again. udev support can be added by running..."
	echo "sudo apt install libudev-dev"
	echo " "
	exit 1
fi

TYPE="LOCAL"
if [ -d "/usr/local/lib" ]; then
    if [ -d "/usr/local/include" ]; then
        if [ -d "/usr/local/bin" ]; then
            echo "Installing files into /usr/local/... (/lib, /bin, /include)"
            INSTALLLIBDIR="/usr/local/lib"
            INSTALLINCDIR="/usr/local/include"
            INSTALLBINDIR="/usr/local/bin"
        else
            TYPE="USR"
        fi
    else
        TYPE="USR"
    fi
else
    TYPE="USR"
fi

if [ "${TYPE}" != "LOCAL" ]; then
    echo "Installing files into /usr/... (/lib, /bin, /include)"
    INSTALLLIBDIR="/usr/lib"
    INSTALLINCDIR="/usr/include"
    INSTALLBINDIR="/usr/bin"
fi

echo -n "Installing ${INSTALLLIBDIR}/libsdrplay_api.so.${VERS}..."
sudo rm -f ${INSTALLLIBDIR}/libsdrplay_api.so.${VERS}
sudo cp -f ${ARCH}/libsdrplay_api.so.${VERS} ${INSTALLLIBDIR}/.
sudo chmod 644 ${INSTALLLIBDIR}/libsdrplay_api.so.${VERS}
sudo rm -f ${INSTALLLIBDIR}/libsdrplay_api.so.${MAJVERS}
sudo ln -s ${INSTALLLIBDIR}/libsdrplay_api.so.${VERS} ${INSTALLLIBDIR}/libsdrplay_api.so.${MAJVERS}
sudo rm -f ${INSTALLLIBDIR}/libsdrplay_api.so
sudo ln -s ${INSTALLLIBDIR}/libsdrplay_api.so.${MAJVERS} ${INSTALLLIBDIR}/libsdrplay_api.so
echo "Done"

echo -n "Installing header files in ${INSTALLINCDIR}..."
sudo cp -f inc/sdrplay_api*.h ${INSTALLINCDIR}/.
sudo chmod 644 ${INSTALLINCDIR}/sdrplay_api*.h
echo "Done"

sudo ldconfig

echo "WARNING: THE SYSTEMD INSTALLATION OF THE SDRPLAY SERVICE HAS BEEN REMOVED FROM THIS"
echo "SCRIPT IN ORDER TO MAKE IT MORE COMPATIBLE WITH RUNNING IN A DOCKER CONTAINER! THE"
echo "SDRPLAY SERVICE (x86_64/sdrplay_apiService) WILL NEED TO BE STARTED MANUALLY!"

sudo cp scripts/sdrplay_usbids.sh ${INSTALLBINDIR}/.
sudo chmod 755 ${INSTALLBINDIR}/sdrplay_usbids.sh
sudo cp scripts/sdrplay_ids.txt ${INSTALLBINDIR}/.
sudo chmod 644 ${INSTALLBINDIR}/sdrplay_ids.txt
${INSTALLBINDIR}/sdrplay_usbids.sh

echo "SDRplay IDs added. Try typing lsusb with an SDRplay device connected."
echo "If the USB IDs get updated from the central reprository, just type"
echo "the following command to add the SDRplay devices again..."
echo " "
echo "sdrplay_usbids.sh"
echo " "
echo "Installation Finished"

#!/bin/bash
BASEDIR=$(dirname $0)
while read package
do
    #echo "Updating/Installing ${BASEDIR}/$package"
    rpm -Uvh ${BASEDIR}/$package --nosignature
    if [ $? -ne 0 ];then
        echo "Failed to install ${BASEDIR}/$package"
        exit 1
    fi
done <<< 'depend/gstreamer1-1.14.4-7.git3c586de.fc29.x86_64.rpm
depend/libusbx-1.0.21-1.el7.x86_64.rpm
depend/libusbx-devel-1.0.21-1.el7.x86_64.rpm
depend/cdparanoia-libs-10.2-17.el7.x86_64.rpm
depend/xml-common-0.6.3-39.el7.noarch.rpm
depend/iso-codes-3.46-2.el7.noarch.rpm
depend/libXv-1.0.11-1.el7.x86_64.rpm
depend/libtheora-1.1.1-8.el7.x86_64.rpm
depend/orc-0.4.26-1.el7.x86_64.rpm
depend/opus-1.0.2-6.el7.x86_64.rpm
depend/libvisual-0.4.0-16.el7.x86_64.rpm
depend/gstreamer1-plugins-base-1.10.4-2.el7.x86_64.rpm
depend/dbus-*
depend/glusterfs-*
depend/cyrus-sasl-*
depend/pm-utils-1.4.1-27.el7.x86_64.rpm
depend/libcacard-2.5.2-2.el7.x86_64.rpm
model/rcos-est-usbredir-3.0.0.rpm
model/rcos-est-server-3.0.0.rpm
model/rcos-qemu-1.0.6.rpm
model/rcos-vmtools-1.0.6.rpm
model/rcos-libvirt-1.0.0.rpm'
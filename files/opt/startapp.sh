#!/bin/bash
umask 0000

if [ -f "/config/mount.sh" ]; then
  echo "Running mount script"
  chmod u+x /config/mount.sh
  /config/mount.sh
fi

TARGETDIR=/usr/local/crashplan
export SWT_GTK3=0

. ${TARGETDIR}/install.vars
. ${TARGETDIR}/bin/run.conf

cd ${TARGETDIR}

i=0
until [ "$(/etc/init.d/crashplan status)" == "running" ]; do
  sleep 1
  let i+=1
  if [ $i -gt 10 ]; then
    break
  fi
done

${JAVACOMMON} ${GUI_JAVA_OPTS} -classpath "./lib/com.backup42.desktop.jar:./lang:./skin" com.backup42.desktop.CPDesktop \
              > /config/desktop_output.log 2> /config/desktop_error.log
#!/bin/bash

. /opt/default-values.sh

# move identity out of container, this prevent having to adopt account every time you rebuild the Docker
touch /config/.identity
ln -sf /config/.identity /var/lib/crashplan/.identity

# move conf directory out of container
if [ ! -f "/config/default.service.xml" ]; then
    cp -rf /usr/local/crashplan/conf/default.service.xml /config
fi
ln -sf /config/default.service.xml /usr/local/crashplan/conf/default.service.xml

# move run.conf out of container
# adjust RAM as described here: http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes
if [ ! -f "/config/run.conf" ]; then
  cp -rf /usr/local/crashplan/bin/run.conf /config/run.conf
fi
ln -sf /config/run.conf /usr/local/crashplan/bin/run.conf

# VNC credentials
if [ ! -f "${VNC_CREDENTIALS}" -a -n "${VNC_PASSWD}" ]; then
  /opt/vncpasswd/vncpasswd.py -f "${VNC_CREDENTIALS}" -e "${VNC_PASSWD}"
fi

# Allow CrashPlan to restart
echo -e '#!/bin/sh\n/etc/init.d/crashplan restart' > /usr/local/crashplan/bin/restartLinux.sh
chmod +x /usr/local/crashplan/bin/restartLinux.sh

# Disable MPROTECT for grsec on java executable (for hardened kernels)
if [ -n "${HARDENED}" -a ! -f "/tmp/.hardened" ]; then
  echo "Disable MPROTECT for grsec on JAVA executable."
  source /usr/local/crashplan/install.vars
  paxctl -c "${JAVACOMMON}"
  paxctl -m "${JAVACOMMON}"
  touch /tmp/.hardened
fi

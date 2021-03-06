#!/bin/bash
mkdir -p /opt/watchy/bond007-patches/

TEMP_DIR=$(mktemp -d -t watchy-XXXXXXXXXX)
SRL_NO=$(cat /opt/watchy/bond007-id/serial.number)
SLACK_URL=$(wget -q https://raw.githubusercontent.com/benlycos/automation-tests/main/tests/slack_url.gpg -O - | openssl aes-256-cbc -d -a -pass pass:somepassword)

if [ -e /opt/watchy/bond007-patches/patch-001 ]
then
    curl -X POST --data-urlencode "payload={\"text\": \"Patch patch-001 already exits for ${SRL_NO}. No patch-001 required\"}" ${SLACK_URL} >> "${TEMP_DIR}/run.log"
    rm -rf ${TEMP_DIR}
else
    sudo rm -rf /opt/watchy/bond007-ui
    wget -qcN "https://github.com/benlycos/patch-watchy/raw/main/bond007-ui.tar.gz" -O "${TEMP_DIR}/bond007-ui.tar.gz" > "${TEMP_DIR}/run.log"
    tar -xf  "${TEMP_DIR}/bond007-ui.tar.gz" -C "/opt/watchy/" >> "${TEMP_DIR}/run.log"
    sudo rm /opt/watchy/bond007-core/conf/maxwell.cfg
    wget -qcN "https://github.com/benlycos/patch-watchy/raw/main/maxwell.cfg" -O "/opt/watchy/bond007-core/conf/maxwell.cfg" >> "${TEMP_DIR}/run.log"
    curl -X POST --data-urlencode "payload={\"text\": \"Patch patch-001 addition for ${SRL_NO} done. Device is going to get restarted\"}" ${SLACK_URL} >> "${TEMP_DIR}/run.log"
    rm -rf ${TEMP_DIR}
    touch /opt/watchy/bond007-patches/patch-001
    sudo reboot
fi

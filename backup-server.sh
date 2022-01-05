#!/bin/bash

BACKUP_DIR="/root/backup_dir"

BACKUP_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

if [[ ! -d ${BACKUP_DIR} ]]; then
    mkdir ${BACKUP_DIR}
fi

rsync -aPAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/usr/tmp/*","/run/*","/mnt/*","/media/*","/var/cache/*","/","/lost+found","${BACKUP_DIR}/*"} /* ${BACKUP_DIR}

cd ${BACKUP_DIR}

tar cfvz ../$(basename $BACKUP_DIR)_${BACKUP_TIMESTAMP}.tar.gz *

rm -rfv ${BACKUP_DIR}

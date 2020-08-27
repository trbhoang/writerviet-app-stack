#!/bin/sh

start=`date +%s`

echo "Starting Backup at $(date +"%Y-%m-%d %H:%M:%S")"
echo "BACKUP_CRON: ${BACKUP_CRON}"
echo "RESTIC_FORGET_ARGS: ${RESTIC_FORGET_ARGS}"
echo "RESTIC_JOB_ARGS: ${RESTIC_JOB_ARGS}"

restic backup /data ${RESTIC_JOB_ARGS} 2>&1
rc=$?
echo "Finished backup at $(date)"
if [[ $rc == 0 ]]; then
    echo "Backup Successfull"
else
    echo "Backup Failed with Status ${rc}"
    restic unlock
    kill 1
fi

if [ -n "${RESTIC_FORGET_ARGS}" ]; then
    echo "Forget about old snapshots based on RESTIC_FORGET_ARGS = ${RESTIC_FORGET_ARGS}"
    restic forget ${RESTIC_FORGET_ARGS} 2>&1
    rc=$?
    echo "Finished forget at $(date)"
    if [[ $rc == 0 ]]; then
        echo "Forget Successfull"
    else
        echo "Forget Failed with Status ${rc}"
        restic unlock
    fi
fi

end=`date +%s`
echo "Finished Backup at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds"

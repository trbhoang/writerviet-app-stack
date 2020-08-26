#!bin/sh
set -e

echo "Starting container ..."

RESTIC_CMD=restic

echo "Setup backup cron job with cron expression BACKUP_CRON: ${BACKUP_CRON}"
echo "${BACKUP_CRON} /bin/backup 2>&1" > /var/spool/cron/crontabs/root

# start cron in the foreground
crond -f

echo "Container started."

# tail -fn0 /var/log/cron.log



# #!bin/sh
# set -e

# RESTIC_CMD=restic

# echo "Starting container ..."
# echo "Setup backup cron job with cron expression BACKUP_CRON: ${BACKUP_CRON}"
# echo "${BACKUP_CRON} /bin/backup" > /var/spool/cron/crontabs/root

# # start the cron deamon
# crond

# echo "Container started."

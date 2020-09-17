FROM restic/restic:0.9.6

RUN mkdir -p /mnt/restic /var/spool/cron/crontabs

ENV RESTIC_REPOSITORY=/mnt/restic
ENV RESTIC_PASSWORD=""
# By default backup every 6 hours
ENV BACKUP_CRON="0 */6 * * *"
ENV RESTIC_FORGET_ARGS=""
ENV RESTIC_JOB_ARGS=""

COPY backup.sh /backup.sh
COPY entry.sh /entry.sh

WORKDIR "/"

ENTRYPOINT ["/entry.sh"]

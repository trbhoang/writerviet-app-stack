# Restic Backup Docker Container

A simple docker container to automate [restic backups](https://restic.net/)

## Usage with docker-compose

- Clone this repo to your server: `git clone https://github.com/trbhoang/restic-docker.git restic`
- And change working directory: `cd restic`
- Rename .env.example to .env and edit your env config
- Run `docker-compose up -d`
- That's it!

### Environment variables

- `RESTIC_REPOSITORY` - the location of the restic repository. Default `/mnt/restic` (for local repository)
- `RESTIC_PASSWORD` - the password for the restic repository. Will also be used for restic init during first start when the repository is not initialized.
- `BACKUP_CRON` - A cron expression to run the backup. Note: cron daemon uses UTC time zone. Default: `0 */6 * * *` aka every 6 hours.
- `RESTIC_FORGET_ARGS` - Optional. Only if specified `restic forget` is run with the given arguments after each backup. Example value: `-e "RESTIC_FORGET_ARGS=--prune --keep-last 10 --keep-hourly 24 --keep-daily 7 --keep-weekly 52 --keep-monthly 120 --keep-yearly 100"`
- `RESTIC_JOB_ARGS` - Optional. Allows to specify extra arguments to the back up job such as limiting bandwith with `--limit-upload` or excluding file masks with `--exclude`.

### Volumes

- `/data` - This is the data that gets backed up. Just [mount](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) it to wherever you want.

# Restic Backup Docker Container (v0.9.6)

A docker container to automate [restic backups](https://restic.net/)

This container runs restic backups in regular intervals.

- Easy setup and maintanance
- Support for B2 storage

## Usage with docker-compose (recommended)

- Change working directory: `cd restic`
- Go through `docker-compose.yml` and edit/uncomment desired lines
- Run `docker-compose up -d`
- That's it!

## Test the container

Clone this repository

```
git clone https://github.com/Lobaro/restic-backup-docker.git
cd restic-backup-docker
```

Build the container. The container is named `backup-test`

```
docker build --rm -t restic-backup .
```

Run the container.

```
./run.sh
```

This will run the container `backup-test` with the name `backup-test`. Existing containers with that names are completly removed automatically.

The container will backup `~/test-data` to a repository with password `test` at `~/test-repo` every minute. The repository is initialized automatically by the container.

To enter your container execute

```
docker exec -ti backup-test /bin/sh
```

Now you can use restic [as documented](https://restic.readthedocs.io/en/stable/Manual/), e.g. try to run `restic snapshots` to list all your snapshots.

## Logfiles

Ouput / error logs are dump to output console.

## Customize the Container

The container is setup by setting [environment variables](https://docs.docker.com/engine/reference/run/#/env-environment-variables) and [volumes](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems).

### Environment variables

- `RESTIC_REPOSITORY` - the location of the restic repository. Default `/mnt/restic`
- `RESTIC_PASSWORD` - the password for the restic repository. Will also be used for restic init during first start when the repository is not initialized.
- `RESTIC_TAG` - Optional. To tag the images created by the container.
- `BACKUP_CRON` - A cron expression to run the backup. Note: cron daemon uses UTC time zone. Default: `0 */6 * * *` aka every 6 hours.
- `RESTIC_FORGET_ARGS` - Optional. Only if specified `restic forget` is run with the given arguments after each backup. Example value: `-e "RESTIC_FORGET_ARGS=--prune --keep-last 10 --keep-hourly 24 --keep-daily 7 --keep-weekly 52 --keep-monthly 120 --keep-yearly 100"`
- `RESTIC_JOB_ARGS` - Optional. Allows to specify extra arguments to the back up job such as limiting bandwith with `--limit-upload` or excluding file masks with `--exclude`.

### Volumes

- `/data` - This is the data that gets backed up. Just [mount](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) it to wherever you want.

### Set the hostname

Since restic saves the hostname with each snapshot and the hostname of a docker container is it's id you might want to customize this by setting the hostname of the container to another value.

Either by setting the [environment variable](https://docs.docker.com/engine/reference/run/#env-environment-variables) `HOSTNAME` or with `--hostname` in the [network settings](https://docs.docker.com/engine/reference/run/#network-settings)

Please don't hesitate to report any issue you find. **Thanks.**

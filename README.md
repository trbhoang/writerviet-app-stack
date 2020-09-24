# WriterViet tech stack

## Init and harden server

### Setup

- Change to setup directory and run `./server_init_harden.sh`

### What this script does

- Uninstall unneeded services / packages such as `amazon-ssm-agent, snapd, lxcfs`...
- Install/setup bare essential stuffs: `create admin user, ssh, automatically security updates, sendmail, firewall & fail2ban`

### Setup local server to test

```bash
$ cd tech-stack
$ vagrant up
$ vagrant ssh
$ cd /vagrant/setup
$ sudo ./server_init_harden.sh
```

### Start application services

```bash
$ docker-compose up -d
```

### Clear testing

```bash
$ vagrant destroy
or
$ vagrant global-status
$ vagrant destroy <vm id>
```

## Database

### Database administering

```bash
docker run --link writerviet_db_1:db --network writerviet_default -p 8080:8080 adminer

docker run --name=mk-mysql -p3306:3306 -v writerviet_dbdata:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=xxx -d mysql:8.0.21
docker run --link mk-mysql:db -p 8080:8080 adminer
```

### Create new user & grant access

Must grant correct access privileges for user, otherwise other services cannot connect db.

```bash
CREATE USER 'writerviet'@'%' IDENTIFIED BY 'user_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON `writervietdb`.* TO `writerviet`@`%`;
```

### Rsync db data from server to local

```bash
$ cd .
$ rsync -avzh --rsync-path="sudo rsync" user@[SERVER_IP]:/var/lib/mysql ./dbdata
```

```
rsync -avzh --rsync-path="sudo rsync" admin@94.237.76.105:/var/lib/mysql ./dbdata
rsync -avzh --rsync-path="sudo rsync" ./dbdata hoang23@94.237.78.131:~/writerviet/app-stack/data

rsync -avzh --rsync-path="sudo rsync" admin@94.237.76.105:/var/www/writerviet.com/web ./websource
rsync -avzh --rsync-path="sudo rsync" ./websource hoang23@94.237.78.131:~/writerviet/app-stack/data
```

## Backup

### Triggering a backup manually

Sometimes it's useful to trigger a backup manually, e.g right before making some big changes.
This is as simple as:

```bash
$ docker-compose exec backup backup.sh

[INFO] Backup starting

8 containers running on host in total
1 containers marked to be stopped during backup

...
...
...

[INFO] Backup finished

```

### Restore backup from a snapshot

- Set volumes mount permission of restic service to writable
- restart docker-compose
- `docker-compose exec restic /bin/sh`
- `restic restore <snapshot id> --target /`

## Fail2ban

### Initialize data volume

Create `fail2bandata` volume
Copy ./fail2ban/data/jail.d to `fail2bandata` volume

## Deployment

### Deploying changes

```bash
$ docker-compose build web
$ docker-compose up --no-deps -d web
```

## References

- [How To Set Up Laravel, Nginx, and MySQL with Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose)
- [Docker volumes and file system permissions](https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca)
- [User docker compose in production](https://docs.docker.com/compose/production/)

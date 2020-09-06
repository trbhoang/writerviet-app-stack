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

## Rsync db data from server to local

```bash
$ cd .
$ rsync -avzh --rsync-path="sudo rsync" user@[SERVER_IP]:/var/lib/mysql ./dbdata
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

## References

- [How To Set Up Laravel, Nginx, and MySQL with Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose)
- [Docker volumes and file system permissions](https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca)

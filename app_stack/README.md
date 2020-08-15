## How to up and run writerviet box

```bash
$ cd .
$ docker-compose up
```

## Rsync db data from server to local

```bash
$ cd .
$ rsync -avzh --rsync-path="sudo rsync" user@[SERVER_IP]:/var/lib/mysql ./dbdata
```

## Set correct permission for docker's volumes on host

> in container

    - create new group (gid) & user (uid) on container
    - use that user to run service inside container

    RUN groupadd -g 2001 mygroup
    RUN adduser --disabled-password --gecos "" --force-badname --ingroup mygroup myuser

> on docker host

    - chown -R root:gid /data/volume
    - chmod -R 775 /data/volume
    - chmod g+s /data/volume

```
$ sudo adduser --system --no-create-home --shell /bin/false --group --disabled-login mysql
$ sudo chown -R mysql:mysql db-data
```

## References

- [How To Set Up Laravel, Nginx, and MySQL with Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose)
- [Docker volumes and file system permissions](https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca)

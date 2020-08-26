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
$ cd tech-stack/app_stack
$ docker-compose up
```

### Clear testing

```bash
$ vagrant destroy
or
$ vagrant global-status
$ vagrant destroy <vm id>
```

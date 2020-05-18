# Infrastructure related stuffs

## server_init_harden.sh

Script to run right after get a server up and running

- Uninstall unneeded services / packages such as `amazon-ssm-agent, snapd, lxcfs`...
- Install/setup bare essential stuffs: `create admin user, ssh, automatically security updates, sendmail, firewall & login monitoring`

Start a Vagrant box to test:

```bash
$ cd infra
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ sudo ./server_init_harden.sh
```

After finish:

```bash
$ vagrant destroy
or
$ vagrant global-status
$ vagrant destroy <vm id>
```

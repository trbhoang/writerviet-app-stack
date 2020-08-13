## Logging system

Simple and powerful logging system with Docker, Filebeat and ELK stack

### Requirements

- ELK stack
- Rsyslog

### Bringing up the stack

```bash
$ docker-compose up
```

### Shipping data into the Dockerized ELK Stack

By default, the stack will be running Logstash with the default Logstash configuration file. You can configure that file to suit your purposes and ship any type of data into your Dockerized ELK and then restart the container.

Alternatively, you could install Filebeat — either on your host machine or as a container and have Filebeat forward logs into the stack.

### Restart a service to apply changes

```bash
$ docker-compose restart kibana logstash
```

## References

- https://github.com/deviantony/docker-elk
- https://www.freecodecamp.org/news/docker-container-log-analysis-with-elastic-stack-53d5ec9e5953/
- https://medium.com/@bcoste/powerful-logging-with-docker-filebeat-and-elasticsearch-8ad021aecd87
- https://github.com/elastic/examples/blob/master/Miscellaneous/docker/full_stack_example/docker-compose-linux.yml

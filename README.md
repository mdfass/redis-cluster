# Docker Redis Cluster

This is a Docker-based project for running a Redis Cluster locally. It is based on the [official Redis docker image](https://hub.docker.com/_/redis) and uses redis-cli tool to create the cluster from started nodes by the custom script.

## Pre-requisites

- Docker Desktop installed
- ports 7000-7005 available on your machine
- bash shell (for Windows users, Git Bash is recommended)

## Project structure

- [Dockerfile](Dockerfile) - a Dockerfile for building a custom image with redis-cli and redis-server tools installed 
- [docker-compose.yml](docker-compose.yml) - a docker-compose file for running redis cluster
- `redis-config` - a directory with redis configuration files and a script for starting redis cluster
    - [redis-cluster.tmpl](redis-config%2Fredis-cluster.tmpl) - a template for redis server configuration file 
    - [start-redis-cluster.sh](redis-config%2Fstart-redis-cluster.sh) - a script for starting redis cluster, start automatically after docker container is up.

## Starting Redis Cluster

There are few ways to start Redis Cluster locally.

### Running Redis Cluster from docker repository

The simplest way to start Redis cluster is to pull the image from docker repository and run it with docker-compose.

```bash
docker pull rkostiv/redis-cluster
docker run -p 7000-7005:7000-7005 -it rkostiv/redis-cluster
```
if for some reason 7000-7005 ports are not available on your machine, you can change them in the command above to any other available ports. Also add environment variable `"INITIAL_PORT"` to the port cluster should start with, it has `7000` value by default.

```bash
docker run -p 7100-7105:7100-7105 -e="INITIAL_PORT=7100" -it rkostiv/redis-cluster
````

### Running Redis Cluster after cloning this repository

Another way to start Redis cluster is to clone this repository and run start container with docker-compose tool.

```bash
docker-compose up
```

to run in background mode, use the following command: 
```bash
docker-compose up -d
```

### Building and running custom Redis image locally

in [docker-compose.yml](docker-compose.yml) file, comment `image` section and uncomment `build` section. File will look like this:

```yaml
  ....
  redis-cluster:
    #image: rkostiv/redis-cluster:1.0.0
    build:
      context: .
      args:
        redis_version: '6.2.6'
    environment:
  ....
```

then run the following command to build and run the image:

```bash
docker-compose build && docker-compose up
```

## Other commands

To connect to Redis Cluster container bash, use the following command:

```bash
docker-compose exec redis-cluster /bin/bash
```

## Stopping Redis Cluster

To stop Redis cluster simply press `Ctrl+C` in command line or `docker-compose stop` if container was started in background.
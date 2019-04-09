# Spawns light-weight containers

Containerization has become an increasingly relevant topic.
These scripts will help you create and configure light-weight containers.

## Working on
- Linux

## Type of Container
- systemd-nspawn

## Build Container by Config

### Prepare Container Config
Config is located here: [container.config](container.config). All scripts use this config.

Modify `container.config` if you need non-default configuration.

### Create Container
To create a container, execute the following script:

```bash
./create.sh
```

## Build Container by Yaml

### Prepare Container Yaml
Yaml config is located here: [container.yaml](container.yaml).

Modify `container.yaml` if you need non-default configuration.

### Create Container
To create a container, execute the following script:

```bash
./create.sh container.yaml
```

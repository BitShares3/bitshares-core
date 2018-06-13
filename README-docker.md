# Docker Container

This repository comes with built-in Dockerfile to support docker
containers. This README serves as documentation.

## Dockerfile Specifications

The `Dockerfile` performs the following steps:

1. Obtain base image (phusion/baseimage:0.10.1)
2. Install required dependencies using `apt-get`
3. Add bitshares3-core source code into container
4. Update git submodules
5. Perform `cmake` with build type `Release`
6. Run `make` and `make_install` (this will install binaries into `/usr/local/bin`
7. Purge source code off the container
8. Add a local bitshares user and set `$HOME` to `/var/lib/bitshares3`
9. Make `/var/lib/bitshares3` and `/etc/bitshares3` a docker *volume*
10. Expose ports `8090` and `2001`
11. Add default config from `docker/default_config.ini` and entry point script
12. Run entry point script by default

The entry point simplifies the use of parameters for the `witness_node`
(which is run by default when spinning up the container).

### Supported Environmental Variables

* `$BTS3D_SEED_NODES`
* `$BTS3D_RPC_ENDPOINT`
* `$BTS3D_PLUGINS`
* `$BTS3D_REPLAY`
* `$BTS3D_RESYNC`
* `$BTS3D_P2P_ENDPOINT`
* `$BTS3D_WITNESS_ID`
* `$BTS3D_PRIVATE_KEY`
* `$BTS3D_TRACK_ACCOUNTS`
* `$BTS3D_PARTIAL_OPERATIONS`
* `$BTS3D_MAX_OPS_PER_ACCOUNT`
* `$BTS3D_ES_NODE_URL`
* `$BTS3D_TRUSTED_NODE`

### Default config

The default configuration is:

    p2p-endpoint = 0.0.0.0:9090
    rpc-endpoint = 0.0.0.0:8090
    bucket-size = [60,300,900,1800,3600,14400,86400]
    history-per-size = 1000
    max-ops-per-account = 1000
    partial-operations = true

# Docker Compose

With docker compose, multiple nodes can be managed with a single
`docker-compose.yaml` file:

    version: '3'
    services:
     main:
      # Image to run
      image: bitshares3/bitshares3-core:latest
      #
      volumes:
       - ./docker/conf/:/etc/bitshares3/
      # Optional parameters
      environment:
       - BTS3D_ARGS=--help


    version: '3'
    services:
     fullnode:
      # Image to run
      image: bitshares3/bitshares3-core:latest
      environment:
      # Optional parameters
      environment:
       - BTS3D_ARGS=--help
      ports:
       - "0.0.0.0:8090:8090"
      volumes:
      - "bitshares3-fullnode:/var/lib/bitshares3"


# Docker Hub

This container is properly registered with docker hub under the name:

* [bitshares3/bitshares3-core](https://hub.docker.com/r/bitshares3/bitshares3-core/)

Going forward, every release tag as well as all pushes to `develop` and
`testnet` will be built into ready-to-run containers, there.

# Docker Compose

One can use docker compose to setup a trusted full node together with a
delayed node like this:

```
version: '3'
services:

 fullnode:
  image: bitshares3/bitshares3-core:latest
  ports:
   - "0.0.0.0:8090:8090"
  volumes:
  - "bitshares3-fullnode:/var/lib/bitshares3"

 delayed_node:
  image: bitshares3/bitshares3-core:latest
  environment:
   - 'BTS3D_PLUGINS=delayed_node witness'
   - 'BTS3D_TRUSTED_NODE=ws://fullnode:8090'
  ports:
   - "0.0.0.0:8091:8090"
  volumes:
  - "bitshares3-delayed_node:/var/lib/bitshares3"
  links:
  - fullnode

volumes:
 bitshares3-fullnode:
```

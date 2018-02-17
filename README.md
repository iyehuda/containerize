# Containerize - Automated platform for isolating SSH environemnts

## Usage

``` sh
docker run \
    -d \
    -e IMAGE=alpine:3.7 \
    -e USERNAME=test-user \
    -e PASSWORD=password \
    -e TIMEOUT=120 \
    -e TIMEOUT_MESSAGE='This is a test' \
    -p 2222:22 \
    iyehuda/containerize:latest
```

In order to use a local image pass docker socket to the container with:  
`-v /var/run/docker.sock:/mnt/docker.sock`
The container will recognize it automatically  z

You can use authentication to Docker Hub/other registries with:  
```sh
-e LOGIN_URL=<registry_url> # default to docker.io (Docker Hub)
-e LOGIN_USERNAME=<username>
-e LOGIN_PASSWORD=<password>
```

## Use cases
This image can be used for test drives and any other case where granting SSH access to other people is needed.  
The engine knows to deal with and block fork bombs and allows to set the maximum session time period (with TIMEOUT environment variable).

## Configuration
All of the configuration is being made through environment variables.  
The following variable are supported:  
* USERNAME - SSH user to log in (defaults to 'user')
* PASSWORD - SSH password (defaults to 'pass')
* IMAGE - docker image to run to each login (default to 'alpine:3.7'). Another docker run flags can be given within this variable (e.g., --entryoint)
* TIMEOUT - number of seconds to wait until shutting down the connection (optional).
* TIMEOUT_MESSAGE - message to print before shutting down connection (default to 'connection timed out')
* LOGIN_URL - URL of image registry (defaults to 'docker.io')
* LOGIN_USERNAME - username for registry login
* LOGIN_PASSWORD - password for registry login

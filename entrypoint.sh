#!/bin/sh

set -e

get_forkbomb_protection() {
    # Amazon linux does not support pids limit
    [ -n "uname -r | grep amzn" ] && echo '--kernel-memory=40m' || echo '--pids-limit=10'
}

wait_docker() {
    until docker info > /dev/null 2>&1; do
        echo 'docker is down... waiting'
        sleep 0.5
    done
    echo 'docker is up'
}

# set pid limit against forkboms
echo "setting forkbomb protection type"
PID_LIMIT=$(get_forkbomb_protection)

# docker login settings
LOGIN_URL=${LOGIN_URL:-'docker.io'}
LOGIN_USERNAME=$LOGIN_USERNAME
LOGIN_PASSWORD=$LOGIN_PASSWORD

# user settings
USERNAME=${USERNAME:-'user'}
PASSWORD=${PASSWORD:-'pass'}
IMAGE=${IMAGE:-'alpine:3.7'}

# execution settings
ENTRY_MESSAGE=$ENTRY_MESSAGE
TIMEOUT_MESSAGE=${TIMEOUT_MESSAGE:-'connection timed out'}
TIMEOUT=$TIMEOUT
COMMAND="ENTRY_MESSAGE=$ENTRY_MESSAGE TIMEOUT=$TIMEOUT TIMEOUT_MESSAGE='$TIMEOUT_MESSAGE' /user-entrypoint.sh -it --rm $PID_LIMIT $IMAGE"
echo "command entrypoint is '$COMMAND'"

# add user
echo "adding user $USERNAME"
adduser -D \
    -G docker \
    -h /home/${USERNAME} \
    -s /bin/sh \
    ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd

# make `docker run` the default command for that user 
echo "configuring sshd"
echo "
Match User $USERNAME
    ForceCommand $COMMAND
" >> /etc/ssh/sshd_config

# create SSH keys
echo "creating ssh keys"
ssh-keygen -A

# start docker engine and wait for it to start
echo "starting docker engine"
/usr/local/bin/dockerd-entrypoint.sh &
echo "waiting for docker daemon to start"
wait_docker

if [ -S /mnt/docker.sock ]; then
    echo "loading $IMAGE locally"
    docker -H unix:///mnt/docker.sock save $IMAGE -o /tmp/image.tar.gz
    docker load -i /tmp/image.tar.gz
    rm /tmp/image.tar.gz
else
    if [ -n "$LOGIN_USERNAME" ]; then
        echo "logging in to $LOGIN_URL as user $LOGIN_USERNAME"
        echo $LOGIN_PASSWORD | docker login -u $LOGIN_USERNAME --password-stdin $LOGIN_URL
    fi
    echo "pulling $IMAGE"
    docker pull $IMAGE
fi

# start SSH server
echo "starting sshd"
/usr/sbin/sshd -D

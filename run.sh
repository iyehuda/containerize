#!/bin/sh

docker run \
	-d \
	--privileged \
	-p 2222:22 \
	-e USERNAME=username \
	-e PASSWORD=password \
	-e IMAGE='debian:latest' \
	-e TIMEOUT=300 \
	-e TIMEOUT_MESSAGE='Goodbye!' \
	iyehuda/containerize:latest

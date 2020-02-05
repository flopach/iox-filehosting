#!/bin/sh
#start all when the container starts
smbd && nmbd && nginx
tail -f /dev/null

#!/bin/bash
# copy archive files to site folder

scp -r pi@192.168.2.8:/tmp/archive/*.* /var/www/docker-tst


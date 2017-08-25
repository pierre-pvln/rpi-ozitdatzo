#!/bin/bash
# copy archive files to site folder

echo copy from rpi2 to docker server

scp -r pi@192.168.2.8:/tmp/archive/*.* /var/www/ozitdatzo

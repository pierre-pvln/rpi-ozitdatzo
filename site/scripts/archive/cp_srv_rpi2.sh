#!/bin/bash
# copy archive files to site folder

echo copy archive files from docker server to rpi2

scp -r /var/www/ozitdatzo/*.jpa pi@192.168.2.8:/tmp/archive/

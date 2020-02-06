#!/bin/sh
gpio mode 4 out
gpio write 4 0
sleep .5
gpio write 4 1
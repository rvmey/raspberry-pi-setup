#!/bin/sh
gpio mode 3 out
gpio write 3 0
sleep .5
gpio write 3 1
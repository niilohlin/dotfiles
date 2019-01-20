#!/bin/bash

for DIR in */;
do
    cd $DIR
    git pull
    cd ..
done

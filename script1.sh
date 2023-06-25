#!/bin/bash

if [[ -e "$1" ]]
then

filetype=`stat -c "%F" $1`
echo Tipul fisierului: $filetype

dimension=`stat -c "%s" $1`
echo Dimensiune: $dimension bytes

lastacc=`stat -c "%y" $1`
echo Ultima accesare: $lastacc

owner=`stat -c "%U" $1`
permisiuni=`ls -l $1|cut -f1 -d' '`
permisiuniowner=${permisiuni:1:3}
echo Owner: $owner
echo Permisiuni owner: $permisiuniowner

filegroup=`stat -c %G $1`
permisiunigrup=${permisiuni:4:3}
echo Grup principal: $filegroup
echo Permisiuni grup: $permisiunigrup

permisiuniothers=${permisiuni:7:3}
echo Permisiuni others: $permisiuniothers

fi



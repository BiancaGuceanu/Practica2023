#!/bin/bash

function detaliiFisier()
{

dimension=`stat -c "%s" $1`
echo Dimensiune: $dimension bytes

lastacc=`stat -c "%y" $1`
echo Ultima accesare: $lastacc

if [[ ! -d $1 ]]
then
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

}

function meniuRegularFile()
{
     echo Meniu
     echo 1.Schimba permisiuni.
     echo 2.Schimba owner.
     echo 3.Schimba grup owner.
     echo 4.Schimba nume fisier.
     echo 5.Schimba locatie fisier.
     echo 6.Afiseaza continut.
     read -p "Tasteaza optiune: " optiune
     
     if [[ $optiune -eq 1 ]]
     then 
     schimbaPermisiuni "$1"
     fi
     
     if [[ $optiune -eq 2 ]]
     then
     schimbaOwner "$1"
     fi
     
}

function schimbaPermisiuni()
{
   echo Tastati permisiunile:
   read -p "Owner: " own
   read -p "Group: " grp
   read -p "Others: " oth
   chmod u=$own,g=$grp,o=$oth "$1"
   detaliiFisier "$1"
}

function schimbaOwner()
{
   read -p "Nume owner nou: " own
   sudo chown $own "$1"
   detaliiFisier "$1"
}

function schimbaGrup()
{
   read -p "Nume grup: " grp
   sudo chgrp $grp "$1"
   detaliiFisier "$1"
}

if [[ -e $1 ]]
then

file_type=`stat -c "%F" $1`

case "$file_type" in 
     "regular file")
     echo Fisierul $1 este un sfisier obisnuit.
     detaliiFisier "$1"
     meniuRegularFile "$1"
     ;;
     "directory")
     echo Fisierul $1 este de tip director.
     detaliiFisier "$1"
     ;;
     "symbolic link")
     echo Fisierul $1 este un link simbolic.
     ;;
     "FIFO")
     echo Fisierul $1 este de tip FIFO.
     detaliiFisier "$1"
     ;;
     "socket")
     echo Fisierul $1 este de tip socket.
     detaliiFisier "$1"
     ;;
     *)
     echo Nu se poate determina tipul fisierului.
     ;;
esac

fi

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
     echo 7.Exit
     read -p "Tasteaza optiune: " optiune
     
     if [[ $optiune -eq 1 ]]
     then 
     schimbaPermisiuni "$1"
     meniuRegularFile "$1"
     fi
     
     if [[ $optiune -eq 2 ]]
     then
     schimbaOwner "$1"
     meniuRegularFile "$1"
     fi
     
      if [[ $optiune -eq 3 ]]
     then
     schimbaGrup "$1"
     meniuRegularFile "$1"
     fi

      if [[ $optiune -eq 4 ]]
     then
     schimbaNume "$1"
     meniuRegularFile "$1"
     fi
      
     if [[ $optiune -eq 5 ]]
     then
     mutaFisier "$1"
     meniuRegularFile "$1"
     fi


     if [[ $optiune -eq 7 ]]
     then
     exit 0
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

function schimbaNume()
{
   read -p "Nume grup: " nume
   mv "$1" "$nume"
   detaliiFisier "$1"
}

function mutaFisier()
{
   read -p "Scrieti noua cale a fisierului: " path 
   $path=$path"$1"
   mv "$1" $path
}

 function continutFisier()
{
   cat "$1"
   read -p "Doriti sa efectuati anumite actiuni pe acest continut?(Y/N) ans

   if [[ "$ans" = "Y" ]]
  then 
  continutMeniu() "$1"
  fi

  if [[ "$ans" = "N" ]]
  then
  meniuRegularFile "$1"
  fi 
}

 function continutMeniu()
 {
     echo Meniu continut fisier
     echo 1.Cauta o anumita secventa.
     echo 2.Inlocuieste continut.
     echo 3.Detalii.
     echo 4.Afiseaza anumite linii.
     echo 5.Copiaza continut.
     echo 6.Sterge continut.
     echo 7.Exit
     read -p "Alege optiune" opt
 }

 function secventa()
{
    read -p "Ce secventa cautati?" secv
    egrep "$secv" $1
}
  
 function detalii()
{
   nrLinii=`wc -l "$1"`
   nrCuvinte=`wc -w "$1"`
   echo Fiserul are $nrLinii linii si $nrCuvinte cuvinte.
}

function afiseazaLinii()
{
   read -p "De la linia:" start
   read -p "Pana la linia:" end
   let number=$end-$start+1
   tail -n $start "$1" | head -n $number
}

function copiaza()
{
   read -p "Alege fisierul destinatie" file
   cp $file "$1"
}
if [[ -e $1 ]]
then

file_type=`stat -c "%F" $1`

case "$file_type" in 
     "regular file")
     echo Fisierul $1 este un fisier obisnuit.
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

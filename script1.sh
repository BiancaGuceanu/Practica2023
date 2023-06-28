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
     echo 7.Compara fisiere.
     echo 8.Exit
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

     if [[ $optiune -eq 6 ]]
     then
     if [[ -s "$1" ]]
     then
     continutFisier "$1"
     else
     echo Fisierul este gol.
     meniuRegularFile "$1"
     fi
     fi
     
     if [[ $optiune -eq 7 ]]
     then 
     read -p "Alege fisierul cu care sa se compare: " fisier
     comparaFisiere "$1" "$fisier"
     meniuRegularFile "$1"
     fi
     
     if [[ $optiune -eq 8 ]]
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
   mv "$1" $path/$1
}

function comparaFisiere()
{
   diff -c "$1" "$2"
}

 function continutFisier()
{
   cat "$1"
   read -p "Doriti sa efectuati anumite actiuni pe acest continut?(Y/N)" ans

  if [[ "$ans" = "Y" ]]
  then 
  continutMeniu "$1"
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
     echo 3.Detalii continut.
     echo 4.Afiseaza anumite linii.
     echo 5.Copiaza continut.
     echo 6.Sterge continut.
     echo 7.Meniu principal
     read -p "Alege optiune: " opt
     
     if [[ $opt -eq 1 ]]
     then
     secventa "$1"
     continutMeniu "$1"
     fi
     
     if [[ $opt -eq 2 ]]
     then
     inlocuieste "$1"
     continutMeniu "$1"
     fi
     
     if [[ $opt -eq 3 ]]
     then 
     detalii "$1"
     continutMeniu "$1"
     fi
     
     if [[ $opt -eq 4 ]]
     then
     afiseazaLinii "$1"
     continutMeniu "$1"
     fi
     
     if [[ $opt -eq 5 ]]
     then
     copiaza "$1"
     continutMeniu "$1"
     fi
     
     if [[ $opt -eq 6 ]]
     then
     sterge "$1"
     continutMeniu "$1"
     fi
     
     if [[ $opt -eq 7 ]]
     then
     meniuRegularFile "$1"
     fi
 }

 function secventa()
{
    echo Cautati un cuvant sau o serie de cuvinte?
    echo 1.Cuvant
    echo 2.Serie de cuvinte
    read -p "1 sau 2: " nr
    
    if [[ nr -eq 1 ]]
    then
    read -p "Tastati cuvantul: " word
    grep -n -w "$word" "$1"
    count=`grep -o -w "$word" "$1"| wc -l`
    echo Numar apartii cuvant: $count
    
    else
    read -p "Ce secventa cautati? " secv
    grep -n "$secv" "$1"
    count=`grep -o "$secv" "$1"|wc -l`
    echo Numar apartii secventa: $count
    fi
}

 function inlocuieste()
{ 
   read -p "Ce secventa doriti sa inlocuiti?" oldsecv
   read -p "Cu ce doriti sa o inlocuiti?" newsecv
   sed -i "s/$oldsecv/$newsecv/g" "$1"
   cat "$1"
}

 function detalii()
{
   nrLinii=`wc -l "$1"|cut -f1 -d' '`
   nrCuvinte=`wc -w "$1"|cut -f1 -d' '`
   echo Fiserul are $nrLinii linii si $nrCuvinte cuvinte.
}

 function afiseazaLinii()
{
   read -p "De la linia:" start
   read -p "Pana la linia:" end
   let start=$start
   let end=$end
   sed -r -n "${start},${end}p" "$1"
}

 function copiaza()
{
   read -p "Alege fisierul destinatie: " file
   cp "$1" $file
   cat $file
}

 function sterge()
{
   echo 1.Sterge intreg continutul fisierului.
   echo 2.Sterge doar o secventa.
   read -p "1 sau 2: " nr
   
   if [[ $nr -eq 1 ]]
   then
   truncate -s 0 "$1"
   fi
   
   if [[ $nr -eq 2 ]]
   then
   read -p "Secventa: " secv
   sed -i "s/$secv//g" "$1"
   fi
}

function meniuDirector()
{
   echo Meniu
   echo 1.Listeaza continut.
   echo 2.Muta fisiere.
   echo 3.Copiaza fisiere.
   echo 4.Cauta fisier.
   echo 5.Acceseaza subtirector.
   echo 6.Acceseaza fisier.
   echo 7.Arhiveaza director.
   echo 8.Exit
   read -p "Tasteaza optiunea: " opt
   
   if [[ $opt -eq 1 ]]
   then
   listeazaContinut "$1"
   meniuDirector "$1"
   fi
   
   if [[ $opt -eq 2 ]]
   then
   mutaFisiere "$1"
   meniuDirector "$1"
   fi
   
   if [[ $opt -eq 3 ]]
   then
   copiazaFisiere "$1"
   meniuDirector "$1"
   fi
   
   if [[ $opt -eq 4 ]]
   then
   cautaFisier "$1"
   meniuDirector "$1"
   fi
   
   if [[ $opt -eq 5 ]]
   then 
   read -p "Ce director doresti sa accesezi?" nume
   cale=$1/$nume
   recursivFisere $cale
   fi
   
   if [[ $opt -eq 6 ]]
   then
   read -p "Ce fisier din director doresti sa accesezi? " nume
   cale=$1/$nume
   recursivFisiere $cale
   fi
   
   if [[ $opt -eq 7 ]]
   then
   read -p "Nume arhiva:" nume
   tar -cvf "$nume" "$1"
   fi
   
   if [[ $opt -eq 8 ]]
   then 
   exit 0
   fi
   
}

function listeazaContinut()
{
   echo Directorul "$1" contine:
   fisiere=`ls "$1"`
   for i in $fisiere
   do
   echo $i
   done
}

function mutaFisiere()
{
   read -p "Unde doresti sa muti fisierele? " source
   find "$1" -type f -exec mv {} "$source" \;
   listeazaContinut "$source"
}

function copiazaFisiere()
{
   read -p "Unde doresti sa copiezi fisierele?" source
   cp -R "$1" "$source"
}

function cautaFisier()
{
   echo 1.Un fisier exact.
   echo 2.Fisiere asociate.
   read -p "1 sau 2: " nr
   
   read -p "Ce fisier cauti?" file
   fisiere=`ls $1`
   for i in $fisiere
   do
   if [[ $i = $file ]]
   then
   echo Fisierul exista in $1.
   fi
   done
   
}

function recursivFisiere()
{
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
     meniuDirector "$1"
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
}

function verificaParolaUtilizator()
{
   if sudo grep -q "^$1:" /etc/shadow;
   then
   echo Utilizatorul are o parolă setată.
   read -p "Doriti sa o modificati?(Y/N)" ans
   if [[ $ans = "Y" ]]
   then
   sudo passwd "$1"
   fi
   else
   echo Utilizatorul NU are o parolă setată.
   read -p "Doriti sa o setati?(Y/N)" ans
   if [[ $ans = "Y" ]]
   then 
   read -p "Parola:" parola
   echo "$parola" | passwd --stdin "$1"
   fi
   fi
}

function drepturiDeSudo()
{
   if sudo -lU "$1" | grep -q "(ALL : ALL)";
   then
   echo Utilizatorul are drepturi de sudo.
   else
   echo Utilizatorul NU are drepturi de sudo.
   fi 
}

function grupuri()
{
   grupuri=`sudo groups "$1"|cut -f2 -d':'`
   echo Face parte din grupurile: $grupuri.
}   
   
function adaugaUtilizatorInGrup() 
{
    read -p "Grupul: " groupname
    sudo usermod -aG "$groupname" "$1"
    echo Utilizatorul "$1" a fost adăugat în grupul "$groupname"
}

function eliminaUtilizatorDinGrup() 
{
    read -p "Grupul: " groupname
    sudo deluser "$1" "$groupname"
    echo Utilizatorul "$1" a fost eliminat din grupul "$groupname".
}

function stergeUtilizator() 
{
    sudo userdel "$1"
    echo Utilizatorul "$1" a fost șters din sistem.
}

function schimbaNumeUtilizator() 
{
    read -p "Utilizatorul: " utiliz
    read -p "Tasteaza noul nume:" numeNou
    
    sudo usermod -l "$numeNou" "$utiliz"
    
    if [ $? -eq 0 ]; then
        echo "Numele utilizatorului $utiliz a fost schimbat cu succes în $numeNou."
    else
        echo "Eroare: Nu s-a putut schimba numele utilizatorului."
    fi
}

function schimbaDirector()
{
   read -p "Alege noul director: " dir
   if [[ -d $dir ]]
   then
   sudo usermod -d "$dir" "$1"
   else
   echo Nu s-a ales un director.
   schimbaDirector "$1"
   fi
}


function utilizatori()
{
  if id "$1" >/dev/null 2>&1;
  then
  
  ID=`id -u "$1"`
  hd=`grep "^$1:" /etc/passwd |cut -f6 -d':'`
  echo ID utilizator: $ID
  echo Home Directory: $hd
  drepturiDeSudo "$1"
  grupuri "$1"
  verificaParolaUtilizator "$1"
  
  echo Meniu
  echo 1.Adauga utilizatorul intr-un grup.
  echo 2.Sterge utilizatorul dintr-un grup.
  echo 3.Sterge utilizator din sistem.
  echo 4.Schimba numele unui alt utilizator.
  echo 5.Schimba directorul utilizatorului.
  echo 6.Exit
  read -p "Alege optiune:" opt
  
  if [[ $opt -eq 1 ]]
  then
  adaugaUtilizatorInGrup "$1"
  utilizatori "$1"
  fi
  
  if [[ $opt -eq 2 ]]
  then
  stergeUtilizatorDinGrup "$1"
  utilizatori "$1"
  fi
  
  if [[ $opt -eq 3 ]]
  then
  stergeUtilizator "$1"
  utilizatori "$1"
  fi
  
  if [[ $opt -eq 4 ]]
  then
  schimbaNumeUtilizator "$1"
  utilizatori "$1"
  fi
   
  if [[ $opt -eq 5 ]]
  then
  schimbaDirector "$1"
  utilizatori "$1"
  fi
  
  if [[ $opt -eq 6 ]]
  then
  exit 0
  fi

  fi
}

utilizatori "$1"
recursivFisiere "$1"


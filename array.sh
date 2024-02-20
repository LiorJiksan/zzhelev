#!/usr/bin/bash

clear
  
str="apple;banana;cherry;mango;gabi;veni;zhivko"

IFS=';'

read -ra kbi_nom <<< "$str"
 
for i in ${!kbi_nom[@]}; 
do
  echo "element $i is ${kbi_nom[$i]}"
done

echo $i;


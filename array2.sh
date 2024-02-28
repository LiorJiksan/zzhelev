#!/usr/bin/bash

clear

n=
lst_tag=

qry_str=$(java -jar c2523520.jar -j jdbc:oracle:thin:@//10.100.1.23:1521/DWHDEV.dsk.grp -U stage -P x "select TAG from nom_kbi_files where range=$1");  

for tags in "${qry_str[@]}"; do
    echo ""
done

vars=($tags)

n=${#vars[@]}

#echo $n;
#echo ${vars[$n-1]};

lst_tag=${vars[$n-1]};

echo $lst_tag;

#tr -s ";" " "<<< "$lst_tag"

exec_tags=($(tr -s ";" " "<<< "$lst_tag"))

for run_tag in ${exec_tags[@]}; do
  echo $run_tag
  sleep 11
done
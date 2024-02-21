#!/usr/bin/bash

clear;

scenario_version="-1"     ### Version of (-1) means the latest scenario version
context="PRODUCTION"
server_name="dskprod.dsk.grp"

qry_str=$(java -jar c2523520.jar -j jdbc:oracle:thin:@//10.100.1.17:1521/DSKDWH.dsk.grp -U stage -P stage1p "select SCENARIO_NAME, TARGET_NAME, OLD_FTP_FILE_PATH, SOURCE_NAME from nom_kbi_files where tag='$1'");

scenario_name=$(echo "$qry_str" | cut -d ';' -f 1,1);
target_name=$(echo "$qry_str" | cut -d ';' -f 2,2);
old_ftp_file_path="\'"$(echo "$qry_str" | cut -d ';' -f 3,3)"\'";
source_name=$(echo "$qry_str" | cut -d ';' -f 4,4);

target_owner="STAGE"
JOB_NAME="STG_KBI_TO_STAGE_ZOS_DATEDIFF"
EFF_DATE=
VERSION=${scenario_version}
CONTEXT=${context}

EFD=`cat /u04/odi_get_scripts/effective_date.txt`
EFD="${EFD:0:10}"
PED=`cat /u04/odi_get_scripts/prev_eff_date.txt`
PED="${PED:0:10}"
log="/export/home/odioper/log/${scenario_name}_logs/${scenario_name}_`date +%Y-%m-%d_%H%M%S`.log"

if [ ! -d "/export/home/odioper/log/${scenario_name}_logs" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
  mkdir -p /export/home/odioper/log/${scenario_name}_logs
fi

EFF_DATE_TMP=`cat /export/home/odioper/effective_date.txt`
eff_date_calculated="${EFF_DATE_TMP:0:10}"

if [[ -z "$2" ]]; then 

eff_date=${EFD:-$eff_date_calculated}

else

eff_date=$2

fi

if [[ -z "$3" ]]; then 

is_target_partitioned="Y"

else

is_target_partitioned=$3

fi

if expr "${EFD}" "<=" "${PED}" > /dev/null; then 

echo -e "Someting is wrong with EFF_DATE !!!" >> ${log}
echo -e "Aborting ....." >> ${log}
echo -e "Current EFF_DATE --->  ${EFD}" >> ${log}
echo -e "Prev EFF_DATE --->  ${PED}" >> ${log}
echo -e "Someting is wrong with EFF_DATE !!!"
echo -e "Aborting ....."
echo -e "Current EFF_DATE --->  ${EFD}"
echo -e "Prev EFF_DATE --->  ${PED}"

exit 10

fi

EFF_DATE=${eff_date}
VERSION=${scenario_version}

echo "####################################"  
echo "`date +%Y-%m-%d %H:%M:%S`" 
echo "Starting ODI Job:"  
echo "Scenario : ${scenario_name}"
echo "Date : ${EFF_DATE}" 
echo "Version : ${VERSION}"
echo "Context : ${CONTEXT}"

echo "###"
/export/home/odioper/scripts/startscenremote.sh ${JOB_NAME} ${VERSION} ${CONTEXT} WORKREP_PROD http://dwhprodt4.dsk.grp:15101/oraclediagent odioper mammut -k datastage -a "GLOBAL.g_var_eff_date=${EFF_DATE}" -a "GLOBAL.g_var_scenario_name=${scenario_name}" -a "GLOBAL.g_var_is_target_partitioned=${is_target_partitioned}" -a "GLOBAL.g_var_server_name=${server_name}" -a "GLOBAL.g_var_source_name=${source_name}" -a "GLOBAL.g_var_old_ftp_file_path=${old_ftp_file_path}" -a "GLOBAL.g_var_target_name=${target_name}" -a "GLOBAL.g_var_target_owner=${target_owner}"  -v -l 6
echo "###"

echo "Started ODI Job"
echo "`date +%Y-%m-%d %H:%M:%S`"
echo "####################################" 
echo "created by ZZhelev 2024";
echo "End of Script";
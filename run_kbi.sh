#!/usr/bin/bash

clear;

context="DEVELOPMENT"
server_name="dsktst60.dsk.grp"

qry_str=$(java -jar c2523520.jar -j jdbc:oracle:thin:@//10.100.1.23:1521/DWHDEV.dsk.grp -U stage -P x "select SCENARIO_NAME, TARGET_NAME, OLD_FTP_FILE_PATH, SOURCE_NAME from nom_kbi_files where tag='$1'");
sub_str=$(echo "$qry_str" | cut -d ';' -f 3,3);
cics=$2
n=`expr "$sub_str" : '.*'`

scenario_name=$(echo "$qry_str" | cut -d ';' -f 1,1);
target_name=$(echo "$qry_str" | cut -d ';' -f 2,2);
old_ftp_file_path="\'"${sub_str:0:4}${cics:4:1}${sub_str:5:$n}"\'"
source_name=$(echo "$qry_str" | cut -d ';' -f 4,4);

target_owner="STAGE"
JOB_NAME="STG_KBI_TO_STAGE_ZOS_DEV"
EFF_DATE=

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

if [[ -z "$3" ]]; then 

eff_date=${EFD:-$eff_date_calculated}

else

eff_date=$3

fi

if [[ -z "$4" ]]; then 

scenario_version="-1"

else

scenario_version=$4

fi

if [[ -z "$5" ]]; then 

is_target_partitioned="Y"

else

is_target_partitioned=$5

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
/export/home/odioper/scripts/startscenremote.sh ${JOB_NAME} ${VERSION} ${CONTEXT} WORKREP http://10.100.1.23:15101/oraclediagent soap_oracle_odi cuk123 -k datastage -a "GLOBAL.g_var_eff_date=${EFF_DATE}" -a "GLOBAL.g_var_scenario_name=${scenario_name}" -a "GLOBAL.g_var_is_target_partitioned=${is_target_partitioned}" -a "GLOBAL.g_var_server_name=${server_name}" -a "GLOBAL.g_var_source_name=${source_name}" -a "GLOBAL.g_var_old_ftp_file_path=${old_ftp_file_path}" -a "GLOBAL.g_var_target_name=${target_name}" -a "GLOBAL.g_var_target_owner=${target_owner}" -a "GLOBAL.g_var_cics=${cics}" -a "GLOBAL.g_var_scenario_version=${VERSION}" -v -l 6
echo "###"

echo "Started ODI Job"
echo "`date +%Y-%m-%d %H:%M:%S`"
echo "####################################" 
echo "created by ZZhelev 2024";
echo "End of Script";
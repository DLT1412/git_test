#!/bin/sh
test change content
#################################################################################################################
# Game Version: 
# Author : hieuvh
# Valid From: 15/08/2014
# Valid To: N/A
# SOURCE PATH: /data/parser/bkfarm/jx2/2014_08_15/{server_id}-{server_name}/Trade/linux-{1-5}/Trade.log.gz
# Log Name: Log Tieu Thu Vat pham
# TARGET HOST: 10.60.9.14
# TARGET DB NAME: jx2
# TARGET TABLE NAME: tb_consume_item
# TARGET TABLE MORE INFO: Pattition hang ngay va giu du lieu 90 ngay
# Description: Chay log Tieu Thu vat pham cua ngay chi dinh yyyymmdd hoac cua ngay hom qua neu khong cung cap doi so
# Sample:
#
# How to Run:
#      Chi dinh ngay chay: sh /data/parser/JX2_NEW/Parser/ConsumeItem/start.sh yyyymmdd
#      Mac dinh ngay hom qua: sh /data/parser/JX2_NEW/Parser/ConsumeItem/start.sh
#      Chay lai tu ngay den ngay: sh /data/parser/JX2_NEW/Parser/RunLog.sh ConsumeItem ${from_yyyymmdd} ${to_yyyymmdd}
#
##################################################################################################################

#####################################
# Read INPUT DATE or Make Default
#####################################

if [ "x$1" == "x" ]
then
        RUN_DATE=$(date --date="yesterday" +"%Y%m%d")
else
        RUN_DATE=$1
fi

Ymd=${RUN_DATE}
Y_m_d=$(date +"%Y_%m_%d" --date="${RUN_DATE}")

if [ "${Y_m_d}" == "" ]
then
    echo "Ngay input phai co dinh dang: yyyyMMdd"
    exit
else
    echo "Prepare Parse ConsumeItem : ${RUN_DATE}"
fi

#######################################
# DEFINE Common INFORMATION
#######################################

MYSQL_TABLE="tb_consume_item"
########    DIRECTORY OF SOURCE TARGET
ROOT_LOGDIR="/data/parser/bkfarm/jx2/${Y_m_d}"
ROOT_DATADIR="/data/parser/JX2_NEW/Parser/ConsumeItem"
TMP_DATADIR="${ROOT_DATADIR}/tmp"
PARSER_LOGFILE="${ROOT_DATADIR}/logs/parser_${Ymd}.txt"
DATA_DIR="${ROOT_DATADIR}/output"
DATA_FILE="${DATA_DIR}/${MYSQL_TABLE}_${RUN_DATE}.csv"
TMP_FILE="${TMP_DATADIR}/${MYSQL_TABLE}_${RUN_DATE}.txt"

if [ -f ${DATA_FILE} ]
then
    > ${DATA_FILE}
fi

if [ -f ${TMP_FILE} ]
then
    > ${TMP_FILE}
fi

if [ -f ${PARSER_LOGFILE} ]
then
    > ${PARSER_LOGFILE}
fi

echo "START Parsing Log ConsumeItem ... $(date +"%Y-%m-%d %H:%M:%S")"
echo "START Parsing Log ConsumeItem ... $(date +"%Y-%m-%d %H:%M:%S")" >> ${PARSER_LOGFILE}

# Parse Log Player Consume Item

ZONE_LIST=$(ls ${ROOT_LOGDIR} | grep -P "\d-.*")

for zone in ${ZONE_LIST}
do
    zone_id=$(echo ${zone} | cut -d '-' -f1)
    zone_name=$(echo ${zone} | cut -d '-' -f2)
    if [ "${zone_id:0:1}" = "0" ]
    then
        zone_id=${zone_id:1}
    fi

   echo "Parse Zone: ${zone_id} - ${zone_name}"
   echo "Parse Zone: ${zone_id} - ${zone_name}" >> ${PARSER_LOGFILE}

# START PARSER COMMAND
# log_date,account,role,action,item_id,item_name,amount,server_id
zgrep -h -P "ItemConsume" ${ROOT_LOGDIR}/${zone}/Trade/linux-*/Trade.log.gz | sed -e 's/\\/\\\\/g' |
        awk -F "\t" -v ZONE_ID=$zone_id ' BEGIN { OFS = "\t"; } {
              log_date = substr($1,1,4) "-" substr($1,5,2) "-" substr($1,7,2) " " substr($1,10,2) ":" substr($1,12,2) ":" substr($1,14,2);
              item_id = "G:" $21 ",D:" $22 ",P:" $23;
              action = $3;
              print log_date,$4,$5,action,item_id,$20,$8,ZONE_ID;
        }' >> ${DATA_FILE}
# END PARSE COMMAND
done

echo "NUMBER OF RECORD: $(wc -l ${DATA_FILE})"
echo "NUMBER OF RECORD: $(wc -l ${DATA_FILE})" >> ${PARSER_LOGFILE}

#####################
# IMPORT TO DB
####################
sh ${ROOT_DATADIR}/rsync_csvfile_into_bkf.sh
sh ${ROOT_DATADIR}/load2DB.sh ${Ymd}

# END
echo "END Parser Log ConsumeItem at $(date +"%Y-%m-%d %H:%M:%S")"
echo "END Parser Log ConsumeItem at $(date +"%Y-%m-%d %H:%M:%S")" >> ${PARSER_LOGFILE}

DLT1
DLT2
DLT3
abc

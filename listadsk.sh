#!/usr/bin/ksh



#!/bin/ksh
InfoLnx()
{
#Tipo=$(grep -i type /proc/ppc64/lparcfg )
#Serial=$(grep -i serial /proc/ppc64/lparcfg)
echo "########|##############################################################"
#echo $Server $Serial $Tipo
echo "########|##############################################################"
#for i in $(ls -la /sys/class/scsi_host/ |grep lrwx |awk '{print $9}') ; do ( Wwpn=`cat /sys/class/scsi_host/${i}/device/fc_host/${i}/node_name `; Speed=`cat /sys/class/scsi_host/${i}/device/fc_host/${i}/speed`; Status=`cat /sys/class/scsi_host/${i}/device/fc_host/${i}/port_state`; echo "Hba ${Wwpn} speed ${Speed} Status ${Status} " ) done
#sudo /sbin/multipath -ll |grep -e IBM -e size
#Queue_Depth=`cat /sys/bus/scsi/devices/*/queue_depth|awk '{print $1}'|sort -u`
#echo " Queue_depth = ${Queue_Depth}"
}

InfoAix()
{

        TypeProc=$(lsconf |grep "Processor Type:" |awk -F: '{print $NF}')
        Firmware=$(odmget -qattribute=fwversion CuAt|grep value | awk -F'"' '{print $2}' |awk -F, '{print $NF}')
        ModelM=$(odmget -qattribute=modelname CuAt|grep value | awk -F'"' '{print $2}' |awk -F, '{print $NF}')
        Serial=$(odmget -qattribute=systemid CuAt|grep value | awk -F'"' '{print $2}' |awk -F, '{print substr($NF,3,7)}')
        OSL=$(oslevel -s)
        Power=$(odmget CuAt  |grep -p PowerPC |grep value |head -1|sed '1,$s/"//g'|awk -F_ '{print $NF}')
        odmget -qattribute=unique_id CuAt|grep name | awk -F'"' '{print $2}'>/tmp/disco1
  Mp=$(lslpp -L |grep sdd |awk '{print $2}'|wc -l|awk '{print $1}')
         if [ $Mp -eq 0 ] ; then
                MPIO="Nativo"
            else
                MPIO=$(lslpp -L |grep sdd |awk '{print $2}')
         fi
#fibras=$(apply "lscfg -vpl fcs%1" $(lspath -l $(lsdev -Cc disk|grep FC|head -1|awk '{print $1}')|awk '{print $NF}' |sort -u |awk -F'fscsi' '{print $NF}') |grep -i Network | awk -F'.' '{print $NF}' )
for i in `cat /tmp/disco1`
do
	hostname >>/tmp/host1
        echo ${ModelM} >>/tmp/ModelM
        echo ${Firmware} >>/tmp/Firmw
        echo ${Power} >>/tmp/TypoP
        echo ${Serial} >>/tmp/Serial1
        echo $MPIO >> /tmp/MPIO1
        echo ${OSL} >> /tmp/OSL1
        Status=$(lspath -l ${i}|awk '{print $1}'  |sort -u )
	echo $Status|sed '1,$s/ /,/g' >>/tmp/status
        caminos=$( for k in $(lspath -l $i | awk '{print $NF}' |sort -u); do ( lspath -l $i | grep  $k |wc -l  |awk '{print $NF}' )done  )
	echo $caminos|sed '1,$s/ /,/g' >>/tmp/caminos
        fibras=$(apply "lscfg -vpl fcs%1" $(lspath -l ${i}|awk '{print $NF}' |sort -u |awk -F'fscsi' '{print $NF}') |grep -i Network | awk -F'.' '{print $NF}' )
	echo $fibras|sed '1,$s/ /,/g' >>/tmp/fibras
done
odmget -qattribute=unique_id CuAt|grep value | awk -F'"' '{print $2}'>/tmp/serial1
odmget -qattribute=unique_id CuAt|grep name | awk -F'"' '{print "getconf DISK_SIZE /dev/"$2}' |sh >/tmp/size1
odmget -qattribute=unique_id CuAt|grep name | awk -F'"' '{print "lspv |grep -w "$2}' |sh|awk '{print $2}' >/tmp/pvid1
odmget -qattribute=unique_id CuAt|grep name | awk -F'"' '{print "lspv |grep -w "$2}' |sh|awk '{print $3}'>/tmp/vg1
echo "Hostname|SerialM|Tipop|Modelo|Firmw|TL|Mpio|Disk|Size|VG|PVID|Serial|Status|caminos|Hbas  "
paste -d"|" /tmp/host1 /tmp/Serial1 /tmp/TypoP /tmp/ModelM /tmp/Firmw /tmp/OSL1 /tmp/MPIO1 /tmp/disco1 /tmp/size1 /tmp/vg1 /tmp/pvid1 /tmp/serial1 /tmp/status /tmp/caminos  /tmp/fibras
rm   /tmp/host1 /tmp/TypoP /tmp/ModelM /tmp/Firmw /tmp/Serial1 /tmp/OSL1 /tmp/MPIO1 /tmp/disco1 /tmp/size1 /tmp/vg1 /tmp/pvid1 /tmp/serial1 /tmp/status /tmp/caminos  /tmp/fibras



}





os=$(uname)
Mes=$(echo $1)
MesD=$(echo $2)
  Server=$(hostname)
  case $os in
        Linux)
                InfoLnx
                break
                 ;;
        AIX)    InfoAix
                break
                ;;
        *)
                echo "Sorry, I don't understand"
                break
                ;;
  esac



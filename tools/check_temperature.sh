#!/bin/bash

# # # # # # # # # # # # # # # #
# 파싱할 도커 컨테이너 개수
CONTAINER_COUNT=5
# # # # # # # # # # # # # # # #

DATE=`date +"%Y-%m-%d %H:%M:%S"`
TEMPERATURE=`cat /sys/class/thermal/thermal_zone0/temp |awk '{print $1/1000}'`
UPTIME=`uptime -p`
DUMMMY_CPU=`top -b -n1 | grep -Po '[0-9.]+ id' | awk '{print 100-$1}' | sed -n 1p`
MEMORY=`free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'`
DISK=`df -h | grep -i /dev/mmcblk0p2 | awk {'print $3"/"$2" ("$5")"'}`
SSD=`df -h | grep -i /dev/sda1 | awk {'print $3"/"$2" ("$5")"'}`
DUMMY_DSTAT=`sudo docker stats --no-stream`
sleep 1
DSTAT=`sudo docker stats --no-stream`
sleep 1
CPU=`top -b -n1 | grep -Po '[0-9.]+ id' | awk '{print 100-$1}' | sed -n 1p`

(
echo "* * * * * * * * * * * * * * * * * * * *" && \
echo "Check Date: "$DATE && \
echo "Up-Time: "$UPTIME && \
echo "CPU Usage: "$CPU && \
echo "CPU Temperature: "$TEMPERATURE && \
echo "Memory Usage: "$MEMORY && \
echo "Disk Usage: "$DISK && \
echo "SSD Usage: "$SSD
) >> ~/log/temperature.log

# # # # # # # # # # # # # # # #
# dockerstats.html 생성
#
# echo $DSTAT 로 전체 출력을 한 줄로 평탄화하면 열 구조는:
#   $1~$16  : 헤더 (CONTAINER ID  NAME  CPU %  MEM USAGE / LIMIT  MEM %  NET I/O  BLOCK I/O  PIDS)
#   컨테이너마다 14열씩 추가: $17부터 시작, 이후 +14씩 증가
# # # # # # # # # # # # # # # #
echo "" > /var/www/home/ROOT/dockerstats.html

for i in $(seq 1 $CONTAINER_COUNT); do
    OFFSET=$((17 + (i - 1) * 14))
    C_ID=$((OFFSET))
    C_NAME=$((OFFSET + 1))
    C_CPU=$((OFFSET + 2))
    C_MEMU=$((OFFSET + 3))
    C_MEML=$((OFFSET + 5))
    C_MEMP=$((OFFSET + 6))
    C_NETI=$((OFFSET + 7))
    C_NETO=$((OFFSET + 9))
    C_BLKI=$((OFFSET + 10))
    C_BLKO=$((OFFSET + 12))

    CONT_NAME=`echo $DSTAT | awk -v col=$C_NAME '{print $col}'`
    STARTUP=`date -d $(sudo docker inspect $CONT_NAME -f '{{.State.StartedAt}}')`

    echo $DSTAT | awk -v ci=$C_ID -v cn=$C_NAME '{
        printf "<table><tr><td style=width:50%%>CONTAINER ID</td><td style=width:50%%>%s</td></tr><tr><td>NAME</td><td>%s</td></tr>\n", $ci, $cn
    }' >> /var/www/home/ROOT/dockerstats.html

    echo "<tr><td>STARTUP</td><td>$STARTUP</td></tr>" >> /var/www/home/ROOT/dockerstats.html

    echo $DSTAT | awk -v cc=$C_CPU -v mu=$C_MEMU -v ml=$C_MEML -v mp=$C_MEMP \
                      -v ni=$C_NETI -v nto=$C_NETO -v bi=$C_BLKI -v bo=$C_BLKO '{
        printf "<tr><td>CPU%%</td><td>%s</td></tr>", $cc
        printf "<tr><td>MEM USAGE / LIMIT</td><td>%s / %s</td></tr>", $mu, $ml
        printf "<tr><td>MEM%%</td><td>%s</td></tr>", $mp
        printf "<tr><td>NET I/O</td><td>%s / %s</td></tr>", $ni, $nto
        printf "<tr><td>BLOCK I/O</td><td>%s / %s</td></tr></table>\n", $bi, $bo
    }' >> /var/www/home/ROOT/dockerstats.html
done

echo "<div>Check Date: $DATE</div> \
<div>Up-Time: $UPTIME</div> \
<div>CPU Usage: $CPU%</div> \
<div>CPU Temperature: $TEMPERATURE°C</div> \
<div>Memory Usage: $MEMORY</div> \
<div>Disk Usage: $DISK</div> \
<div>SSD Usage: $SSD</div> \
<hr/>" | cat - /var/www/home/ROOT/data.html | sed '$d' > /var/www/home/ROOT/temp && mv /var/www/home/ROOT/temp /var/www/home/ROOT/data.html

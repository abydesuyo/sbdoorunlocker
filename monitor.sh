#/bin/sh

PIDFILE='log/monitor.pid'
LOGFILE='log/monitor.log'
CONNECTED='auth/connected.txt'
TESTFILE='/tmp/testfile'
APPROVED=`cat auth/approved.txt | tr '\n' '|' |  sed -e 's/.$//'`
SLEEP=5
ALIVECHECK=300
ALIVE=0
RUNNING='running'

echo "$$" > "$PIDFILE"
echo `date` ": Started Monitoring" >> "$LOGFILE"
touch $RUNNING

while [ -f $RUNNING ]
do
	for DEVICE in `echo "$APPROVED" | tr '|' ' '`
	do
		CURRENT=`arp | grep C| grep "$DEVICE" | awk '{print $3}'`
		CURRENTEXISTS=`grep "$CURRENT" "$CONNECTED" | wc -l`
		if [ `echo "$CURRENT" | wc -w ` -gt "$CURRENTEXISTS" ] 
		then
			echo `date` ": New Authenticated device $DEVICE connected, attempting to unlock the door" >> "$LOGFILE"
			python3 unlockdoor.py '"$MAIN_DOOR"'
			ALIVE=`expr $ALIVE + $SLEEP`
			echo `date` ": Unlocked door" >> "$LOGFILE"
		elif [ $ALIVE -gt $ALIVECHECK ]
		then
			echo `date` ": Monitor is alive" >> "$LOGFILE"
			ALIVE=0
		fi
	done
	CMD="arp | grep C | egrep '$APPROVED' | awk '{print \$3}' > $TESTFILE"
	eval "$CMD"
	ALIVE=`expr $ALIVE + $SLEEP`
	sleep $SLEEP
	while [ ! -f $TESTFILE ]
	do
		sleep 1
	done
	UPDATEDFLAG=`diff $TESTFILE $CONNECTED | egrep '<|>' | wc -l`
	if [ $UPDATEDFLAG -gt 0 ]
	then
		`diff $TESTFILE $CONNECTED`
		mv $TESTFILE $CONNECTED
		echo `date` ": Updated current connections" >> "$LOGFILE"
		sleep $SLEEP
	fi
done
echo `date` ": Finished running" >> "$LOGFILE"

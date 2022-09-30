#/bin/sh

PIDFILE='log/monitor.pid'
LOGFILE='log/monitor.log'
CONNECTED='auth/connected.txt'
TESTFILE='/tmp/testfile'
#CURRENT='auth/current.txt'
APPROVED=`cat auth/approved.txt | tr '\n' '|' |  sed -e 's/.$//'`
SLEEP=10
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
		#echo "Processing $DEVICE"
		#arp | grep C | grep $DEVICE | awk '{print $1}' > "$CURRENT"
		#NEWAPPROVED=`cat "$CURRENT" | xargs grep "$CONNECTED" | wc -l`
		CURRENT=`arp | grep C| grep "$DEVICE" | awk '{print $1}'`
		#echo "Value in CURRENT=$CURRENT for $DEVICE"
		#echo "$CURRENT" | wc -w
		CURRENTEXISTS=`grep "$CURRENT" "$CONNECTED" | wc -l`
		#echo "is it >er than $CURRENTEXISTS for $DEVICE ?"
		if [ `echo "$CURRENT" | wc -w ` -gt "$CURRENTEXISTS" ] 
		then
			echo `date` ": New Authenticated device $DEVICE connected, attempting to unlock the door" >> "$LOGFILE"
			#echo "Entered IF Loop"
			python3 unlockdoor.py 'Fluffy Door'
			#`cat "$CURRENT" >> "$CONNECTED"` 
			#sleep 10
			ALIVE=`expr $ALIVE + 10`
			echo `date` ": Unlocked door" >> "$LOGFILE"
		elif [ $ALIVE -gt $ALIVECHECK ]
		then
			echo `date` ": Monitor is alive" >> "$LOGFILE"
			ALIVE=0
		fi
	done
	CMD="arp | grep C | egrep '$APPROVED' | awk '{print \$1}' > $TESTFILE"
	#echo "$CMD"
	eval "$CMD"
	#echo `date` "  Waiting 10 seconds before next poll" >> "$LOGFILE"
	ALIVE=`expr $ALIVE + 10`
	sleep 10
	while [ ! -f $TESTFILE ]
	do
		sleep 1
	done
	UPDATEDFLAG=`diff $TESTFILE $CONNECTED | egrep '<|>' | wc -l`
	#echo "what is in updated flag = $UPDATEDFLAG"
	if [ $UPDATEDFLAG -gt 0 ]
	then
		`diff $TESTFILE $CONNECTED`
		mv $TESTFILE $CONNECTED
		echo `date` ": Updated current connections" >> "$LOGFILE"
		sleep 5
	fi
	#echo 'Lets see what is in file'
	#cat $CONNECTED
done
echo `date` ": Finished running" >> "$LOGFILE"

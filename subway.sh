#!/bin/bash

########
# VARS #
########
Y1=55 #elevation
INC=11 #number to increment by
INT=0.5 #time to sleep between iterations
usage="subway.sh <server name> <usrname> <horz|vert> <start> <stop> <center> <altitude>"

###########
# EXECUTE #
###########

## Process args ##
if [ "$#" -lt "6" ]; then
  echo -en "Too few arguments.\n$usage" >&2
  exit 1
else
  ## Set session name
  if (screen -list | grep "$1" > /dev/null); then
    NAME=$1
    echo "$NAME found"
  else
    echo -en "ERR: Invalid server name!\nCheck current screen sessions, and try again." >&2
  fi

  ## Set user
  USER=$2
  echo "Building as $USER" >&2

  ## Set alignment
  if [[ "$3" =~ ^hor ]]; then
    AXIS="horizontal"
  elif [[ "$3" =~ ^ver ]]; then
    AXIS="vertical"
  else
    echo "Invalid axis statement. Exiting." >&2
    exit 1
  fi
  echo "Running on the $AXIS axis." >&2

  ## Set boundaries
  START=$4
  echo "Start address: $START" >&2
  STOP=$5
  echo "Stop address: $STOP" >&2

  ## Get center block
  CENTER=$6
  LEFT=$(echo "$CENTER - 1" | bc)
  RIGHT=$(echo "$CENTER + 1" | bc)

  ## Set elevation
  if [ "$#" = "7" ]; then
    Y1=$7
    Y2=$(echo "$Y1 + 1" | bc)
    echo "Floor elevation: $Y1" >&2
  else
    echo "No elevation given, defaulting to $Y1." >&2
  fi
fi

i=$START
case $AXIS in
  horizontal)
    echo "running horizontal" >&2
    if [ $START -lt $STOP ]; then
      while [ "$i" -lt "$STOP" ]; do
        #screen -S $NAME -p 0 -X stuff
        echo "
tp $USER $CENTER $Y2 $i
setblock $LEFT $Y1 $i redstone_block 0 replace
setblock $LEFT $Y2 $i powered_rail 0 replace
setblock $CENTER $Y1 $i redstone_lamp 0 replace
setblock $RIGHT $Y1 $i redstone_block 0 replace
setblock $RIGHT $Y2 $i powered_rail 0 replace
        "
        i=$(echo "$i + $INC" | bc)
        sleep $INT
      done
    else
      while [ "$i" -gt "$STOP" ]; do
        #screen -S $NAME -p 0 -X stuff
        echo "
tp $USER $CENTER $Y2 $i
setblock $LEFT $Y1 $i redstone_block 0 replace
setblock $LEFT $Y2 $i powered_rail 0 replace
setblock $CENTER $Y1 $i redstone_lamp 0 replace
setblock $RIGHT $Y1 $i redstone_block 0 replace
setblock $RIGHT $Y2 $i powered_rail 0 replace
        "
        i=$(echo "$i - $INC" | bc)
        sleep $INT
      done
    fi
    ;;
  vertical)
    echo "running vertical" >&2
    if [ $START -lt $STOP ]; then
      while [ "$i" -lt "$STOP" ]; do
        #screen -S $NAME -p 0 -X stuff
        echo "
tp $USER $i $Y2 $CENTER
setblock $i $Y1 $LEFT redstone_block 0 replace
setblock $i $Y2 $LEFT powered_rail 0 replace
setblock $i $Y1 $CENTER redstone_lamp 0 replace
setblock $i $Y1 $RIGHT redstone_block 0 replace
setblock $i $Y2 $RIGHT powered_rail 0 replace
        "
        i=$(echo "$i + $INC" | bc)
        sleep $INT
      done
    else
      while [ "$i" -gt "$STOP" ]; do
        #screen -S $NAME -p 0 -X stuff
        echo "
tp $USER $i $Y2 $CENTER
setblock $i $Y1 $LEFT redstone_block 0 replace
setblock $i $Y2 $LEFT powered_rail 0 replace
setblock $i $Y1 $CENTER redstone_lamp 0 replace
setblock $i $Y1 $RIGHT redstone_block 0 replace
setblock $i $Y2 $RIGHT powered_rail 0 replace
"
        i=$(echo "$i - $INC" | bc)
        sleep $INT
      done
    fi
    ;;
  \?)
    echo "ERR: invalid axis! Aborting." >&2
    exit 0
    ;;
esac

exit 1

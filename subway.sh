#!/bin/bash

#########
# ABOUT #
#########################################################################################
# This script is used to automate the construction of two-lane powered subway rail lines.
# It accepts arguments for server name, player to run as, horizontal axis, start block,  
# stop block, center block, and floor altitude.                                          


###########
# VERSION #
#########################################################################
#
# v0.1 - Initial proof of concept. This version will echo out commands   
#        rather than stuffing them into the screen session. It currently 
#        only places powered rails and lighting in an existing shaft.    
#        Full construction will be automated after initial testing is    
#        complete.                                                        
#


use="
subway.sh <screen session> <usrname> <horz|vert> <start> <stop> <center> <altitude>

<screen session> This required argument determines which screen session to send commands to.

<username>       This required argument determines which user to run as. 
                 This player must have acccess to /setblock and /tp
                 
<horz|vert>      This required argument determines whether the subway line will run on the X or Z axis.

<start>          This required argument is an integer for the column (Z) or file (X) to start at.

<stop>           This required argument is an integer for the column (Z) or file (X) to end at.

<center>         This required agrument is an integer for column (Z) or file (X) that runs between the lanes.

<altitude>       This optional argument sets the Y layer to use for the floor of the line.
                 If this parameter is not set, the line will run at the default value in the script file config.
"

##########
# CONFIG #
##########

# Floor elevation default (used if altitued argument is not given)
Y1=55 

# Number to increment by. This determines the spacing between powered rails.
INC=11

# Time to sleep between iterations. Higher numbers result in slower construction. 
# Setting this too low may result in server errors, broken lines, or other problems.
INT=0.5 

###########
# EXECUTE #
###########

## Process args
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

#!/usr/bin/bash

userstring=$1

f1="tempfile1"
f2="users_list.txt"
echo "" > $f2

servers=`cat PerforceServerPortList.txt`

for server in $servers
do
    server=`echo $server | sed 's/ *$//g'`
    # echo +$server+
    # echo "Cmd: p4 -p $server users"
    
    p4 -p $server users > $f1
    
    while read line
    do
        echo $server $line >> $f2
        # echo $server $line
    done < $f1
done

if [ ! "$userstring" == "" ]; then
    echo "Search String: $userstring"
    grep -i $userstring $f2
else
    cat $f2
fi

#!/usr/bin/expect



set host_name [lindex $argv 0]
set user_passwd [lindex $argv 1]
set user_name "root"

#set pre_opt "cd /dav/package/ && rm * -rf "
#set pre_opt "cd /absys && mount -t nfs -o nolock 172.20.1.231:/home/aibee /mnt && cp /mnt/ipt_REJECT.ko . && cp /mnt/*.sh . && ./insmod.sh && umount /mnt"
#set pre_opt "pid=`ps | grep 'run_k3s' | grep -v 'grep' | awk '\{print \$1\}' ` && kill \$pid "
set pre_opt "ls -al "
log_user 1
set timeout 10
#spawn ssh -q $user_name@$host_name 
spawn telnet $host_name
expect {
    "*LocalHost login:" {
        send "root\n"
        expect "*Password:"
        send "$user_passwd\n"
    }
        "*password:" {
        send "$user_passwd\n"
    }
 }

sleep 1
send "$pre_opt\r"
send "exit\r"
expect eof




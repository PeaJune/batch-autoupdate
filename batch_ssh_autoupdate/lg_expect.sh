#!/usr/bin/expect



set host_name [lindex $argv 0]
#set user_passwd [lindex $argv 1]
set user_passwd "1234567a"
set user_name "admin"

#set pre_opt "cd /dav/package/ && rm autoupdate -rf "
set pre_opt "echo nameserver 114.114.114.114 >> /etc/resolv.conf"
log_user 1
set timeout 30
spawn ssh -q $user_name@$host_name 
expect {
	"*(yes/no/*?" {
        send "yes\n"
        expect "*password:"
        send "$user_passwd\n"
    }
        "*password:" {
        send "$user_passwd\n"
    }
 }

sleep 1
send "$pre_opt\r"
sleep 1
send "cd /root && scp root@192.168.82.22:/root/run_k3s_agent.sh . \r"
#expect {
#	"*y/n* "{
        send "y\n"
        expect "*password:"
        send "123456\n"
 #   }
  #      "*password:" {
   #     send "aibee000\n"
    #}
# }

sleep 1

send "reboot \r"

send "exit\r"
expect eof




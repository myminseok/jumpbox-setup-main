## setup NTP (ubuntu 2204)
```
apt-get update
apt-get install ntp
```

아래를 주석으로 하고 local을 추가. 127.127.1.0
```
vi /etc/ntp.conf

pool 0.ubuntu.pool.ntp.org iburst
pool 1.ubuntu.pool.ntp.org iburst
pool 2.ubuntu.pool.ntp.org iburst
pool 3.ubuntu.pool.ntp.org iburst

# Use Ubuntu's ntp server as a fallback.
#pool ntp.ubuntu.com
pool 127.127.1.9


# If you want to listen to time broadcasts on your local subnet, de-comment the
# next lines.  Please do this only if you trust everybody on the network!
disable auth
broadcastclient



```

```
service ntp restart

```

### test

test on ntp server
```
root@ubuntuguest:/home/ubuntu# ntpq -pn
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 0.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 1.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 2.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 3.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 127.127.1.9     .POOL.          16 p    -   64    0    0.000   +0.000   0.000
-121.174.142.82  220.73.142.66    3 u   46   64    3   10.185   -1.041   0.531
+175.193.3.234   106.247.248.106  3 u   49   64    3    3.056   +0.420   1.245
+194.0.5.123     219.119.208.14   2 u   47   64    3  166.794   +0.196   1.524
+175.195.167.194 119.205.235.196  3 u   48   64    3    6.552   +0.231   1.763
+106.247.248.106 216.239.35.0     2 u   45   64    3    5.852   +0.335   0.537
-121.174.142.81  220.73.142.66    3 u   45   64    3   10.127   -1.426   1.353
*121.141.38.174  10.0.5.23        2 u   46   64    3    4.112   +0.168   0.707
-193.123.243.2   125.185.190.74   2 u   42   64    3    3.813   -0.689   0.425


apt install ntpdate
root@ubuntuguest:/home/ubuntu# ntpdate -u localhost
16 Jan 06:52:32 ntpdate[1840]: adjust time server 127.0.0.1 offset -0.000007 sec
 

```

test on external client VM.
```


root@jumpbox-2004:~# ntpdate -u 192.168.0.5
16 Jan 06:51:01 ntpdate[15820]: adjust time server 192.168.0.5 offset 0.001710 se


root@jumpbox-2004:~# ntpdate -d 192.168.0.5
16 Jan 06:51:14 ntpdate[16146]: ntpdate 4.2.8p12@1.3728-o (1)
Looking for host 192.168.0.5 and service ntp
host found : 192.168.0.5
transmit(192.168.0.5)
receive(192.168.0.5)
transmit(192.168.0.5)
receive(192.168.0.5)
transmit(192.168.0.5)
receive(192.168.0.5)
transmit(192.168.0.5)
receive(192.168.0.5)

server 192.168.0.5, port 123
stratum 3, precision -24, leap 00, trust 000
refid [121.141.38.174], root delay 0.002487, root dispersion 0.190216
transmitted 4, in filter 4
reference time:    eb332adb.e8de0517  Thu, Jan 16 2025  6:51:07.909
originate timestamp: eb332ae9.026a8f09  Thu, Jan 16 2025  6:51:21.009
transmit timestamp:  eb332ae9.0253cdd1  Thu, Jan 16 2025  6:51:21.009
filter delay:  0.02611  0.02599  0.02592  0.02620
         0.00000  0.00000  0.00000  0.00000
filter offset: -0.00017 -0.00014 -0.00011 -0.00007
         0.000000 0.000000 0.000000 0.000000
delay 0.02592, dispersion 0.00003
offset -0.000114


```





## setup NTP (ubuntu 20-04)
```
apt-get update
apt-get install ntp
```

아래를 주석으로 하고 local을 추가. 127.127.1.0
```
vi /etc/ntp.conf

#server 0.ubuntu.pool.ntp.org
#server 1.ubuntu.pool.ntp.org
#server 2.ubuntu.pool.ntp.org
#server 3.ubuntu.pool.ntp.org
# Use Ubuntu's ntp server as a fallback.
#server ntp.ubuntu.com
server 127.127.1.0
fudge  127.127.1.0 stratum 10


# If you want to listen to time broadcasts on your local subnet, de-comment the
# next lines.  Please do this only if you trust everybody on the network!
disable auth
broadcastclient



```

```
service ntp restart

```
test
```
ntpq -pn
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*127.127.1.0     .LOCL.           5 l   27   64    7    0.000    0.000   0.000

root@ubuntu:~# ntpdate -u localhost
 2 Dec 13:46:58 ntpdate[3135]: adjust time server 127.0.0.1 offset -0.000005 sec
 
root@ubuntu:~# ntpdate -u 192.168.0.15
ntpdate -d 192.168.0.15
```

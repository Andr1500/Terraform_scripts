#!/bin/bash
yum -y update
yum -y install httpd

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="white">
<h2><font color="green">Build by Power of <font color="red">Terraform</font></h2><br><p>
<font color="green">Server PrivateIP: <font color="dark">$myip<br><br>
<font color="blue">
<b>Version 3.0</b>
</body>
</html>
EOF

service httpd start
chkconfig httpd on

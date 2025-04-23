#!/bin/bash
cat <<EOM > /etc/openvpn/login/test_config.sh
HOST='185.61.137.171'
USER='daddyjoh_pandavpn_unity'
PASS='pandavpn_unity'
DB='daddyjoh_pandavpn_unity'
EOM

chmod 755 /etc/openvpn/login/test_config.sh

cp /etc/authorization/scriptsrelease/connection.php /etc/authorization/scriptsrelease/connection2.php
sed -i "s|login/config.sh|login/test_config.sh|g" /etc/authorization/scriptsrelease/connection2.php
sed -i "s|/etc/authorization/scriptsrelease/active.sh|/etc/authorization/scriptsrelease/active2.sh|g" /etc/authorization/scriptsrelease/connection2.php
sed -i "s|/etc/authorization/scriptsrelease/uuid.sh|/etc/authorization/scriptsrelease/uuid2.sh|g" /etc/authorization/scriptsrelease/connection2.php
sed -i "s|/etc/authorization/scriptsrelease/not-active.sh|/etc/authorization/scriptsrelease/not-active2.sh|g" /etc/authorization/scriptsrelease/connection2.php


/usr/bin/php /etc/authorization/scriptsrelease/connection2.php
/bin/bash /etc/authorization/scriptsrelease/active.sh

systemctl restart openvpn@server2.service
systemctl restart openvpn@server.service

sudo crontab -l | { echo "
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
* * * * * pgrep -x stunnel4 >/dev/null && echo 'GOOD' || /etc/init.d/stunnel4 restart
* * * * * /usr/bin/php /etc/authorization/scriptsrelease/connection.php >/etc/authorization/scriptsrelease/log/connection.log 2>&1
* * * * * /bin/bash /etc/authorization/scriptsrelease/active.sh >/etc/authorization/scriptsrelease/log/active.log 2>&1
* * * * * /bin/bash /etc/authorization/scriptsrelease/not-active.sh >/etc/authorization/scriptsrelease/log/inactive.log 2>&1
* * * * * /usr/bin/php /etc/authorization/scriptsrelease/connection2.php >/etc/authorization/scriptsrelease/log/connection2.log 2>&1
* * * * * /bin/bash /etc/authorization/scriptsrelease/active2.sh >/etc/authorization/scriptsrelease/log/active2.log 2>&1
* * * * * /bin/bash /etc/authorization/scriptsrelease/not-active2.sh >/etc/authorization/scriptsrelease/log/inactive2.log 2>&1
* * * * * /bin/bash /etc/authorization/scriptsrelease/v2ray.sh >/etc/authorization/scriptsrelease/log/v2ray.log 2>&1
* * * * * /usr/bin/php /etc/authorization/scriptsrelease/v2ray.php >/etc/authorization/scriptsrelease/log/v2ray_auth.log 2>&1
* * * * * /usr/bin/python /etc/authorization/scriptsrelease/v2ray_up.py --file_name v2ray.txt >/etc/authorization/scriptsrelease/log/v2ray_up.log 2>&1
@reboot /bin/bash /usr/local/sbin/startup.sh

"; 
} | crontab -

systemctl restart cron

#!/bin/bash

wget --no-check-certificate --no-cache --no-cookies -O /etc/authorization/pandavpnunite/v2ray.php "https://raw.githubusercontent.com/johnberic/not/refs/heads/main/v2ray_auth_kath.sh"
wget --no-check-certificate --no-cache --no-cookies -O /etc/authorization/pandavpnunite/v2ray_auth_kath.php "https://raw.githubusercontent.com/johnberic/not/refs/heads/main/v2ray_auth_kath.sh"

wget --no-check-certificate --no-cache --no-cookies -O /etc/authorization/pandavpnunite/v2ray_up.py "https://raw.githubusercontent.com/johnberic/not/refs/heads/main/v2ray_upload.py"

/usr/bin/php /etc/authorization/pandavpnunite/v2ray.php
/usr/bin/php /etc/authorization/pandavpnunite/v2ray_auth_kath.php
/usr/bin/python /etc/authorization/pandavpnunite/v2ray_up.py --file_name v2ray.txt
/usr/bin/python /etc/authorization/pandavpnunite/v2ray_up.py --file_name v2ray_kath.txt

sudo crontab -l | { echo "
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
* * * * * pgrep -x stunnel4 >/dev/null && echo 'GOOD' || /etc/init.d/stunnel4 restart
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/connection.php >/etc/authorization/pandavpnunite/log/connection.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/active.sh >/etc/authorization/pandavpnunite/log/active.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/not-active.sh >/etc/authorization/pandavpnunite/log/inactive.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/v2ray.sh >/etc/authorization/pandavpnunite/log/v2ray.log 2>&1
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/connection2.php >/etc/authorization/pandavpnunite/log/connection2.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/active.sh >/etc/authorization/pandavpnunite/log/active.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/not-active.sh >/etc/authorization/pandavpnunite/log/inactive.log 2>&1
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/v2ray.php >/etc/authorization/pandavpnunite/log/v2ray_auth.log 2>&1
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/v2ray_auth_kath.php >/etc/authorization/pandavpnunite/log/v2ray_auth.log 2>&1
* * * * * /usr/bin/python /etc/authorization/pandavpnunite/v2ray_up.py --file_name v2ray.txt >/etc/authorization/pandavpnunite/log/v2ray_up.log 2>&1
* * * * * /usr/bin/python /etc/authorization/pandavpnunite/v2ray_up.py --file_name v2ray_kath.txt >/etc/authorization/pandavpnunite/log/v2ray_up.log 2>&1

"; 
} | crontab -

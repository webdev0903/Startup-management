#install dependencies
sudo yum install libxslt-devel libxml2 libxml2-devel libxslt zlib-devel  libffi-devel openssl-devel
#Redis
sudo yum instll redis -y
sudo service redis start

#Installing Python 2.7 from source for local user
wget http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz
tar xvfz Python-2.7.3.tgz
cd Python-2.7.3
mkdir ~/.local
./configure --prefix=~/.local
make 
make install
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bash_profile

#exit and start bash again

#install pip
wget https://bootstrap.pypa.io/get-pip.py
python2.7 get-pip.py --user

#install virtualenv
pip install -U virtualenv --user
mkdir /www/starterpad.com/sentry
virtualenv  /www/starterpad.com/sentry
source /www/starterpad.com/sentry/bin/activate
pip install -U sentry
pip install -U sentry[postgres]
sentry init
createdb -U postgres -O postgres sentry # create sentry DB

# Edit Sentry config
# Make sure to add following at the end
# ALLOWED_HOST = ['localhost', 'sentry.starterpad.com', 'starterpad.com']
vi ~/.sentry/sentry.conf.py 

sentry upgrade 
sentry createuser # create admin user

deactivate # deactivate virtualenv
sudo yum install python-setuptools
sudo easy_install supervisor
echo_supervisord_conf > /etc/supervisord.conf

sudo vi /etc/supervisord.conf
		[program:sentry-web]
		directory=/var/www/starterpad.com/sentry/
		command=/var/www/starterpad.com/sentry/bin/sentry --config=/home/starterpad/.sentry/sentry.conf.py start
		autostart=true
		autorestart=true
		redirect_stderr=true
		stdout_logfile syslog
		stderr_logfile syslog

		[program:sentry-worker]
		directory=/var/www/starterpad.com/sentry/
		command=/var/www/starterpad.com/sentry/bin/sentry --config=/home/starterpad/.sentry/sentry.conf.py celery worker -B
		autostart=true
		autorestart=true
		redirect_stderr=true
		stdout_logfile syslog
		stderr_logfile syslog

sudo vi /etc/rc.d/init.d/supervisord
		#!/bin/bash

		. /etc/init.d/functions

		DAEMON=/usr/bin/supervisord
		PIDFILE=/var/run/supervisord.pid

		[ -x "$DAEMON" ] || exit 0

		start() {
		        echo -n "Starting supervisord: "
		        if [ -f $PIDFILE ]; then
		                PID=`cat $PIDFILE`
		                echo supervisord already running: $PID
		                exit 2;
		        else
		                daemon  $DAEMON --pidfile=$PIDFILE -c /etc/supervisord.conf
		                RETVAL=$?
		                echo
		                [ $RETVAL -eq 0 ] && touch /var/lock/subsys/supervisord
		                return $RETVAL
		        fi

		}

		stop() {
		        echo -n "Shutting down supervisord: "
		        echo
		        killproc -p $PIDFILE supervisord
		        echo
		        rm -f /var/lock/subsys/supervisord
		        return 0
		}

		case "$1" in
		    start)
		        start
		        ;;
		    stop)
		        stop
		        ;;
		    status)
		        status supervisord
		        ;;
		    restart)
		        stop
		        start
		        ;;
		    *)
		        echo "Usage:  {start|stop|status|restart}"
		        exit 1
		        ;;
		esac
		exit $?
sudo chmod 755 /etc/rc.d/init.d/supervisord
sudo service supervisord start
sudo supervisorctl status
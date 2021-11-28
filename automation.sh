sudo apt update -y
echo "The package has been updated"
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="mohammed"
s3_bucket="upgrad-mohammed"

pkgs='apache2'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  sudo apt-get install $pkgs -y
fi
echo "Apache 2 check is completed"

apache2_check="$(systemctl status apache2.service | grep Active | awk {'print $3'})"
if [ "${apache2_check}" = "(dead)" ]; then
        systemctl enable apache2.service
        echo "service is enabled"
fi
ServiceStatus="$(systemctl is-active apache2.service)"
if [ "${ServiceStatus}" = "active" ]; then
        echo "Apache2 is already running" 
else
    sudo systemctl start apache2
    echo "Apache2 Service has been started"
fi
echo "Apache2 service check has been comepleted, Service has been started if service was not started"
sudo systemctl status apache2
echo "Apache2 Status Running"

cd /var/log/apache2/
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log
size=$(sudo du -sh /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}')

   
	if [ -e /var/www/html/inventory.html ]
	then
	echo "<br>httpd-logs &nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp; ${size}" >> /var/www/html/inventory.html
	else
	echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp; Date Created &nbsp;&nbsp;&nbsp;&nbsp; Type &nbsp;&nbsp;&nbsp;&nbsp; Size</b><br>" > /var/www/html/inventory.html
	echo "<br>httpd-logs &nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp; ${size}" >> /var/www/html/inventory.html
	fi


aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar 

# check cron file is exist of not, if it is doesn't exist then create it 
# Note:- script will execute once in day at 3.30AM 
if  [ ! -f  /etc/cron.d/automation ]
then
	echo "30 3 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi

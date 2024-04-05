nohup sudo dockerd &
sudo service jenkins start
echo Password `cat /var/lib/jenkins/secrets/initialAdminPassword`
# INSTALL SONARQUBE WITH TERRAFORM


## Create a Bash Script to install Sonarqube
```install_sonarqube.sh```

## ec2.tf
* Set provider
* Created VPC
* Security group and Opened ports 80 & 22
* EC2 Instance
* AMI - Amazon linux 2

* ssh into the ec2 instance
* Copied ```install_sonarqube.sh``` file into the server
* Make bash script file install_sonarqube.sh excutable
* Ran the bash script file
* Ouput the DNS of the instance


## Next Steps

### Configure a Sonar Server locally

```
yum install unzip -y
```

```
adduser sonarqube
```

```
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
```

```
unzip *
```

```
chmod -R 755 /home/sonarqube/sonarqube-9.4.0.54424
```

```
chown -R sonarqube:sonarqube /home/sonarqube/
```

```
sonarqube-9.4.0.54424
```

```
cd sonarqube-9.4.0.54424/bin/linux-x86-64/
```

```
./sonar.sh start
```


Now we can access the `SonarQube Server` on `http://<ip-address>:9000` 

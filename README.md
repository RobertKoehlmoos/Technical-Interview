# Technical-Interview
Run the script using a user with sudo privileges, using the below command  
$ sudo ./gitandhttps.sh  
  
---Running Scripts on the Server---  
Place the script files you want to run in together in a directory.  
The script files will need #!/bin/bash to be by the web server  
To move them onto the webserver run the following commands  
$ git init  
$ git add .  
$ git config user.name "yourNameHere"  
$ git config user.email "your@email.here"  
$ git commit  
$ git remote add origin admin@\<address of server\>:admin  
$ git push --set-upstream origin master  
The push will prompt for a password, enter empiredidnothingwrong  
Then use a browser to go to the server and the it will display the results of the scripts  

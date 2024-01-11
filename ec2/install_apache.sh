 #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<h1>Deployed via terraform</h1>" > /var/www/html/index.html
    echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>terraform sucks</h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' > /var/www/html/index.html
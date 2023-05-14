aws ec2 authorize-security-group-ingress --group-name default --cidr '0.0.0.0/0' --protocol tcp --port 22
aws ec2 authorize-security-group-ingress --group-name default --cidr '0.0.0.0/0' --protocol tcp --port 80
aws ec2 authorize-security-group-ingress --group-name default --cidr '0.0.0.0/0' --protocol tcp --port 443


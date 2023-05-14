aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,SecurityGroups,SubnetId,VpcId,InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress]'

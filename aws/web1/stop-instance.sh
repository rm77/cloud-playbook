INSTANCEID=$1
aws ec2 stop-instances --instance-ids $INSTANCEID
#aws ec2 terminate-instances --instance-ids $INSTANCEID

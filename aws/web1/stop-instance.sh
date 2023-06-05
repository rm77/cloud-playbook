. set.sh

INSTANCEID=$1

if [ -z $INSTANCEID  ]
then
   echo Pilihlah dahulu imageid yang akan dihapus
   aws ec2 describe-instances | jq '.Reservations[].Instances[] | "\(.ImageId) \(.PublicIpAddress)" '
   exit 1
fi

aws ec2 terminate-instances --instance-ids $INSTANCEID

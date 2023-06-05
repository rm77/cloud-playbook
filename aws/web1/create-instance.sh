. set.sh

echo $USERNAME
echo $KEYNAME

aws ec2 run-instances \
	--image-id ami-007855ac798b5175e \
	--count 1 \
	--instance-type t2.micro \
	--key-name $KEYNAME


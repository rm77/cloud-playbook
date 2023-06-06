. set.sh

echo $USERNAME
echo $KEYNAME

aws ec2 run-instances \
	--image-id ami-007855ac798b5175e \
	--count 1 \
	--instance-type t2.micro \
	--key-name $KEYNAME \
	--user-data file:///data/web1/startup-install-script.txt  
	#dengan menggunakan ini, pada waktu startup, vm akan menginstall sesuai dengan script 



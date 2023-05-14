KEYNAME=mykey1
aws ec2 delete-key-pair --key-name $KEYNAME

aws ec2 create-key-pair \
	--key-name $KEYNAME \
	--query 'KeyMaterial' \
	--output text > mykeypair.pem

chmod og-rwx mykeypair.pem

#aws ec2 import-key-pair \
#	--key-name $KEYNAME \
#	--public-key-material file://mykeypair.pub




ssh-keygen -y -f mykeypair.pem > mykeypair.pub


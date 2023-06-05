. set.sh
#aws ec2 delete-key-pair --key-name $KEYNAME


#untuk create key
#ssh-keygen -N "" -f mykeypair.pem -t rsa -m pem


#untuk menghasilkan public key dari privatekeynya
ssh-keygen -y -f mykeypair.pem > mykeypair.pub
#
#
#create dalam format PEM
#ssh-keygen -f ssh-pub -e -m pem > mykeypair.pub

#Untuk create key pair
#aws ec2 create-key-pair \
#	--key-name $KEYNAME \
#	--query 'KeyMaterial' \
#	--output text > mykeypair.pem



chmod og-rwx mykeypair.pem
aws ec2 import-key-pair \
 --key-name $KEYNAME \
 --public-key-material fileb://mykeypair.pub





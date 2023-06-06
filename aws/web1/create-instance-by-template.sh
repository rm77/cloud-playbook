. set.sh

echo $USERNAME
echo $KEYNAME

#https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/launch-instances-from-launch-template.html
#https://docs.aws.amazon.com/autoscaling/ec2/userguide/examples-launch-templates-aws-cli.html
aws ec2 create-launch-template \
	--launch-template-name my-vm-template \
	--version-description version1 \
	--launch-template-data '{"ImageId":"ami-007855ac798b5175e","InstanceType":"t2.micro", "KeyName": "'$KEYNAME'" }'

#run install script
#untuk base64 encode content dari file startup-install-script.txt
#base64 startup-install-script.txt > install_base64.txt
#tidak diperlukan, karena run-instances akan meng-encode otomatis
#akan diperlukan, jika akan mengupdate


aws ec2 run-instances \
    --launch-template LaunchTemplateName=my-vm-template,Version=1 \
    --user-data file://startup-install-script.txt

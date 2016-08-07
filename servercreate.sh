!#/bin/bash -e
AMIDI=$(aws ec2 describe-images --filter "Name=description, Values=Amazon Linux AMI 2015.03.? x86_64 HVM GP2" --query "Images[0].ImageId" --output text)
VPCID=$(aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" --query "Vpcs[0].VpcId" --output text)
SUBNETID=$(aws ec2 describe-subnets --filter "Name=vpc-id, Values=vpc-6a3efa0d" --query "Subnets[0].SubnetId" --output text)
SGID=$(aws ec2 create-security-group --group-name testsecuritygroup --description "This is a security group" --vpc-id $VPCID --output text)
aws ec2 authorize-security-group-ingress --group-id $SGID --protocal tcp --port 22 --cidr 0.0.0.0/0
INSTANCEID=$(aws ec2 run-instances --image-id $AMIID --security-group-ids $SGID subnet-id $SUNBNETID --key-name keyname --instance.type t2.micro --query "Instances[0].InstanceId" --output text)
echo "Waiting for $INSTANCEID"
aws ec2 wait instance-running --instance-ids $INSTANCEID
PUBLICNAME=$(aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservation[0].Instances[0].publicDnsName" --output text)
echo "$INSTANCEID is accepting SSH connections under $PUBLICNAME"
echo "ssh -i keypem.pem ec2-user@$PUBLICNAME"
read -p "Press [Enter] key to terminate $INSTANCEID .."
aws ec2 terminate-instances --instance-ids $INSTANCEID
echo "terminating $INSTANCEID ..."
aws ec2 wait instance-terminated --instance-ids $INSTANCEID
aws ec2 delete-security-group --group-ids $SGID
echo "done"

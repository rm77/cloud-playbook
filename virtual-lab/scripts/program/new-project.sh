fname=.projects.json
part=project

if [ -e $fname ]
then
	current=$(cat $fname)
	b=$(($current+1))
	echo $b > $fname
	current=$(cat $fname)
else
	current=0
	echo $current > $fname
fi


echo create $part $current

mkdir -p $part$current




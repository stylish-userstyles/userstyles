identify_path='/usr/bin/identify'
convert_path='/usr/bin/convert'

echo 'Thumbnailing '$1' at '`date`

if [ ! -x $identify_path ]
then
	echo $identify_path' is not executable'
	exit 1
fi

if [ ! -x $convert_path ]
then
	echo $convert_path' is not executable'
	exit 2
fi

# head is for animated gifs. identify needs to match the server's path
dimensions=`$identify_path $1 | head -1 | cut -d" " -f3`
width=`echo "$dimensions" | cut -dx -f1`
height=`echo "$dimensions" | cut -dx -f2`
echo "width is "$width", height is "$height
if [ $width -gt 350 ]
then
	# convert needs the full path
	echo 'Resizing...'
	$convert_path $1 -resize 350 -colors 256 -quality 80 $2
else
	echo 'No resizing necessary'
	cp $1 $2
fi
echo 'Completed '$1' at '`date`

exit 0

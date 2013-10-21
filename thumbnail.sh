# head is for animated gifs. identify needs to match the server's path
dimensions=`/usr/local/bin/identify $1 | head -1 | cut -d" " -f3`
width=`echo "$dimensions" | cut -dx -f1`
height=`echo "$dimensions" | cut -dx -f2`
echo "width is $width height is $height"
if [ $width -gt 350 ]
then
	# convert needs the full path
	/usr/local/bin/convert $1 -resize 350 -colors 256 -quality 80 $2
else
	cp $1 $2
fi

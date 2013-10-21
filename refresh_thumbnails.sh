thumbnail_script="/home/jason/test/thumbnail.sh"
full_dir="/home/jason/test/full"
thumb_dir="/home/jason/test/thumbnails"

cd $full_dir
for f in *after*
do
	if [ -e "$thumb_dir/$f" ]
	then
		if [ `stat -c %Y $full_dir/$f` -gt `stat -c %Y $thumb_dir/$f` ]
		then
			echo "$f needs update"
			$thumbnail_script $full_dir/$f $thumb_dir/$f
		else
			echo "$f doesn't need update"
		fi
	else
		echo "$f does not exist"
		$thumbnail_script $full_dir/$f $thumb_dir/$f
	fi
done;

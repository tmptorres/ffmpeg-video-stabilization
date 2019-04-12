# Array of filenames
files2Process=( "YDXJ0153.MP4" "YDXJ0166.MP4" )

# First passes
echo "########################## Starting First Passes ###########################"
for fn in ${files2Process[@]}; do
	ffmpeg -i ${fn} -vf vidstabdetect=result="${fn%.*}-transforms.trf" -f null -
done


# Second passes
echo "########################## Starting Second Passes ##########################"
for fn in ${files2Process[@]}; do
	ffmpeg -i ${fn} -vf vidstabtransform=input="${fn%.*}-transforms.trf",unsharp=5:5:0.8:3:3:0.4 "${fn%.*}-vidstab.MP4"
done

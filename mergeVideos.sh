
a="2.7k30p-Onboard-Stabilization.MP4"
b="2.7k30p-Onboard-Stabilization-vidstab.MP4"

ffmpeg -i $a -i $b -filter_complex "hstack,format=yuv420p" -c:v libx264 -crf 18 sideBySideOutput.mp4
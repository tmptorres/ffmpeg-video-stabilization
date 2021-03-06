# Array of filenames
files2Process=( "YN010158.MP4" "YN030158.MP4" "YN040158.MP4" "YDXJ0160.MP4" "YN010160.MP4")

files2Process=( "4k30p-descarrilamento.MP4" )

# First passes
echo "########################## Starting First Passes ###########################"

# Parameters
shakiness=10 			# Set how shaky the video is and how quick the camera is. It accepts an integer in the range 1-10, a value of 1 means little shakiness, a value of 10 means strong shakiness. Default value is 5.
stepsize=4				# Set stepsize of the search process. The region around minimum is scanned with 1 pixel resolution. Default value is 6.
tripod=0				# Set reference frame number for tripod mode. If enabled, the motion of the frames is compared to a reference frame in the filtered stream, identified by the specified number.
						#	The idea is to compensate all movements in a more-or-less static scene and keep the camera view absolutely still.
						# 	If set to 0, it is disabled. The frames are counted starting from 1.

for fn in ${files2Process[@]}; do
	ffmpeg -i ${fn} -vf vidstabdetect=result="${fn%.*}-transforms.trf":shakiness=$shakiness:stepsize=$stepsize:tripod=$tripod -f null -
done


# Second passes
echo "########################## Starting Second Passes ##########################"

# Video Properties
framerate=30			# Video FPS rounded to the nearest integer
# My Parameters
smoothTime=20			# Lowpass cutoff point in seconds

# Parameters
optalgo="gauss"			# Set the camera path optimization algorithm
						#	‘gauss’	: gaussian kernel low-pass filter on camera motion (default)
						#	‘avg’	: averaging on transformations
zoom=0.05				# Set percentage to zoom. A positive value will result in a zoom-in effect, a negative value in a zoom-out effect. Default value is 0 (no zoom).
optzoom=2				# Set optimal zooming to avoid borders.
						#	‘0’	: disabled
						#	‘1’	: optimal static zoom value is determined (only very strong movements will lead to visible borders) (default)
						#	‘2’	: optimal adaptive zoom value is determined (no borders will be visible), see zoomspeed
zoomspeed=0.05			# Set percent to zoom maximally each frame (enabled when optzoom is set to 2). Range is from 0 to 5, default value is 0.25.
interpol="bilinear"		# Specify type of interpolation.
						# 	‘no’		: no interpolation
						# 	‘linear’	: linear only horizontal
						# 	‘bilinear’	: linear in both directions (default)
						#	‘bicubic’	: cubic in both directions (slow)

# Exotic parameters
maxshift=-1				# Set maximal number of pixels to translate frames. Default value is -1, meaning no limit
maxangle=-1				# Set maximal angle in radians (degree*PI/180) to rotate frames. Default value is -1, meaning no limit
crop="keep"				# Specify how to deal with borders that may be visible due to movement compensation.
						# 	‘keep’	: keep image information from previous frame (default)
						#	‘black’	: fill the border black
invert=0				# Invert transforms if set to 1. Default value is 0.
relative=0				# Consider transforms as relative to previous frame if set to 1, absolute if set to 0. Default value is 0.
tripod=0				# Enable virtual tripod mode if set to 1, which is equivalent to relative=0:smoothing=0. Default value is 0. Use also tripod option of vidstabdetect.


# Computations
declare -i smoothing	# Set the number of frames (value*2 + 1) used for lowpass filtering the camera movements. Default value is 10.
						#	For example a number of 10 means that 21 frames are used (10 in the past and 10 in the future) to smoothen the motion in the video.
						#	A larger value leads to a smoother video, but limits the acceleration of the camera (pan/tilt movements).
						#	0 is a special case where a static camera is simulated.
(( smoothing = framerate * smoothTime ))


for fn in ${files2Process[@]}; do
	ffmpeg -i ${fn} -vf vidstabtransform=input="${fn%.*}-transforms.trf":smoothing=$smoothing:optalgo=$optalgo:zoom=$zoom:optzoom=$optzoom:zoomspeed=$zoomspeed:interpol=$interpol:maxshift=$maxshift:maxangle=$maxangle:crop=$crop:invert=$invert:relative=$relative:tripod=$tripod,unsharp=5:5:0.8:3:3:0.4 "${fn%.*}-vidstab.MP4"
done

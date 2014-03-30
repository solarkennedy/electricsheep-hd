#!/bin/bash
#
#

NFRAMES=20
W=100
H=100
FPS=30

sed "s/WIDTH/$W//" animated.template | sed "s/HIEGHT/$H//" > anim_template.flame

for flame in genomes/*.flam3; do

  ID=`basename $flame | sed 's/.flam3//'`
  if [[ -f movies/$ID.avi ]] ; then
    echo "Movie for $ID exists already. Skipping."
    continue
  fi

  # Create a new flame file with enough frames to loop
  mkdir animated_genomes 2>/dev/null
  env template=anim_template.flame sequence=$flame nframes=$NFRAMES flam3-genome  > animated_genomes/$ID.flame

  # Make stills out of the animated flame file
  mkdir -p frames/$ID/ 2>/dev/null
  env in=animated_genomes/$ID.flame prefix=frames/$ID/ format=jpg jpeg=95 flam3-animate

  # Concat the jpegs into a mjpeg
  mkdir movies 2>/dev/null
  mencoder mf://frames/$ID/*.jpg -mf w=$W:h=$H:fps=$FPS:type=jpg -ovc copy -oac copy -o movies/$ID.avi

done

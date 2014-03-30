#!/bin/bash
#
#

NFRAMES=120
W=2880
H=1800
FPS=30
FLAME=""

mkdir movies 2>/dev/null
mkdir animated_genomes 2>/dev/null
echo "#EXTM3U" > playlist.m3u

sed "s/WIDTH/$W/" animated.template | sed "s/HEIGHT/$H/" > anim_template.flame

for FLAME in genomes/*.flam3; do

  ID=`basename $FLAME | sed 's/.flam3//'`

  if [[ $OLD_FLAME == "" ]]; then
    echo Skipping because I dont know what my old_flame was
    OLD_FLAME=$FLAME
    OLD_ID=$ID
    continue
  fi

  # Merge old and new flames into a single file to make the animation from
  echo '<flames name="Batch">' > tmp.flame
  cat $OLD_FLAME $FLAME  >> tmp.flame
  echo '</flames>' >> tmp.flame

  # Create a new flame file with enough frames to loop
  env template=anim_template.flame sequence=tmp.flame nframes=$NFRAMES flam3-genome  > animated_genomes/${OLD_ID}_${ID}.flame

  if  ! [[ -f movies/$OLD_ID.avi ]] ; then
    # Make stills out of the animated flame file, first the first part of the animation
    mkdir -p frames/${OLD_ID}/ 2>/dev/null
    let END=$NFRAMES-1
    env in=animated_genomes/${OLD_ID}_${ID}.flame prefix=frames/$OLD_ID/ format=jpg jpeg=95 begin=0 end=$END flam3-animate
    mencoder mf://frames/$OLD_ID/*.jpg -mf w=$W:h=$H:fps=$FPS:type=jpg -ovc copy -oac copy -o movies/$OLD_ID.avi
    echo "movies/$OLD_ID.avi" >> playlist.m3u
    echo "movies/$OLD_ID.avi" >> playlist.m3u
    echo "movies/$OLD_ID.avi" >> playlist.m3u
  fi

  if ! [[ -f movies/${OLD_ID}_${ID}.avi ]]; then
    # Now make the transition part
    mkdir -p frames/${OLD_ID}_${ID}/ 2>/dev/null
    let END=$NFRAMES*2
    env in=animated_genomes/${OLD_ID}_${ID}.flame prefix=frames/${OLD_ID}_${ID}/ format=jpg jpeg=95 begin=$NFRAMES end=$END flam3-animate
    mencoder mf://frames/${OLD_ID}_${ID}/*.jpg -mf w=$W:h=$H:fps=$FPS:type=jpg -ovc copy -oac copy -o movies/${OLD_ID}_${ID}.avi
    echo "movies/${OLD_ID}_${ID}.avi" >> playlist.m3u
  fi

  # Skip making the second part because it becomes the next first part on the subsequent loop
  # Yes, this means we never make the last file. We also don't get the first file. Eh

  OLD_FLAME=$FLAME
  OLD_ID=$ID

done

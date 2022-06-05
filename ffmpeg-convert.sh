#!/bin/sh

set -eu

PROCESSED_DIR="${PROCESSED_DIR:-Processed}"

processed_name() {
    echo "$PROCESSED_DIR/$(basename "${1%.*}").mov"
}

ffmpeg_process() {
    div=65

    ffmpeg -i "$1" -frames:v 1500 -y -filter_complex "
    [0:0]crop=128:1344:x=624:y=0,format=yuvj420p,
    geq=
    lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    interpolation=b,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[crop],
    [0:0]crop=624:1344:x=0:y=0,format=yuvj420p[left], 
    [0:0]crop=624:1344:x=752:y=0,format=yuvj420p[right], 
    [left][crop]hstack[leftAll], 
    [leftAll][right]hstack[leftDone],

    [0:0]crop=1344:1344:1376:0[middle],

    [0:0]crop=128:1344:x=3344:y=0,format=yuvj420p,
    geq=
    lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    interpolation=b,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[cropRightBottom],
    [0:0]crop=624:1344:x=2720:y=0,format=yuvj420p[leftRightBottom], 
    [0:0]crop=624:1344:x=3472:y=0,format=yuvj420p[rightRightBottom], 
    [leftRightBottom][cropRightBottom]hstack[rightAll], 
    [rightAll][rightRightBottom]hstack[rightBottomDone],
    [leftDone][middle]hstack[leftMiddle],
    [leftMiddle][rightBottomDone]hstack[bottomComplete],

    [0:5]crop=128:1344:x=624:y=0,format=yuvj420p,
    geq=
    lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    interpolation=n,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[leftTopCrop],
    [0:5]crop=624:1344:x=0:y=0,format=yuvj420p[firstLeftTop], 
    [0:5]crop=624:1344:x=752:y=0,format=yuvj420p[firstRightTop], 
    [firstLeftTop][leftTopCrop]hstack[topLeftHalf], 
    [topLeftHalf][firstRightTop]hstack[topLeftDone],

    [0:5]crop=1344:1344:1376:0[TopMiddle],

    [0:5]crop=128:1344:x=3344:y=0,format=yuvj420p,
    geq=
    lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/"$div"))+(p(X,Y)*(("$div"-((X+1)))/"$div")), p(X,Y))':
    interpolation=n,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[TopcropRightBottom],
    [0:5]crop=624:1344:x=2720:y=0,format=yuvj420p[TopleftRightBottom], 
    [0:5]crop=624:1344:x=3472:y=0,format=yuvj420p[ToprightRightBottom], 
    [TopleftRightBottom][TopcropRightBottom]hstack[ToprightAll], 
    [ToprightAll][ToprightRightBottom]hstack[ToprightBottomDone],
    [topLeftDone][TopMiddle]hstack[TopleftMiddle],
    [TopleftMiddle][ToprightBottomDone]hstack[topComplete],

    [bottomComplete][topComplete]vstack[complete], [complete]v360=eac:e:interp=cubic[v]" \
    -map "[v]" -map "0:a:0"  -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le -f mov \
    "$(processed_name "$1")"
}

exif_process() {
    exiftool -api LargeFileSupport=1 -overwrite_original \
    -XMP-GSpherical:Spherical="true" -XMP-GSpherical:Stitched="true" \
    -XMP-GSpherical:StitchingSoftware=dummy \
    -XMP-GSpherical:ProjectionType=equirectangular \
    "$(processed_name "$1")"
}

process() {
    ffmpeg_process "$1"
    exif_process "$1"
    echo "File processed: $(processed_name "$1")"
}

batch_process() {
    mkdir -p "$PROCESSED_DIR"
    for f in "$1"/*.360; do
        process "$f"
    done
}

if [ $# -gt 0 ]; then
    if [ -f "$1" ] && [ "${1##*.}" == "360" ]; then
        mkdir -p "$PROCESSED_DIR"
        process "$1"
        exit
    fi
    if [ -d "$1" ]; then
        batch_process "$1"
    fi
else
    batch_process "$PWD"
fi

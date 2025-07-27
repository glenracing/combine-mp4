# combine-mp4

Automatically combine mp4 videos into a single file with title overlays using ffmpeg.

```
Usage: combine_mp4.sh <titles file> <output> [inputs...]

<titles file> is a text file where the first and second lines contain
the main title and subtitle, respectively, and subsequent lines
contain the titles for each video in the order they will be passed to
this script.

If the main title and subtitle are both blank, the main title will not
be generated. If any of the other lines are blank, a title will not be
generated for the corresponding video.

```

Create a `titles.txt` file to pass to the script. For example, to combine four videos (and skip creating a title for video 3):

```
Main title goes here.
Subtitle goes here.
Video 1 Title
Video 2 Title

Video 4 Title
```

Then call the script:

```
$ ./combine_mp4.sh titles.txt output.mp4 video1.mp4 video2.mp4 video3.mp4 video4.mp4
```

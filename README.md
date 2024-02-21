# modsrt - Modify an SRT file

This is a simple utility to modify an SRT file.

## Background

Why would you want or need to modify an SRT file? Well, imagine if you have an audio or video file, and an accompanying SRT file containing auto-generated captions. But you need to cut some of the audio or video file, so that what you eventually want to publish starts at some point "into" the interview or demo or whatever it is. Which then means that the timestamp ranges in the accompanying SRT file are out by a fixed amount of time.

In addition, if you cut out some of the start of your audio or video file, say, to remove some pre-interview chat, then you will want to cut out some of the SRT records. But the SRT records are numbered. So basically, if you edit your audio or video file, you'll also need to make sure that whatever the new first record is, it is numbered 1, and the subsequent ones are numbered sequentially after that.

## Modifications possible

After editing your SRT file to remove some of the initial records so that the captions line up with the the final audio or video file, you can then use this utility to:

- add (or subtract) a fixed amount of time from each of the timestamp ranges
- ensure that the SRT records are (re)numbered starting from 1

## SRT file format basics

Here's a small SRT example file ([demo-original.srt](./demo-original.srt)) containing 4 records. Each record consists of three lines, and there's a blank line separating each record.

Each record consists of three values, one on each of the three lines:

- a sequential record number
- a timestamp range
- the caption text for that range

```text
1
00:00:01,366 --> 00:00:05,366
Did you know ...

2
00:00:05,366 --> 00:00:09,366
about Luigi? It is an enterprise-ready micro frontend framework from SAP.

3
00:00:09,366 --> 00:00:13,366
Here you can see the micro frontend framework in action.

4
00:00:13,366 --> 00:00:17,366
This Luigi app can host different frontend
```

## Adjusting an SRT file - an example

You can see in the example SRT file that the talking starts ("_Did you know ..._") about 1 second into the video (at `00:00:01,366`). But what if we wanted to cut the video so it starts with the demo i.e. where the narrator says "_Here you can see the micro frontend framework in action._", in record 3. This would mean we would want to edit the SRT file to delete the first two records, so it ends up looking like this ([demo-adjusted.srt](./demo-adjusted.srt)):

```text
3
00:00:09,366 --> 00:00:13,366
Here you can see the micro frontend framework in action.

4
00:00:13,366 --> 00:00:17,366
This Luigi app can host different frontend
```

So now we have a video that we have cut so that it starts with "_Here you can see ..._", and have adjusted the records in the SRT file to reflect that. 

But we have two more issues to solve:

- now all the timestamp ranges are out by 9 seconds
- the record numbering now starts at 3, not 1

With this utility, both these issues can be addressed.

Running this utility as follows:


```shell
./entrypoint -9 demo.srt
```

produces the following output:

```text
1
00:00:00,366 --> 00:00:04,366
Here you can see the micro frontend framework in action.

2
00:00:04,366 --> 00:00:08,366
This Luigi app can host different frontend

```

The record numbering has been adjusted now to start from 1, and the timestamp ranges have all been set back by 9 seconds.

## Usage

You can clone this repo and use it as follows:

```shell
./entrypoint <seconds> <filename>
```

You can also run it without having to clone or install anything, as a single-shot Docker container, like this (working on the same `demo-adjusted.srt` example file from earlier, here assuming that it's in `/Users/dj/work/scratch/`):

```shell
docker run --rm -v /Users/dj/work/scratch/:/tmp/ -9 /tmp/demo-adjusted.srt
```

> As shown in this example, you'll need to bind mount the directory containing your SRT file, and specify the full path to it as appropriate.

This will produce the following output:

```text
1
00:00:00,366 --> 00:00:04,366
Here you can see the micro frontend framework in action.

2
00:00:04,366 --> 00:00:08,366
This Luigi app can host different frontend

```

## Notes

The timestamps are in this format: `HH:MM:SS,SSS`; the `SSS` part is ignored and not adjusted, the adjustment is only in whole seconds.

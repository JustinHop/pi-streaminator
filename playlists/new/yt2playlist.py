#!/usr/bin/python3
# coding: utf-8

from __future__ import unicode_literals, print_function
import youtube_dl
import yaml
import sys

import datetime
from pprint import pprint

today = datetime.datetime.now()
yesterday = datetime.datetime.now() + datetime.timedelta(days=-2)

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

class MyLogger(object):
    def debug(self, msg):
        eprint(msg)
        pass

    def warning(self, msg):
        eprint(msg)
        pass

    def error(self, msg):
        eprint(msg)
        pass

def my_hook(d):
    if d['status'] == 'finished':
        print('Done downloading, now converting ...')

ydl_opts = {
    'cachedir': './cache',
    'daterange': youtube_dl.utils.DateRange(start=yesterday.strftime('%Y%m%d'), end=today.strftime('%Y%m%d')),
    'format': 'bestaudio/best',
    'verbose': True,
    'skip_download': True,
    # 'simulate': True,
    'logger': MyLogger(),
    'progress_hooks': [my_hook],
    'ignoreerrors': True,
    # 'playlistend': 5,
}
with youtube_dl.YoutubeDL(ydl_opts) as ydl:
    # ydl.download(['https://www.youtube.com/user/Superhand1981'])
    yy = ydl.extract_info('https://www.youtube.com/user/Superhand1981', download=True)
    # print(yaml.safe_dump(yy))
    pprint(yy)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''subs.py
Usage: subs.py [options]

Options:
    -D --debug          Debugging output
    -q --quiet          Quiet output
    -h --help           Help!
    -l --loops=LOOPS    Maximum Loops [default: 10]
    -s --sleep=SLEEP    Sleep wait between loops [default: 30]
    -x --xml            Generate subscriptions.xml format
    -o --output=FILE    Output to file
    -y --youtube        Parse youtube [default: false]
    -b --bitchute       Parse bitchute [default: false]
'''

import time
import os
import re

from docopt import docopt
conf = docopt(__doc__)

import logging

l_level = logging.INFO

if conf['--debug']:
    l_level = logging.DEBUG
elif conf['--quiet']:
    l_level = logging.ERROR

logging.basicConfig(
    level=l_level,
    format='%(asctime)s - %(levelname)s - %(pathname)s - %(funcName)s - %(message)s')

from selenium import webdriver
from selenium.webdriver.common.by import By


url = "https://www.youtube.com/feed/channels"
burl = "https://www.bitchute.com/subscriptions/"

js = '''var scrollInterval = setInterval(function() {
    document.documentElement.scrollTop = document.documentElement.scrollHeight;
}, 1000);'''

js2 = '''var channel_links = document.getElementsByClassName("channel-link");
var ret = []; for (var f of channel_links) { ret.push(f.href) }; return ret;'''

bjs2 = '''var channel_links = document.getElementsByClassName("spa");
var ret = []; for (var f of channel_links) { let s = f.getAttribute("rel");
if (s === "author") { ret.push(f.href) } }; return ret; '''

bjs = '''var links = document.getElementsByClassName("spa");
var channel_links = links.getElementsByTagName("a");
var ret = []; for (var f of channel_links) { ret.push(f.href) }; return ret;'''

def youtube():
    loop_limit = int(conf['--loops'])
    sleep_limit = int(conf['--sleep'])

    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--user-data-dir=/home/chrome/.config/chromium")
    driver = webdriver.Chrome('/usr/bin/chromedriver', chrome_options=options)

    driver.get(url)

    time.sleep(sleep_limit)

    logging.debug("executing scroller js")
    driver.execute_script(js)

    loop_count = 0
    links = []
    links_prev = []

    while True:
        loop_count = loop_count + 1
        logging.info(["Loop count", loop_count])
        if loop_count > loop_limit:
            break
        links_prev = links.copy()
        links = []

        logging.debug(["Sleeping", sleep_limit])
        time.sleep(sleep_limit)
        # for a in driver.find_elements_by_tag_name('a'):
        for href in driver.execute_script(js2):
            if href:
                if href not in links:
                    links.append(href)
                    logging.debug(href)

        logging.info(["links length", len(links)])
        logging.info(["pinks length", len(links_prev)])

        if loop_count > 0 and len(links) == len(links_prev):
            logging.debug("No more new links")
            break

    logging.info(["Channels Found", len(links)])

    for l in sorted(links):
        ll = re.sub(r'com/(channel|user)/(\S+)$',
                    r'com/feeds/videos.xml?\1=\2', l)
        if re.search(r'videos\.xml', ll):
            logging.debug(["Found", l, ll])
            print(ll)

    driver.quit()

def bitchute():
    sleep_limit = int(conf['--sleep'])

    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--user-data-dir=/home/chrome/.config/chromium")
    driver = webdriver.Chrome('/usr/bin/chromedriver', chrome_options=options)

    driver.get(burl)

    time.sleep(sleep_limit)

    links = []
    links_prev = []

    b = "https://www.bitchute.com/feeds/rss"
    # for href in driver.execute_script(bjs):
    for a in driver.find_elements_by_tag_name('a'):
        logging.debug(["A", a])
        try:
            href = a.get_attribute("href")
            if href:
                if href not in links:
                    logging.debug(["HREF", href])
                    links.append(href)
        except BaseException as x:
            logging.debug(x)

    for l in sorted(links):
        ll = re.sub(r'com/(channel/(\S+))$',
                    r'com/feeds/rss/\1', l)
        if re.search(r'channel', ll):
            logging.debug(["Found", l, ll])
            print(ll)

    driver.quit()

def main():
    logging.info(conf)

    if conf['--youtube']:
        youtube()

    if conf['--bitchute']:
        bitchute()


if __name__ == "__main__":
    main()

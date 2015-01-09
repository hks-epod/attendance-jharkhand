# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class AttendanceScrapyItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    name = scrapy.Field()
    position = scrapy.Field()
    unit = scrapy.Field()
    location = scrapy.Field()
    sublocation = scrapy.Field()
    organization = scrapy.Field()
    month = scrapy.Field()
    year = scrapy.Field()
    sno = scrapy.Field()
    date = scrapy.Field()
    status = scrapy.Field()
    in_time = scrapy.Field()
    out_time = scrapy.Field()
    in_time_short_fall = scrapy.Field()
    out_time_short_fall = scrapy.Field()
    short_fall = scrapy.Field()
    duration = scrapy.Field()
    over_time = scrapy.Field()
    total_short_fall = scrapy.Field()
    url = scrapy.Field()
    pass

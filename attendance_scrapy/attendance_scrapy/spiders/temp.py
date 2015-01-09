from scrapy.spider import Spider
from attendance_scrapy.items import AttendanceScrapyItem
from bs4 import BeautifulSoup
import csv
import os
import datetime

class MySpider(Spider):
    name = "attendance"
    start_urls = list()
    # output_dir = '/Users/Eric/Desktop/Data/Attendance/attendance_scrapy'
    output_dir = os.getcwd()
    print output_dir
    # os.path.abspath(os.path.join(yourpath, os.pardir))
    url_file = output_dir+'/links.csv'

    months = dict()
    years = [str(i) for i in range(2014,int(datetime.date.today().strftime("%Y"))+1)]

    for year in years:
        months[year]=list()
        if int(year)<int(datetime.date.today().strftime("%Y")):
            months[year] = [str(i) for i in range(1,13)]
        else:
            months[year] = [str(i) for i in range(1,int(datetime.date.today().strftime("%m"))+1)]

    start_urls = []
    
    for year in years:
        for month in months[year]:
            start_urls = start_urls + [l.strip().replace('&Month=10','&Month='+month).replace('&Year=2014','&Year='+year) for l in open(url_file).readlines()]

    def parse(self, response):

        soup = BeautifulSoup(response.body_as_unicode())
        url = response.url
        url = url.replace('%20',' ').strip()

        month = url.split('&Month=')[1].split('&')[0]
        year = url.split('&Year=')[1].split('&')[0]
        unit = url.split('&UnitName=')[1].split('&')[0]
        location = url.split('&LocationName=')[1].split('&')[0]
        sublocation = url.split('&Block=')[1].split('&')[0]
        org = url.split('&OrganizationName=')[1].split('&')[0]

        items = []
        div = soup.find("div",{"id":"ContentPlaceHolder1_Panel1"})
        tables = div.find_all("table")
        if len(tables)==0:
            item = AttendanceScrapyItem()
            data = ['','',unit,location,sublocation,org,month,year] + ['' for x in range(11)] + [url]
            item["name"] = data[0]
            item["position"] = data[1]
            item["unit"] = data[2]
            item["location"] = data[3]
            item["sublocation"] = data[4]
            item["organization"] = data[5]
            item["month"] = data[6]
            item["year"] = data[7]
            item["sno"] = data[8]
            item["date"] = data[9]
            item["status"] = data[10]
            item["in_time"] = data[11]
            item["out_time"] = data[12]
            item["in_time_short_fall"] = data[13]
            item["out_time_short_fall"] = data[14]
            item["short_fall"] = data[15]
            item["duration"] = data[16]
            item["over_time"] = data[17]
            item["total_short_fall"] = data[18]
            item["url"] = data[19]
            items.append(item)
        for table_num,table in enumerate(tables):
            if table_num%2==0:
                name = table.find_all('tr')[0].find_all('td')[1].text.encode('utf-8')
                position = table.find_all('tr')[0].find_all('td')[2].text.encode('utf-8')
            else:
                rows = table.find_all('tr')[1:]
                for row in rows:
                    item = AttendanceScrapyItem()
                    data = [name,position,unit,location,sublocation,org,month,year] + [col.text.encode('utf-8') for col in row.find_all('td')] + [url]
                    item["name"] = data[0]
                    item["position"] = data[1]
                    item["unit"] = data[2]
                    item["location"] = data[3]
                    item["sublocation"] = data[4]
                    item["organization"] = data[5]
                    item["month"] = data[6]
                    item["year"] = data[7]
                    item["sno"] = data[8]
                    item["date"] = data[9]
                    item["status"] = data[10]
                    item["in_time"] = data[11]
                    item["out_time"] = data[12]
                    item["in_time_short_fall"] = data[13]
                    item["out_time_short_fall"] = data[14]
                    item["short_fall"] = data[15]
                    item["duration"] = data[16]
                    item["over_time"] = data[17]
                    item["total_short_fall"] = data[18]
                    item["url"] = data[19]
                    items.append(item)
        return items

        # print soup.findAll(['title'])
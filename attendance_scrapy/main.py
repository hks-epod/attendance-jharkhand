from twisted.internet import reactor
from scrapy.crawler import Crawler
from scrapy import log, signals
from attendance_scrapy.spiders.temp import MySpider
from scrapy.utils.project import get_project_settings

spider = MySpider()
settings = get_project_settings()
crawler = Crawler(settings)
crawler.signals.connect(reactor.stop, signal=signals.spider_closed)
crawler.configure()
crawler.crawl(spider)
crawler.start()
log.start()
reactor.run() # the script will block here until the spider_closed signal was sent
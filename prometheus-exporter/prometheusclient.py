import time
import json
import os
import shutil
from prometheus_client.core import GaugeMetricFamily, REGISTRY, CounterMetricFamily
from prometheus_client import start_http_server

class Reader:
 
    def read(self, name):
        inputFile = open(name)
        contents = inputFile.read()
        inputFile.close()
        return contents

class Parser:

    def parse(self, conf, fio_output):

        fio = json.loads(fio_output)

        metrics = list()
        for line in conf.splitlines():
            if not line.startswith("#"):
                values = line.split(",")

                metric = values[0].split('/')
                if len(metric) == 5: 
                    mvalue = fio[metric[0]][0][metric[1]][metric[2]][metric[3]][metric[4]]
                elif len(metric) == 4:       
                    mvalue = fio[metric[0]][0][metric[1]][metric[2]][metric[3]]
                elif len(metric) == 3:       
                    mvalue = fio[metric[0]][0][metric[1]][metric[2]]
                elif len(metric) == 2:       
                    mvalue = fio[metric[0]][0][metric[1]]

                metrics.append({
                "metric": values[0],
                "help": values[1],
                "name": values[2],
                "type": values[3],
                "unit": values[4],
                "category": metric[1],
                "value": mvalue
                })
        
        return metrics

class CustomCollector(object):
    def __init__(self,m):
        self.metrics = m
        # suppress built-in metrics
        for coll in list(REGISTRY._collector_to_names.keys()):
            REGISTRY.unregister(coll)

    def collect(self):
        for item in self.metrics:
            PREFIX = "fio_" + item['category'] + "_"
            baseValue = convert_to_base(item['value'], item['unit'])
            yield GaugeMetricFamily(PREFIX + item['name'], item['help'], baseValue)

def convert_to_base(value, unit):
    if unit == "b":
        baseValue = value
    elif unit == "n":
        baseValue = value / 1000000000
    elif unit == "u":
        baseValue = value / 1000000
    elif unit == "m":
        baseValue = value / 1000
    elif unit == "K":
        baseValue = value * 1000
    elif unit == "M":
        baseValue = value * 1000000
    elif unit == "G":
        baseValue = value * 1000000000
    elif unit == "T":
        baseValue = value * 1000000000000
    return baseValue

def watchfile(filename):
    now = time.time()
    if os.path.exists(filename) and now - os.stat(filename).st_mtime < check_interval: 
        time.sleep(5)
        return True
    else:
        return False
   
def gettime():
    t = time.localtime()
    current_time = time.strftime("%H:%M:%S", t)
    return current_time

if __name__ == '__main__':

    workdir = "/exporter/"
    config  = workdir + "config/fio-metrics.conf"
    datadir = "/tmp/data"
    os.mkdir(datadir)
    fio_output = datadir + "/fio-results.json"
    check_interval = 60

    start_http_server(8000)
    print("HTTP server started. Listening on port 8000.")

    # Wait for the FIO output
    curtime = gettime()
    print(curtime + ": " + "Wait for FIO output.")

    while True:
        if watchfile(fio_output) == True:
            curtime = gettime()
            print(curtime + ": " + "FIO output received. Processing ...")  

            r = Reader()
            conf = r.read(config)
            fio = r.read(fio_output)
 
            p = Parser()
            metrics = p.parse(conf, fio)
   
            REGISTRY.register(CustomCollector(metrics))
            curtime = gettime()
            print(curtime + ": " + "FIO metrics exposed for scraping. ")  
            print(curtime + ": " + "Wait for FIO output.")
            time.sleep(check_interval) 
        else:
            time.sleep(10)

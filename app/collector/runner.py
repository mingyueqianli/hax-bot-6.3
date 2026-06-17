import time
from app.collector.hax import fetch

def get_interval():
    try:
        return int(open("interval.txt").read().strip())
    except:
        return 30

def run():
    while True:
        data = fetch()
        with open("data/test.txt","w",encoding="utf-8") as f:
            f.writelines(data)
        time.sleep(get_interval())

if __name__ == "__main__":
    run()

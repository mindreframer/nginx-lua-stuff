#-*-coding: utf-8 -*-
# sudo pip install requests
import requests
#import json
#import random
#import md5


apps = {'appid', 'default'}
types = {'key', 'keys'}

host = "http://localhost:8080"


def Test_del():
    form = {"keys", "google"}
    uri = "/default/keys/google/del"
    r = requests.post(host + uri, data=form)
    assert r.status_code == 200


def Test_set():
    form = {'value': 'www.google.com'}
    r = requests.post('http://localhost:8080/default/key/google/set', data=form)
    assert r.status_code == 200

if __name__ == "__main__":
    Test_set()

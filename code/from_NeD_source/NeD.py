import django
#from django.http import HttpResponse
#from django.shortcuts import render_to_response
#from django import forms
import os

try:
	from PIL import Image
except:
	import Image

import mysite.settings

import mysite.urls
import webbrowser, time, sys, os, csv
import mysite.views

	
from random import sample, shuffle
from os import listdir, getcwd, remove
from numpy import mean, std,array,sqrt,dot
from time import sleep, time, strftime, gmtime
from os.path import getmtime
from django.core.servers.basehttp import run
from django.core.handlers.wsgi import WSGIHandler
import htmlentitydefs
import HTMLParser
import Cookie


if __name__ == "__main__":
    os.environ['DJANGO_SETTINGS_MODULE'] = 'mysite.settings'
    port = 8000
    out = sys.stdout
     
    from django.conf import settings
    try:
        
 
        webbrowser.open('http://localhost:%s' % port)
        run('localhost', port,WSGIHandler())
    except:
		pass

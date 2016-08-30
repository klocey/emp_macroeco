from distutils.core import setup
import htmlentitydefs
import py2exe
 
setup(windows=[{'script':'NeD.py'}],
      data_files = [('static', ['mysite\static\django.gif','mysite\static\style.css']),
                    ('static\graphics',[]),
                    'mysite\\404.html',
                    'mysite\\500.html',
                    'mysite\\contacts.html',
                    'mysite\\doc.html',
                    'mysite\\download.html',
                    'mysite\\index.html',
                    'mysite\\no_input.html',
                    'mysite\\out.html',
                    'mysite\\out_batch.html'],
         options={'py2exe':{
							'excludes' : ['django.bin',
										  'django.core.cache'
										  
										  ],
							'includes':[
									'mysite.views',
									'django.core',
									'django.conf',
									'django.contrib',
									'django.utils',
									'django.middleware.csrf',
									'django.middleware.common',
									'django.db.backends.dummy.base',
									'django.core.mail.backends.smtp',
									'django.views.defaults',
									'django.core.cache',
									'django.core.cache.backends.locmem',
									'django.template.loaders.filesystem',
									'django.template.defaulttags',
									'django.template.defaultfilters',
									'django.template.loader_tags',
									'django.template.loaders.app_directories',
									'django.contrib.messages',
									'django.core.context_processors',
									'django.contrib.messages.context_processors',
									'django.contrib.auth.context_processors',
									'django.views',
									
									'email']
							}
				}
	)

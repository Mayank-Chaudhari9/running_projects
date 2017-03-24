from django.conf.urls import url

from . import views

urlpatterns =[
		
		url(r'^$',views.index, name='index'),
		url(r'^test/$',views.test, name='test'),
		url(r'^profile/$', views.profile, name='profile'),
		url(r'^pest_capture/$', views.pest_capture, name='pest_capture'),
		url(r'^pest_detector/$', views.pest_detector, name='pest_detector'),
		#url(r'^google/$', views.redirect, name='redirect'),

	]
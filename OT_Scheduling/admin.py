from django.contrib import admin
from .models import CustomUser, Doctors, OTs, Patients, Procedures, Scheduled_Surgeries, Monitoring, OTstaff # Import your models

admin.site.register(CustomUser) 
admin.site.register(Doctors) 
admin.site.register(OTs) 
admin.site.register(Patients) 
admin.site.register(Procedures) 
admin.site.register(Scheduled_Surgeries) 
admin.site.register(Monitoring) 
admin.site.register(OTstaff)

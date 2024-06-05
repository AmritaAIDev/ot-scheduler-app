from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, name=None, user_type=None,**extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        if None in (name, user_type):
            raise ValueError('Name and User Type are required')

        email = self.normalize_email(email)
        user = self.model(email=email, name=name,
            user_type=user_type,
            **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None,name=None, user_type=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, name=name,
            user_type=user_type,
            **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    name = models.CharField(max_length=255)
    user_type = models.CharField(max_length=15) 

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['name', 'user_type']

    objects = CustomUserManager()

    def __str__(self):
        return self.email


class Doctors(models.Model):
    doctor_id = models.AutoField(primary_key = True)
    doctor_name = models.CharField(max_length=1000,null=True, blank=True)
    department = models.CharField(max_length=50,null=True, blank=True)

class OTs(models.Model):
    ot_id = models.AutoField(primary_key = True)
    ot_number = models.CharField(max_length = 50,null=True,blank=True)
    department = models.CharField(max_length=50,null=True,blank=True)

    #class Meta:
        #unique_together = ('ot_number', 'department')  # Ensuring uniqueness across these fields

class Patients(models.Model):
    patient_id = models.AutoField(primary_key=True)
    patient_name = models.CharField(max_length=50)
    age = models.IntegerField(null=True, blank=True)
    mrd = models.IntegerField(null=True, blank=True)
    gender = models.CharField(max_length=50)
    registration_date = models.DateField(null=True, blank=True)

class Procedures(models.Model):
    procedure_id = models.AutoField(primary_key=True)
    procedure_name = models.TextField(null=True, blank=True)
    department = models.CharField(max_length=50)
    estimated_duration = models.FloatField(null=True, blank=True)

## For OT Staff

class OTstaff(models.Model):
    ot_staff_id = models.AutoField(primary_key=True)
    ot_staff_employee_id = models.CharField(max_length=1000,null=True,blank=True)
    ot_staff_name = models.CharField(max_length=1000,null=True,blank=True)
    ot_staff_department = models.CharField(max_length=1000,null=True,blank=True)
    ot_staff_designation = models.CharField(max_length=1000,null=True,blank=True)

class Scheduled_Surgeries(models.Model):
    scheduled_surgery_id = models.AutoField(primary_key=True)
    patient_name = models.CharField(max_length=1000, null=True, blank=True)
    mrd = models.CharField(max_length=1000, null=True, blank=True)
    doctor_name = models.CharField(max_length=1000, null=True, blank=True)
    department = models.CharField(max_length=1000, null=True, blank=True)
    ot_number = models.CharField(max_length=1000, null=True, blank=True)
    procedure_name = models.CharField(max_length=1000, null=True, blank=True)

    patient_id = models.ForeignKey(Patients,on_delete = models.CASCADE,null=True, blank=True)
    doctor_id = models.ForeignKey(Doctors,on_delete=models.CASCADE,null=True, blank=True)
    ot_id = models.ForeignKey(OTs,on_delete=models.CASCADE,null=True, blank=True)
    procedure_id = models.ForeignKey(Procedures,on_delete=models.CASCADE,null=True, blank=True)

    user_id = models.ForeignKey(CustomUser,on_delete=models.CASCADE,null=True, blank=True)
    surgery_date = models.DateField(null=True, blank=True)
    surgery_start_time = models.TimeField(null=True, blank=True)
    surgery_end_time = models.TimeField(null=True, blank=True)
    status = models.CharField(max_length=50,null=True, blank=True)
    # for emergency, add on, or preplanned
    #surgery_type = models.CharField(max_length=1000, null=True,blank=True, default='Pre-planned')
    # For OT Staff
    ot_staff_id = models.ForeignKey(OTstaff,on_delete=models.CASCADE,null=True, blank=True)
    technician_tl = models.CharField(max_length=1000,null=True,blank=True)
    nurse_tl = models.CharField(max_length=1000,null=True,blank=True)

    #for spececial equipment
    special_equipment = models.CharField(max_length=1000,null=True,blank=True)

class Monitoring(models.Model):
    surgery_date = models.DateField(null=True, blank=True)
    scheduled_surgery_id = models.ForeignKey(Scheduled_Surgeries,on_delete=models.CASCADE,null=True,blank=True)
    #ot_id = models.ForeignKey(OTs,on_delete=models.CASCADE)
    ot_number = models.CharField(max_length=1000, blank=True, null=True)
    user_id = models.ForeignKey(CustomUser,on_delete=models.CASCADE, null=True,blank=True)
    patient_received_in_pre_op_time = models.TimeField(null=True,blank=True)
    antibiotic_prophylaxis_time = models.TimeField(null=True,blank=True)
    patient_wheel_in_OT = models.TimeField(null=True,blank=True)
    induction_start_time = models.TimeField(null=True,blank=True)
    induction_end_time = models.TimeField(null=True,blank=True)
    painting_and_draping_start_time = models.TimeField(null=True,blank=True)
    painting_and_draping_end_time = models.TimeField(null=True,blank=True)
    incision_in_time = models.TimeField(null=True,blank=True)
    incision_close_time = models.TimeField(null=True,blank=True)
    extubation_time_in_OT = models.TimeField(null=True,blank=True)
    wheeled_out_time_to_Post_op_ICU = models.TimeField(null=True,blank=True)
    wheeled_out_from_Post_OP = models.TimeField(null=True,blank=True)
    
    # new entries
    procedure_name = models.TextField(null=True, blank=True)
    estimated_duration = models.FloatField(null=True, blank=True)
    doctor_name = models.CharField(max_length=500, null=True, blank=True)

    ot_staff_id = models.ForeignKey(OTstaff,on_delete=models.CASCADE,null=True, blank=True)
    technician_tl = models.CharField(max_length=1000,null=True,blank=True)
    nurse_tl = models.CharField(max_length=1000,null=True,blank=True)

    #for spececial equipment
    special_equipment = models.CharField(max_length=1000,null=True,blank=True)
    # for emergency surgries 
    surgery_type = models.CharField(max_length=1000, null=True,blank=True, default='Pre-planned')




    


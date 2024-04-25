from django.contrib.auth import get_user_model
from .models import CustomUser, Doctors, OTs, Patients, Procedures, Scheduled_Surgeries, Monitoring
from rest_framework import serializers
from django.contrib.auth.hashers import make_password

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id','email', 'password','name','user_type')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)

class DoctorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Doctors
        fields = '__all__'

class OTSerializer(serializers.ModelSerializer):
    class Meta:
        model = OTs
        fields = '__all__'

class PatientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patients
        fields = '__all__'

class ProcedureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Procedures
        fields = '__all__'
        
class ScheduleSerializer(serializers.ModelSerializer):
    surgery_date = serializers.DateField(format='%m/%d/%Y', input_formats=['%m/%d/%Y'])

    class Meta:
        model = Scheduled_Surgeries
        fields = '__all__'

class MonitorSerializer(serializers.ModelSerializer):
    surgery_date = serializers.DateField(format='%m/%d/%Y', input_formats=['%m/%d/%Y'])
    class Meta:
        model = Monitoring
        fields = '__all__'

class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name', 'role','password']


class SurgeryDateSerializer(serializers.Serializer):
    surgery_date = serializers.DateField(required=False)

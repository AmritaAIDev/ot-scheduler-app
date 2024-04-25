# Create your views here.
from django.contrib.auth import get_user_model
from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import UserSerializer
from .serializers import UserSerializer, UserUpdateSerializer, DoctorSerializer, OTSerializer, PatientSerializer, ProcedureSerializer, ScheduleSerializer, MonitorSerializer
from .models import CustomUser, Doctors, OTs, Patients, Procedures, Scheduled_Surgeries, Monitoring
from rest_framework import generics, viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django_otp.plugins.otp_totp.models import TOTPDevice
from django_otp.util import random_hex
import random
from rest_framework.decorators import action
from .permissions import IsOwner

User = get_user_model()

class UserCreate(APIView):
    permission_classes = (permissions.AllowAny,)
    
    def post(self, request, *args, **kwargs):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            if user:
                refresh = RefreshToken.for_user(user)  # Generate refresh and access tokens
                access_token = str(refresh.access_token)
                refresh_token = str(refresh)
                serializer = UserSerializer(user)
                json = {
                    "user": serializer.data,
                    "access": access_token,
                    "refresh":refresh_token
                }
                return Response(json, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def get(self, request, *args, **kwargs):
        #user_id = request.query_params.get('user_id')
        email = request.query_params.get('email')
        id = request.query_params.get('id')
        user_type = request.query_params.get('user_type')

        if id:
            queryset = CustomUser.objects.filter(id=id)  # Replace YourModel and user_id field
        elif email:
            queryset = CustomUser.objects.filter(email=email)  # Replace YourModel and username field
        elif user_type:
            queryset = CustomUser.objects.filter(user_type=user_type)
        else:
            # Handle the case where neither user_id nor username is provided
            return Response("Please provide email id", status=status.HTTP_400_BAD_REQUEST)

        serializer = UserSerializer(queryset, many=True)  # Replace YourSerializer

        if not queryset.exists():
            return Response("User not found", status=status.HTTP_404_NOT_FOUND)
        
        return Response(serializer.data, status=status.HTTP_200_OK)

class CustomTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            user = CustomUser.objects.get(email=request.data['email'])
            serializer = UserSerializer(user)
            response.data['user'] = serializer.data
        return response
    
class LoginView(CustomTokenObtainPairView):
    permission_classes = (permissions.AllowAny,)

from django.http import HttpResponse

def home(request):
    return HttpResponse("Hi,Welcome to the OT Scheduling App!")

class DoctorListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = Doctors.objects.all()
    serializer_class = DoctorSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        doctor_id = self.request.query_params.get('doctor_id')
        department = self.request.query_params.get('department')
        if doctor_id:
            queryset = queryset.filter(doctor_id=doctor_id)
        if department:
            queryset = queryset.filter(department=department)
        return queryset
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Check if the entry already exists in the database
        doctor_name = serializer.validated_data.get('doctor_name')
        department = serializer.validated_data.get('department')
        if Doctors.objects.filter(doctor_name=doctor_name, department=department).exists():
            return Response({'detail': 'Doctor with this Name and department already exists.'}, status=status.HTTP_409_CONFLICT)
        
        # If not exists, save the new entry
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

class OTListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = OTs.objects.all()
    serializer_class = OTSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        ot_id = self.request.query_params.get('ot_id')
        ot_number = self.request.query_params.get('ot_number')
        department = self.request.query_params.get('department')
        if ot_id:
            queryset = queryset.filter(ot_id=ot_id)
        if department:
            queryset = queryset.filter(department=department)
        if ot_number:
            queryset = queryset.filter(ot_number=ot_number)
        return queryset
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Check if the entry already exists in the database
        ot_number = serializer.validated_data.get('ot_number')
        department = serializer.validated_data.get('department')
        if OTs.objects.filter(ot_number=ot_number, department=department).exists():
            return Response({'detail': 'OT number with this department already exists.'}, status=status.HTTP_409_CONFLICT)
        
        # If not exists, save the new entry
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)



class PatientListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = Patients.objects.all()
    serializer_class = PatientSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        patient_id = self.request.query_params.get('patient_id')
        mrd = self.request.query_params.get('mrd')
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        if mrd:
            queryset = queryset.filter(mrd=mrd)
        return queryset
    
    '''def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Check if the entry already exists in the database
        mrd = serializer.validated_data.get('mrd')
        if Patients.objects.filter(mrd=mrd).exists():
            return Response({'detail': 'Patient with this mrd already exists.'}, status=status.HTTP_409_CONFLICT)
        
        # If not exists, save the new entry
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)'''


class ProcedureListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = Procedures.objects.all()
    serializer_class = ProcedureSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        procedure_id = self.request.query_params.get('procedure_id')
        procedure_name = self.request.query_params.get('procedure_name')
        department = self.request.query_params.get('department')
        estimated_duration = self.request.query_params.get('estimated_duration')
        if procedure_id:
            queryset = queryset.filter(procedure_id=procedure_id)
        if procedure_name:
            queryset = queryset.filter(procedure_name=procedure_name)
        if department:
            queryset = queryset.filter(department=department)
        if estimated_duration:
            queryset = queryset.filter(estimated_duration=estimated_duration)
        return queryset
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Check if the entry already exists in the database
        procedure_name = serializer.validated_data.get('procedure_name')
        department = serializer.validated_data.get('department')
        if Procedures.objects.filter(procedure_name=procedure_name, department=department).exists():
            return Response({'detail': 'Procedure with this department already exists.'}, status=status.HTTP_409_CONFLICT)
        
        # If not exists, save the new entry
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)


class ScheduleListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = Scheduled_Surgeries.objects.all()
    serializer_class = ScheduleSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        scheduled_surgery_id = self.request.query_params.get('scheduled_surgery_id')
        patient_name = self.request.query_params.get('patient_name')
        doctor_name = self.request.query_params.get('doctor_name')
        ot_number = self.request.query_params.get('ot_number')
        procedure_name = self.request.query_params.get('procedure_name')
        user_id = self.request.query_params.get('user_id')
        status = self.request.query_params.get('status')
        date = self.request.query_params.get('date')
        mrd = self.request.query_params.get('mrd')
        if scheduled_surgery_id:
            queryset = queryset.filter(scheduled_surgery_id=scheduled_surgery_id)
        if patient_name:
            queryset = queryset.filter(patient_name=patient_name)
        if doctor_name:
            queryset = queryset.filter(doctor_name=doctor_name)
        if ot_number:
            queryset = queryset.filter(ot_number=ot_number)
        if procedure_name:
            queryset = queryset.filter(procedure_name=procedure_name)
        if user_id:
            queryset = queryset.filter(user_id=user_id)
        if status:
            queryset = queryset.filter(status=status)
        if date:
            queryset = queryset.filter(date=date)
        if mrd:
            queryset = queryset.filter(mrd=mrd)
        
        return queryset
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        fields_to_update = request.data  # Data provided by the user

        # Exclude User_id field from the update
        scheduled_surgery_id = 'scheduled_surgery_id'
        patient_name = 'patient_name'
        doctor_name = 'doctor_name'
        ot_number = 'ot_number'
        procedure_name = 'procedure_name'
        user_id = 'user_id'
        surgery_date = 'surgery_date'
        surgery_start_time = 'surgery_start_time'
        surgery_end_time = 'surgery_end_time'
        mrd = 'mrd'
        
        if scheduled_surgery_id in fields_to_update:
            return Response({'error': f"{scheduled_surgery_id} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if patient_name in fields_to_update:
            return Response({'error': f"{patient_name} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if doctor_name in fields_to_update:
            return Response({'error': f"{doctor_name} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if ot_number in fields_to_update:
            return Response({'error': f"{ot_number} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if procedure_name in fields_to_update:
            return Response({'error': f"{procedure_name} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if user_id in fields_to_update:
            return Response({'error': f"{user_id} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if surgery_date in fields_to_update:
            return Response({'error': f"{surgery_date} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if surgery_start_time in fields_to_update:
            return Response({'error': f"{surgery_start_time} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if surgery_end_time in fields_to_update:
            return Response({'error': f"{surgery_end_time} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)
        
        if mrd in fields_to_update:
            return Response({'error': f"{mrd} cannot be updated"},
                        status=status.HTTP_400_BAD_REQUEST)


        # Iterate through the provided data to update instance fields
        for field, value in fields_to_update.items():
            if hasattr(instance, field):
                setattr(instance, field, value)

        instance.save()  # Save the updated instance
        return Response(self.get_serializer(instance).data)
    
    @action(methods=['delete'], detail=False, url_path='delete-all-on-date')
    def delete_all_on_date(self, request):
        surgery_date = request.query_params.get('surgery_date')
        if not surgery_date:
            return Response({"message": "Date parameter is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Filter the queryset for the specified date
        queryset = self.get_queryset().filter(surgery_date=surgery_date)
        if queryset.exists():
            deleted_count = queryset.delete()[0]  # delete() returns a tuple (num_deleted, details)
            return Response({"message": f"{deleted_count} entries deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        else:
            return Response({"message": "No entries found for the specified date."}, status=status.HTTP_404_NOT_FOUND)
    


class MonitorListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = Monitoring.objects.all()
    serializer_class = MonitorSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        scheduled_surgery_id = self.request.query_params.get('scheduled_surgery_id')
        ot_number = self.request.query_params.get('ot_number')
        user_id = self.request.query_params.get('user_id')
        surgery_date = self.request.query_params.get('surgery_date')
        if scheduled_surgery_id:
            queryset = queryset.filter(scheduled_surgery_id=scheduled_surgery_id)
        if ot_number:
            queryset = queryset.filter(ot_number = ot_number)
        if user_id:
            queryset = queryset.filter(user_id=user_id)
        if surgery_date:
            queryset = queryset.filter(surgery_date=surgery_date)
        
        return queryset
    
class UserUpdateView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserUpdateSerializer
    #permission_classes = [permissions.IsAuthenticated, IsOwner]
    permission_classes = [IsOwner]

    def get_object(self):
        # Ensure a user can only update their own profile
        return self.request.user

    def update(self, request, *args, **kwargs):
        # Exclude email and password from the update
        if 'email' in request.data :
            return Response({'error': 'Updating email is not allowed.'}, status=status.HTTP_400_BAD_REQUEST)

        # Call the parent class's update method for normal fields
        response = super().update(request, *args, **kwargs)

        return response


## data analytics API's

from .serializers import SurgeryDateSerializer

# different ot used
class OTNumberCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = SurgeryDateSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        surgery_date = serializer.validated_data.get('surgery_date')

        if surgery_date:
            queryset = Scheduled_Surgeries.objects.filter(surgery_date=surgery_date)
            if queryset.exists():
                count = queryset.values('ot_number').distinct().count()
                message = f"Count of unique OT numbers on {surgery_date.strftime('%m/%d/%Y')}: {count}"
            else:
                message = f"No scheduled surgeries found on {surgery_date.strftime('%m/%d/%Y')}."
        else:
            count = Scheduled_Surgeries.objects.values('ot_number').distinct().count()
            message = f"Count of unique OT numbers across all dates: {count}"

        return Response({'message': message})
    

## number of surgeries performed in each ot
from django.db.models import Count
class OTSurgeriesCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = SurgeryDateSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        surgery_date = serializer.validated_data.get('surgery_date')

        # Construct the base query
        if surgery_date:
            surgeries = Scheduled_Surgeries.objects.filter(surgery_date=surgery_date)
        else:
            surgeries = Scheduled_Surgeries.objects.all()

        # Aggregate the counts of surgeries per OT number
        ot_counts = surgeries.values('ot_number').annotate(count=Count('ot_number')).order_by('ot_number')

        # Format the response data
        if ot_counts:
            data = [{'ot_number': ot['ot_number'], 'count': ot['count']} for ot in ot_counts]
            message = f"Count of surgeries per OT on {'all dates' if not surgery_date else surgery_date.strftime('%m/%d/%Y')}: {data}"
        else:
            message = f"No surgeries found for {'all dates' if not surgery_date else surgery_date.strftime('%m/%d/%Y')}."

        return Response({'message': message})
    
## heat map of the slots
from django.db.models import Count, Q
from datetime import time, datetime

class OTTimeSlotUsageAPI(APIView):
    def get(self, request):
        # Deserialize input data for the date
        serializer = SurgeryDateSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        surgery_date = serializer.validated_data.get('surgery_date')

        # Define the time slots
        time_slots = [
            (time(8, 0), time(9, 59)),
            (time(10, 0), time(11, 59)),
            (time(12, 0), time(13, 59)),
            (time(14, 0), time(15, 59)),
            (time(16, 0), time(17, 59)),
        ]

        # Prepare the response data structure
        ot_time_slot_usage = {
            'time_slots': [f"{start.strftime('%H:%M')} - {end.strftime('%H:%M')}" for start, end in time_slots],
            'ot_usage': {}
        }

        # Filter by date if provided
        base_query = Scheduled_Surgeries.objects.all()
        if surgery_date:
            base_query = base_query.filter(surgery_date=surgery_date)

        # Fetch the OT numbers available
        ot_numbers = base_query.values_list('ot_number', flat=True).distinct()

        # Count the surgeries for each OT and time slot
        for ot_number in ot_numbers:
            ot_time_slot_usage['ot_usage'][ot_number] = []
            for start_time, end_time in time_slots:
                surgery_count = base_query.filter(
                    ot_number=ot_number,
                    surgery_start_time__gte=start_time,
                    surgery_end_time__lte=end_time
                ).count()
                ot_time_slot_usage['ot_usage'][ot_number].append(surgery_count)

        return Response(ot_time_slot_usage)







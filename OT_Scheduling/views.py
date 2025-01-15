# Create your views here.
from django.contrib.auth import get_user_model
from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import UserSerializer
from .serializers import UserSerializer, UserUpdateSerializer, DoctorSerializer, OTSerializer, PatientSerializer, ProcedureSerializer, ScheduleSerializer, MonitorSerializer, OTstaffSerializer
from .models import CustomUser, Doctors, OTs, Patients, Procedures, Scheduled_Surgeries, Monitoring, OTstaff
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
    
class OTstaffListCreateView(viewsets.ModelViewSet):
    #permission_classes = [IsAuthenticated]
    queryset = OTstaff.objects.all()
    serializer_class = OTstaffSerializer
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Check if the entry already exists in the database
        ot_staff_name = serializer.validated_data.get('ot_staff_name')
        ot_staff_department = serializer.validated_data.get('ot_staff_department')
        ot_staff_designation = serializer.validated_data.get('ot_staff_designation')

        if OTstaff.objects.filter(ot_staff_name=ot_staff_name, ot_staff_department=ot_staff_department,ot_staff_designation=ot_staff_designation ).exists():
            return Response({'detail': 'OT staff with this department and designation already exists.'}, status=status.HTTP_409_CONFLICT)
        
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
        registration_date = self.request.query_params.get('registration_date')
        mrd = self.request.query_params.get('mrd')
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        if mrd:
            queryset = queryset.filter(mrd=mrd)
        if registration_date:
            queryset = queryset.filter(registration_date=registration_date)
        return queryset
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Check if the entry already exists in the database
        mrd = serializer.validated_data.get('mrd')
        if Patients.objects.filter(mrd=mrd).exists():
            return Response({'detail': 'Patient with this mrd already exists.'}, status=status.HTTP_409_CONFLICT)
        
        # If not exists, save the new entry
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
    
    @action(methods=['delete'], detail=False, url_path='delete-all-on-date')
    def delete_all_on_date(self, request):
        registration_date = request.query_params.get('registration_date')
        if not registration_date:
            return Response({"message": "Date parameter is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Filter the queryset for the specified date
        queryset = self.get_queryset().filter(registration_date=registration_date)
        if queryset.exists():
            deleted_count = queryset.delete()[0]  # delete() returns a tuple (num_deleted, details)
            return Response({"message": f"{deleted_count} entries deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        else:
            return Response({"message": "No entries found for the specified date."}, status=status.HTTP_404_NOT_FOUND)


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
        surgery_date = self.request.query_params.get('surgery_date')
        mrd = self.request.query_params.get('mrd')
        ot_staff_id = self.request.query_params.get('ot_staff_id')
        if ot_staff_id:
            queryset = queryset.filter(ot_staff_id=ot_staff_id)
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
        if surgery_date:
            queryset = queryset.filter(surgery_date=surgery_date)
        if mrd:
            queryset = queryset.filter(mrd=mrd)
        
        return queryset
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        fields_to_update = request.data  # Data provided by the user

        '''# Exclude User_id field from the update
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
                        status=status.HTTP_400_BAD_REQUEST)'''


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
        technician_tl = self.request.query_params.get('technician_tl')
        if scheduled_surgery_id:
            queryset = queryset.filter(scheduled_surgery_id=scheduled_surgery_id)
        if ot_number:
            queryset = queryset.filter(ot_number = ot_number)
        if user_id:
            queryset = queryset.filter(user_id=user_id)
        if surgery_date:
            queryset = queryset.filter(surgery_date=surgery_date)
        if technician_tl:
            queryset = queryset.filter(technician_tl=technician_tl)
        
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

from .serializers import DateRangeSerializer

# different ot used
class OTNumberCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Base queryset
        queryset = Monitoring.objects

        # Filter queryset based on the provided date range
        if start_date and end_date:
            queryset = queryset.filter(surgery_date__range=(start_date, end_date))
            if not queryset.exists():
                message = f"No scheduled surgeries found between {start_date.strftime('%m/%d/%Y')} and {end_date.strftime('%m/%d/%Y')}."
                return Response({'message': message})
            count_message = f"Count of unique OT numbers between {start_date.strftime('%m/%d/%Y')} and {end_date.strftime('%m/%d/%Y')}: "
        elif start_date:  # Only the start_date is provided
            queryset = queryset.filter(surgery_date__gte=start_date)
            if not queryset.exists():
                message = f"No scheduled surgeries found starting from {start_date.strftime('%m/%d/%Y')}."
                return Response({'message': message})
            count_message = f"Count of unique OT numbers from {start_date.strftime('%m/%d/%Y')} onwards: "
        elif end_date:  # Only the end_date is provided
            queryset = queryset.filter(surgery_date__lte=end_date)
            if not queryset.exists():
                message = f"No scheduled surgeries found up to {end_date.strftime('%m/%d/%Y')}."
                return Response({'message': message})
            count_message = f"Count of unique OT numbers up to {end_date.strftime('%m/%d/%Y')}: "
        else:
            count_message = "Count of unique OT numbers across all dates: "

        # Calculate the count
        count = queryset.values('ot_number').distinct().count()

        return Response({'message': count_message + str(count)})    

## number of surgeries performed in each ot
from django.db.models import Count

class OTSurgeriesCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Construct the base query
        if start_date and end_date:
            surgeries = Monitoring.objects.filter(surgery_date__range=(start_date, end_date))
        elif start_date:
            surgeries = Monitoring.objects.filter(surgery_date__gte=start_date)
        elif end_date:
            surgeries = Monitoring.objects.filter(surgery_date__lte=end_date)
        else:
            surgeries = Monitoring.objects.all()

        # Aggregate the counts of surgeries per OT number
        ot_counts = surgeries.values('ot_number').annotate(count=Count('ot_number')).order_by('ot_number')

        # Format the response data
        if ot_counts:
            #data = [{'ot_number': ot['ot_number'], 'count': ot['count']} for ot in ot_counts]
            data = [{ot['ot_number']:ot['count']} for ot in ot_counts]
            if start_date and end_date:
                message = f"Count of surgeries per OT from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}"
                result = {message:data}
            elif start_date:
                message = f"Count of surgeries per OT from {start_date.strftime('%Y-%m-%d')} onwards"
                result = {message:data}
            elif end_date:
                message = f"Count of surgeries per OT up to {end_date.strftime('%Y-%m-%d')}"
                result = {message:data}
            else:
                message = f"Count of surgeries per OT on all dates"
                result = {message:data}
        else:
            message = "No surgeries found for the specified dates."
            result = {message: [{"1": 0},{"2": 0},{"3": 0},{"4": 0},{"5": 0},{"6": 0},{"7": 0},{"8": 0},{"9":0},{"10":0},{"11":0}]}

        #return Response({'message': message}) 
        return Response(result) 

      
## heat map of the OT slots
from datetime import time
class OTTimeSlotUsageAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

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

        # Start with the base queryset, possibly filtered by date range
        base_query = Scheduled_Surgeries.objects
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=(start_date, end_date))
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

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
    
## Average of all the steps of a procedure per OT

from django.db.models import Avg, ExpressionWrapper, F, fields, Sum

class AvgMonitoringStepsAPIView(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create a base query for Monitoring
        base_query = Monitoring.objects.all()

        # Apply filters based on provided dates
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Calculate durations and average them
        surgeries = base_query.annotate(
            pre_op_to_ot=ExpressionWrapper(
                F('patient_wheel_in_OT') - F('patient_received_in_pre_op_time'),
                output_field=fields.DurationField()
            ),
            incision_to_extubation=ExpressionWrapper(
                F('extubation_time_in_OT') - F('incision_close_time'),
                output_field=fields.DurationField()
            ),
            extubation_duration=ExpressionWrapper(
                F('wheeled_out_time_to_Post_op_ICU') - F('extubation_time_in_OT'),
                output_field=fields.DurationField()
            ),
            wheeled_out=ExpressionWrapper(
                F('wheeled_out_from_Post_OP') - F('wheeled_out_time_to_Post_op_ICU'),
                output_field=fields.DurationField()
            ),
            induction_duration=ExpressionWrapper(
                F('induction_end_time') - F('induction_start_time'),
                output_field=fields.DurationField()
            ),
            painting_and_draping_duration=ExpressionWrapper(
                F('painting_and_draping_end_time') - F('painting_and_draping_start_time'),
                output_field=fields.DurationField()
            ),
            incision_duration=ExpressionWrapper(
                F('incision_close_time') - F('incision_in_time'),
                output_field=fields.DurationField()
            )
        ).values('ot_number').annotate(
            avg_pre_op_to_ot = Avg('pre_op_to_ot'),
            avg_induction_duration=Avg('induction_duration'),
            avg_painting_and_draping_duration=Avg('painting_and_draping_duration'),
            avg_incision_duration=Avg('incision_duration'),
            avg_extubation_duration=Avg('extubation_duration'),
            avg_incision_to_extubation=Avg('incision_to_extubation'),
            avg_wheeled_duration = Avg('wheeled_out')
        ).order_by('ot_number')

        return Response(surgeries)

### OT Percent Utilization
class OTUtilizationAPIView(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create a base query for Monitoring
        base_query = Monitoring.objects.all()

        # If dates are provided, apply date range filtering
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
            total_days = (end_date - start_date).days + 1  # Including both start and end date
        
        elif start_date:
            return Response({"message": "please enter the end date."})
        
        elif end_date:
            return Response({"message": "Please enter the start date."})

        else:
            # Calculate the range from the earliest to the latest surgery_date in the database
            earliest_date = Monitoring.objects.earliest('surgery_date').surgery_date
            latest_date = Monitoring.objects.latest('surgery_date').surgery_date
            total_days = (latest_date - earliest_date).days + 1 if earliest_date and latest_date else 0

        total_possible_hours_per_ot = total_days * 10  # 10 hours per day

        # Fetch OT utilization data
        base_query = base_query.annotate(
            utilization_time=ExpressionWrapper(
                F('wheeled_out_time_to_Post_op_ICU') - F('patient_wheel_in_OT'),
                output_field=fields.DurationField()
            )
        ).values('ot_number').annotate(
            total_utilization=Sum('utilization_time')
        )

        # Calculate utilization percentage for each OT
        ot_utilization_percentages = {}
        if total_days > 0:
            for entry in base_query:
                ot_number = entry['ot_number']
                total_utilization_seconds = entry['total_utilization'].total_seconds() if entry['total_utilization'] else 0
                total_possible_seconds = total_possible_hours_per_ot * 3600
                utilization_percentage = (total_utilization_seconds / total_possible_seconds) * 100
                #ot_utilization_percentages[ot_number] = round(utilization_percentage, 2)
                ot_utilization_percentages[ot_number] = utilization_percentage
        
        if not ot_utilization_percentages:
            return Response({"message": "No surgeries found in the specified range."})
        
        result = []
        for k,v in ot_utilization_percentages.items():
            result.append({k:v})

        return Response(result)
    
### Average difference time between two surgeries
from django.db.models import ExpressionWrapper, fields, Avg, Subquery, OuterRef
from django.db.models.functions import Coalesce
from rest_framework import status
class AvgTimeDifferenceAPIView(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        queryset = Monitoring.objects.all()

        # Apply date filters based on the provided start and end dates
        if start_date and end_date:
            queryset = queryset.filter(surgery_date__gte=start_date, surgery_date__lte=end_date)
        elif start_date:
            queryset = queryset.filter(surgery_date__gte=start_date)
        elif end_date:
            queryset = queryset.filter(surgery_date__lte=end_date)

        # If no dates are provided, the filter defaults to the full range of existing dates
        if not start_date and not end_date:
            queryset = queryset.filter(surgery_date__isnull=False)

        # Check if any records exist after filtering
        if not queryset.exists():
            return Response({'message': 'No data found for the specified date range.'}, status=status.HTTP_404_NOT_FOUND)

        '''# Calculate the average time difference
        queryset = queryset.annotate(
            time_difference=ExpressionWrapper(
                F('wheeled_out_from_Post_OP') - F('patient_received_in_pre_op_time'),
                output_field=fields.DurationField()
            )
        ).values('ot_number').annotate(
            avg_time_difference=Avg('time_difference')
        ).order_by('ot_number')

        return Response(queryset)'''

        # Define a subquery to fetch the next consecutive surgery for each surgery
        next_surgery_subquery = Monitoring.objects.filter(
        ot_number=OuterRef('ot_number'),
        surgery_date__gt=OuterRef('surgery_date')
        ).order_by('surgery_date').values('surgery_date')[:1]

        # Annotate the queryset with the next consecutive surgery's data
        queryset = queryset.annotate(
        next_patient_received_in_pre_op_time=Coalesce(Subquery(next_surgery_subquery, output_field=fields.DateTimeField()), Value('9999-12-31 00:00:00'))
    )

        # Calculate the time difference between wheeled_out_from_Post_OP and the next surgery's patient_received_in_pre_op_time
        queryset = queryset.annotate(
        time_difference=ExpressionWrapper(
            F('next_patient_received_in_pre_op_time') - F('wheeled_out_from_Post_OP'),
            output_field=fields.DurationField()
        )
        ).filter(time_difference__isnull=False)  # Filter out null values

        # Calculate the average time difference per OT
        queryset = queryset.values('ot_number').annotate(
        avg_time_difference=Avg('time_difference')
        #avg_time_difference=ExpressionWrapper(Avg('time_difference')*Value(),output_field=fields.FloatField())
        )

        return Response(queryset)
    
### For Doctors Analytics

class DoctorNumberCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create base query for Scheduled_Surgeries
        base_query = Scheduled_Surgeries.objects

        # Filter based on the provided date range
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Determine the count of unique doctors
        count = base_query.values('doctor_name').distinct().count()
        if base_query.exists():
            if start_date and end_date:
                message = f"Count of unique doctors from {start_date.strftime('%m/%d/%Y')} to {end_date.strftime('%m/%d/%Y')}: {count}"
            elif start_date:
                message = f"Count of unique doctors from {start_date.strftime('%m/%d/%Y')} onwards: {count}"
            elif end_date:
                message = f"Count of unique doctors up to {end_date.strftime('%m/%d/%Y')}: {count}"
            else:
                message = f"Count of unique doctors across all dates: {count}"
        else:
            message = "No scheduled doctors found."

        return Response({'message': message})    

## number of surgeries performed by each doctor
class DoctorSurgeriesCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Scheduled Surgeries
        base_query = Monitoring.objects

        # Apply date filters based on the provided date range
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Aggregate the counts of surgeries per doctor
        doctor_counts = base_query.values('doctor_name').annotate(count=Count('doctor_name')).order_by('doctor_name')

        # Format the response data
        if doctor_counts:
            data = [{doctor['doctor_name']: doctor['count']} for doctor in doctor_counts]
            if start_date and end_date:
                message = {f"Count of surgeries per doctor from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}": data}
            elif start_date:
                message = {f"Count of surgeries per doctor from {start_date.strftime('%Y-%m-%d')} onwards": data}
            elif end_date:
                message = {f"Count of surgeries per doctor up to {end_date.strftime('%Y-%m-%d')}": data}
            else:
                message = {f"Count of surgeries per doctor across all dates": data}
        else:
            message = {"No surgeries found for the specified dates.":0}

        return Response(message)    

## heat map of the Doctors slots
class DoctorTimeSlotUsageAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Define the time slots
        time_slots = [
            (time(8, 0), time(9, 59)),
            (time(10, 0), time(11, 59)),
            (time(12, 0), time(13, 59)),
            (time(14, 0), time(15, 59)),
            (time(16, 0), time(17, 59)),
        ]

        # Prepare the response data structure
        doctor_time_slot_usage = {
            'time_slots': [f"{start.strftime('%H:%M')} - {end.strftime('%H:%M')}" for start, end in time_slots],
            'doctor_usage': {}
        }

        # Start with the base queryset, possibly filtered by date range
        base_query = Scheduled_Surgeries.objects
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Fetch distinct doctor names
        doctor_names = base_query.values_list('doctor_name', flat=True).distinct()

        # Count the surgeries for each doctor and time slot
        for doctor_name in doctor_names:
            doctor_time_slot_usage['doctor_usage'][doctor_name] = []
            for start_time, end_time in time_slots:
                surgery_count = base_query.filter(
                    doctor_name=doctor_name,
                    surgery_start_time__gte=start_time,
                    surgery_end_time__lte=end_time
                ).count()
                doctor_time_slot_usage['doctor_usage'][doctor_name].append(surgery_count)

        return Response(doctor_time_slot_usage)    

## average duration of each doctor

from datetime import timedelta
class DoctorAverageSurgeryDurationAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Start with the base queryset for Scheduled Surgeries
        surgeries = Monitoring.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            surgeries = surgeries.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            surgeries = surgeries.filter(surgery_date__gte=start_date)
        elif end_date:
            surgeries = surgeries.filter(surgery_date__lte=end_date)

        # Calculate surgery duration
        surgeries = surgeries.annotate(
            duration=ExpressionWrapper(
                F('wheeled_out_time_to_Post_op_ICU') - F('patient_wheel_in_OT'),
                output_field=fields.DurationField()
            )
        )

        # Filter out surgeries with no end time or start time
        surgeries = surgeries.exclude(wheeled_out_time_to_Post_op_ICU=None).exclude(patient_wheel_in_OT=None)

        # Calculate average duration for each doctor
        average_durations = surgeries.values('doctor_name').annotate(
            average_duration=Avg('duration')
        ).order_by('doctor_name')

        # Convert average duration to a readable format
        response_data = {
            doctor['doctor_name']: str(timedelta(seconds=doctor['average_duration'].total_seconds())) if doctor['average_duration'] else '00:00:00' for doctor in average_durations
        }
        result = []
        for k,v in response_data.items():
            result.append({k:v})

        return Response({'message':result})
    

## Department Analytics
# Count of Departments

class DepartmentNumberCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Scheduled Surgeries
        base_query = Scheduled_Surgeries.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Count the distinct departments
        count = base_query.values('department').distinct().count()

        # Format the response message
        if count > 0:
            if start_date and end_date:
                #message = f"Count of departments from {start_date.strftime('%m/%d/%Y')} to {end_date.strftime('%m/%d/%Y')}: {count}"
                message = f"Count of departments from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}: {count}"
            elif start_date:
                message = f"Count of departments from {start_date.strftime('%Y-%m-%d')} onwards: {count}"
            elif end_date:
                message = f"Count of departments up to {end_date.strftime('%Y-%m-%d')}: {count}"
            else:
                message = f"Count of departments across all dates: {count}"
        else:
            message = "No departments found in the specified range."

        return Response({'message': message})
    

'''## Doctors in each department
class DepartmentDoctorCountAPI(APIView):
    def get(self, request):
        # Deserialize the input data for the date
        serializer = SurgeryDateSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        surgery_date = serializer.validated_data.get('surgery_date')

        if surgery_date:
            # Filter surgeries by date
            surgeries_on_date = Scheduled_Surgeries.objects.filter(surgery_date=surgery_date)

            # Check if there are any surgeries on the given date
            if not surgeries_on_date.exists():
                return Response({"message": "No data for the given date"})

            # Proceed to count the number of doctors per department for the given date
            department_doctor_counts = surgeries_on_date.values('department') \
                .annotate(doctor_count=Count('doctor_name', distinct=True)) \
                .order_by('department')
        else:
            # If no date is provided, count the number of doctors for all departments in the database
            department_doctor_counts = Scheduled_Surgeries.objects.values('department') \
                .annotate(doctor_count=Count('doctor_name', distinct=True)) \
                .order_by('department')

        # Format the result into a dictionary
        department_counts = {entry['department']: entry['doctor_count'] for entry in department_doctor_counts}

        return Response(department_counts)'''
    
## Surgeries in each department
class DepartmentSurgeryCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Start with the base queryset for Scheduled Surgeries
        base_query = Scheduled_Surgeries.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Check if there are any surgeries within the filtered range
        if not base_query.exists():
            return Response({"message": "No data for the specified date range"})

        # Count the number of surgeries per department
        department_surgery_counts = base_query.values('department') \
            .annotate(surgery_count=Count('procedure_name')) \
            .order_by('department')

        # Format the result into a dictionary
        department_counts = {entry['department']: entry['surgery_count'] for entry in department_surgery_counts}
        result = []

        for k,v in department_counts.items():
            result.append({k:v})

        return Response({'message':result})
    
# count of unique surgeries per department

class UniqueDepartmentSurgeryCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Start with the base queryset for Scheduled Surgeries
        base_query = Scheduled_Surgeries.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Check if there are any surgeries within the filtered range
        if not base_query.exists():
            return Response({"message": "No surgeries found for the specified date range"}, status=status.HTTP_404_NOT_FOUND)

        # Count the number of unique surgeries per department
        surgery_counts_per_department = base_query.values('department', 'procedure_name') \
            .annotate(surgery_count=Count('procedure_name')) \
            .order_by('department', 'procedure_name')

        # Organize the result into a structured format
        department_surgeries = {}
        for entry in surgery_counts_per_department:
            department = entry['department']
            procedure = entry['procedure_name']
            count = entry['surgery_count']
            if department not in department_surgeries:
                department_surgeries[department] = []
            department_surgeries[department].append({'procedure_name': procedure, 'count': count})

        return Response(department_surgeries)


## procedures Analytics
class ProcedureCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Scheduled Surgeries
        surgeries = Scheduled_Surgeries.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            surgeries = surgeries.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            surgeries = surgeries.filter(surgery_date__gte=start_date)
        elif end_date:
            surgeries = surgeries.filter(surgery_date__lte=end_date)

        # Count the total number of procedures
        # Instead of counting distinct procedures, we count all procedure entries
        procedure_count = surgeries.count()

        # Prepare the response message
        message = "Total number of procedures"
        if start_date and end_date:
            message += f" from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}"
        elif start_date:
            message += f" from {start_date.strftime('%Y-%m-%d')} onwards"
        elif end_date:
            message += f" up to {end_date.strftime('%Y-%m-%d')}"
        else:
            message += " across all dates"
        result = {message: procedure_count}

        return Response({'message':[result]})
    

#Time Comparison of each procedure by different Doctors

class ProcedureTimeComparisonAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Build the base query
        base_query = Monitoring.objects
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Calculate surgery duration
        base_query = base_query.annotate(
            duration=ExpressionWrapper(
                F('wheeled_out_time_to_Post_op_ICU') - F('patient_wheel_in_OT'),
                output_field=fields.DurationField()
            )
        ).exclude(patient_received_in_pre_op_time=None).exclude(wheeled_out_from_Post_OP=None)

        # Group and calculate average duration by procedure and doctor
        procedure_durations = base_query.values('procedure_name', 'doctor_name').annotate(
            average_duration=Avg('duration')
        ).order_by('procedure_name', 'doctor_name')

        # Organize data for response
        procedures = {}
        for entry in procedure_durations:
            proc_name = entry['procedure_name']
            if proc_name not in procedures:
                procedures[proc_name] = []
            # Format the average duration upto 2 decimal
            average_duration = entry['average_duration'].total_seconds()
            average_duration_timedelta = timedelta(seconds=average_duration)
            average_duration_str = str(average_duration_timedelta)
            procedures[proc_name].append({
                'doctor_name': entry['doctor_name'],
                #'average_duration': str(timedelta(seconds=entry['average_duration'].total_seconds()))
                'average_duration': average_duration_str
            })

        # Prepare final response
        response_data = [
            {
                'procedure_name': name,
                'doctors': procedures[name]
            } for name in procedures
        ]

        return Response(response_data)

#Percentage of Emergency surgeries, Add-on and pre-planned surgeries
class SurgeryTypePercentageAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Scheduled Surgeries
        base_query = Monitoring.objects
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Calculate total surgeries and count by types
        total_count = base_query.count()
        if total_count == 0:
            return Response({'message': 'No surgeries found for the specified range.'})

        emergency_count = base_query.filter(surgery_type='Emergency').count()
        addon_count = base_query.filter(surgery_type='Add-on').count()
        preplanned_count = base_query.filter(surgery_type='Pre-planned').count()

        # Calculate percentages
        emergency_percentage = (emergency_count / total_count) * 100
        addon_percentage = (addon_count / total_count) * 100
        preplanned_percentage = (preplanned_count / total_count) * 100

        # Prepare the response data
        response_data = [
            {'emergency_percentage': round(emergency_percentage, 2)},
            {'add_on_percentage': round(addon_percentage, 2)},
            {'pre_planned_percentage': round(preplanned_percentage, 2)},
            {'total_surgeries': total_count}
        ]

        return Response({'message':response_data})
    
## percent of delayed and on time surgeries
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db.models import Case, When, Value, BooleanField, Count, ExpressionWrapper, F, fields, Q
from .models import Monitoring
from .serializers import DateRangeSerializer
from datetime import timedelta

class SurgeryTimingPercentageAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Monitoring, excluding surgeries with missing critical time values or estimated duration
        base_query = Monitoring.objects.exclude(
            Q(patient_received_in_pre_op_time__isnull=True) |
            Q(wheeled_out_from_Post_OP__isnull=True) |
            Q(estimated_duration__isnull=True)
        )

        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Calculate actual surgery duration and determine if delayed
        base_query = base_query.annotate(
            actual_duration=ExpressionWrapper(
                F('wheeled_out_from_Post_OP') - F('patient_received_in_pre_op_time'),
                output_field=fields.DurationField()
            )
        ).annotate(
            is_delayed=Case(
                When(actual_duration__gt=F('estimated_duration'), then=Value(True)),
                default=Value(False),
                output_field=BooleanField()
            )
        )

        # Count total, delayed, and on-time surgeries
        total_count = base_query.count()
        if total_count == 0:
            return Response({"message": "No valid surgery records found for the specified criteria or date range."})

        delayed_count = base_query.filter(is_delayed=True).count()
        on_time_count = base_query.filter(is_delayed=False).count()

        # Calculate percentages
        delayed_percentage = (delayed_count / total_count * 100) if total_count > 0 else 0
        on_time_percentage = (on_time_count / total_count * 100) if total_count > 0 else 0

        # Prepare the response data
        response_data = [
            {'delayed_percentage': round(delayed_percentage, 2)},
            {'on_time_percentage': round(on_time_percentage, 2)},
            {'total_surgeries': total_count}
        ]

        return Response({'message':response_data})

### Patient Related Data Analytics

# Number of Patients
class PatientCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Patients
        base_query = Patients.objects
        if start_date and end_date:
            base_query = base_query.filter(registration_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(registration_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(registration_date__lte=end_date)

        # Count total patients within the date range
        total_patients = base_query.count()

        # Prepare the response data
        response_data = [
            {'total_patients': total_patients},
            {'date_range': {
                'start_date': start_date.strftime('%Y-%m-%d') if start_date else None,
                'end_date': end_date.strftime('%Y-%m-%d') if end_date else None
            }}
        ]

        return Response({'message':response_data})
    
## Gender Distribution
class GenderDistributionAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Patients
        base_query = Patients.objects
        if start_date and end_date:
            base_query = base_query.filter(registration_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(registration_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(registration_date__lte=end_date)

        # Count total patients and total by gender
        total_count = base_query.count()
        if total_count == 0:
            return Response({'message': 'No patients found for the specified range.'})

        gender_counts = base_query.values('gender').annotate(count=Count('gender')).order_by('gender')

        # Calculate percentages
        gender_distribution = {entry['gender']: (entry['count'] / total_count * 100) for entry in gender_counts}

        # Prepare the response data
        response_data = [
            {'Female': gender_distribution['F']},
            {'Male':gender_distribution['M']},
            {'total_patients': total_count}
        ]

        return Response({'message':response_data})

#### Age Distribution

from rest_framework.views import APIView
from rest_framework.response import Response
from django.db.models import Count, Case, When, IntegerField, CharField
from .models import Patients
from .serializers import DateRangeSerializer

class AgeDistributionAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Filter patients based on the date range
        base_query = Patients.objects
        if start_date and end_date:
            base_query = base_query.filter(registration_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(registration_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(registration_date__lte=end_date)

        # Check if any patients exist in the filtered range
        if not base_query.exists():
            return Response({'message': 'No patients found for the specified date range.'}, status=status.HTTP_404_NOT_FOUND)

        # Annotate patients with age groups
        age_groups = base_query.annotate(
            age_group=Case(
                When(age__lte=18, then=Value('0-18')),
                When(age__lte=35, then=Value('19-35')),
                When(age__lte=60, then=Value('36-60')),
                default=Value('61+'),
                output_field=CharField()
            )
        ).values('age_group').annotate(count=Count('age_group')).order_by('age_group')

        # Calculate total patients for percentage calculation
        total_count = base_query.count()

        # Convert counts to percentages
        age_distribution = [
            {'age_group': group['age_group'] ,'count': group['count'], 'percentage': (group['count'] / total_count * 100) if total_count > 0 else 0}
            for group in age_groups
        ]

        return Response({
            'age_distribution': age_distribution,
        })
class SurgeryDateAPI(APIView):
    def get(self, request):
        # Querying the earliest and latest surgery dates
        earliest_surgery = Monitoring.objects.filter(surgery_date__isnull=False).order_by('surgery_date').first()
        latest_surgery = Monitoring.objects.filter(surgery_date__isnull=False).order_by('-surgery_date').first()
        
        # Fetching the dates, handling cases where there might be no surgeries
        earliest_date = earliest_surgery.surgery_date if earliest_surgery else None
        latest_date = latest_surgery.surgery_date if latest_surgery else None
        
        # Returning the dates in JSON format
        return Response([
            {'earliest date' : earliest_date},
            {'latest date': latest_date}
        ])
    
import pandas as pd
import base64
import tempfile

class OTSchedulerView(APIView):
    def post(self, request, *args, **kwargs):
        # Enable CORS
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST',
            'Access-Control-Allow-Headers': 'Content-Type'
        }

        # Decode the base64 string
        request_json = request.data
        doc_data = request_json['doc']
        #start_time = request_json['start_time']
        #buffer_time = request_json['buffer_time']
        decoded_bytes = base64.b64decode(doc_data)

        # Write the decoded bytes to a temporary Excel file
        with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
            tmp.write(decoded_bytes)
            tmp_path = tmp.name
        print('File Decoded Successfully')

        '''# Reading the Final Procedure file
        storage_client = storage.Client()
        bucket = storage_client.bucket('disease-classifier-model')
        blob = bucket.blob('Final Procedures.xlsx')
        data = blob.download_as_bytes()
        excel_data = io.BytesIO(data)
        print('Final Procedure Loaded')'''


        # Preprocessing Input
        def preprocessed_surgeries(data):
            q = []
            for i in data:
                i = i.lower()
                i = i.replace(' ', '')
                q.append(i)
            return q

        df = pd.read_excel('C:/Users/Admin/Downloads/Final Procedures(1).xlsx')
        print('Final Procedures Read')
        inp = pd.read_excel(tmp_path)
        print('Input File Read')

        # Sorting with the Priority
        def priority_surgery(knowledge_base, input_file):
            input_file.columns = [
                'Date of Surgery', 'Age/Sex', 'Procedure', 'Surgeon', 'Department',
                'Name of the Patient', 'Special Equipment', 'MRD'
            ]
            knowledge_base['Processed_Procedures'] = preprocessed_surgeries(knowledge_base['Procedure'])
            input_file['Processed_Procedures'] = preprocessed_surgeries(input_file['Procedure'])

            map_input = pd.merge(
                input_file, knowledge_base, how='inner', on='Processed_Procedures'
            ).drop_duplicates(['Processed_Procedures', 'Surgeon', 'Age/Sex'])
            filter_map = map_input.drop(['Sr No', 'Procedure_y', 'Department_y', 'Special Request'], axis=1)

            age = []
            for i in filter_map['Age/Sex']:
                i = i.split('Y')
                age.append(float(i[0]))

            filter_map['Age'] = age

            filter_a = filter_map[filter_map['Duration'] > 10.0].sort_values(by='Age', ascending=True)
            filter_b = filter_map[
                (filter_map['Duration'] < 10.0) & (filter_map['Age'] < 12.0)
            ].sort_values(by='Age', ascending=True)
            filter_c = filter_map[
                (filter_map['Duration'] < 10.0) & (filter_map['Age'] > 12.0)
            ].sort_values(by='Duration', ascending=False)

            filter = pd.concat([filter_a, filter_b, filter_c], axis=0)

            ot = []

            for i in filter['Preferred OT']:
                i = str(i)
                i = i.replace(' ', '')
                j = list(map(int, i.split(',')))
                ot.append(j)

            filter['ot'] = ot
            filter['number ots'] = [len(i) for i in filter['ot']]
            filter_1 = pd.concat([filter[filter['number ots'] == 1], filter[filter['number ots'] != 1]], axis=0)

            return filter_1

        # Priority set up
        a = priority_surgery(df, inp)
        print('Priority Set')

        ## For Emergency Scheduling
        from datetime import datetime
        from django.http import JsonResponse
        from django.db.models import Max
        from .models import Scheduled_Surgeries
        def get_previous_end_times(request):
            # Get the date and time from the request parameters
            date_string = request.GET.get('date')
            time_string = request.GET.get('time')

            # Check if both date and time parameters are present and not empty
            if date_string and time_string:
                try:
                    # Convert date string to datetime object
                    input_date = datetime.strptime(date_string, "%Y-%m-%d")
                    # Convert time string to datetime object
                    input_time = datetime.strptime(time_string, "%H:%M:%S")

                    # Query to get the previous end time for each OT for the given date and time
                    previous_end_times = Scheduled_Surgeries.objects.filter(
                        surgery_date=input_date,
                        surgery_end_time__lt=input_time
                    ).values('ot_number').annotate(max_end_time=Max('surgery_end_time'))

                    # Convert queryset to list for easier JSON serialization
                    previous_end_times_list = list(previous_end_times)

                    return JsonResponse(previous_end_times_list, safe=False)
                except ValueError:
                    # Handle ValueError if date or time format is incorrect
                    return JsonResponse({'error': 'Invalid date or time format'}, status=400)
            else:
                # Handle case when date or time parameter is missing
                return JsonResponse({'error': 'Date or time parameter is missing'}, status=400)


        # Scheduling Algorithm
        def scheduled_procedure(surgeries):
            filter_1 = surgeries

            surgery_duration = dict(zip(filter_1['Procedure_x'], filter_1['Duration']))
            surgery_ot = dict(zip(filter_1['Procedure_x'], filter_1['ot']))
            surgery_doctor = dict(zip(filter_1['Procedure_x'], filter_1['Surgeon']))
            unscheduled_surgeries = [
                [filter_1['Procedure_x'].iloc[i], filter_1["MRD"].iloc[i]]
                for i in range(len(filter_1))
            ]
            scheduled_surgeries = []
            OT_dict = {}
            doctors = {i: [] for i in filter_1['Surgeon']}

            # Function to check if two slots overlap
            def check_overlap(slot1, slot2):
                return slot1[0] < slot2[1] and slot2[0] < slot1[1]

            # Function to find if the new slot is free and add it to the occupied slots if it is free
            def book_slot(occupied_slots, new_slot):
                for slot in occupied_slots:
                    if check_overlap(slot, new_slot):
                        return False  # Slot is not free
                if new_slot[1] > 1080 and len(occupied_slots) == 0 and int(new_slot[1] - new_slot[0]) < 600:
                    return False

                return True  # Slot is successfully booked

            for i in unscheduled_surgeries:
                ots = surgery_ot[i[0]]
                duration = surgery_duration[i[0]]
                doctor = surgery_doctor[i[0]]
                schedule_hua = False
                for ot in ots:
                    if schedule_hua:
                        break
                    for j in range(0, 601):
                        if ot in OT_dict:
                            ot_duration = OT_dict[ot] + 30 + j
                            ot_duration_end = ot_duration + (duration * 60) + j
                            slots = book_slot(doctors[doctor], (ot_duration, ot_duration_end))

                            if ot_duration_end > 1080 and duration > 10 and slots:
                                scheduled_surgeries.append({
                                    'surgery': i[0], 'OT': ot, 'Start_time': ot_duration,
                                    'End_time': ot_duration_end, 'Doctor': doctor, 'MRD': i[1]
                                })
                                OT_dict[ot] = ot_duration_end
                                doctors[doctor].append((ot_duration, ot_duration_end))
                                schedule_hua = True
                                break

                            elif ot_duration_end <= 1080 and slots:
                                scheduled_surgeries.append({
                                    'surgery': i[0], 'OT': ot, 'Start_time': ot_duration,
                                    'End_time': ot_duration_end, 'Doctor': doctor, 'MRD': i[1]
                                })
                                OT_dict[ot] = ot_duration_end
                                doctors[doctor].append((ot_duration, ot_duration_end))
                                schedule_hua = True
                                break

                        else:
                            ot_duration = 480 + j
                            ot_duration_end = ot_duration + (duration * 60) + j
                            slots = book_slot(doctors[doctor], (ot_duration, ot_duration_end))
                            if ot_duration_end > 1080 and duration > 10.0 and slots:
                                scheduled_surgeries.append({
                                    'surgery': i[0], 'OT': ot, 'Start_time': ot_duration,
                                    'End_time': ot_duration_end, 'Doctor': doctor, 'MRD': i[1]
                                })
                                OT_dict[ot] = ot_duration_end
                                doctors[doctor].append((ot_duration, ot_duration_end))
                                schedule_hua = True
                                break

                            elif ot_duration_end <= 1080 and slots:
                                scheduled_surgeries.append({
                                    'surgery': i[0], 'OT': ot, 'Start_time': ot_duration,
                                    'End_time': ot_duration_end, 'Doctor': doctor, 'MRD': i[1]
                                })
                                OT_dict[ot] = ot_duration_end
                                doctors[doctor].append((ot_duration, ot_duration_end))
                                schedule_hua = True
                                break

            return scheduled_surgeries

        final_schedule_surgeries = pd.DataFrame(scheduled_procedure(a))
        final_schedule_surgeries['Start_time'] = [
            f'{int(i // 60)}:{str(int(i % 60)).zfill(2)}' for i in final_schedule_surgeries['Start_time']
        ]
        final_schedule_surgeries['End_time'] = [
            f'{int(i // 60)}:{str(int(i % 60)).zfill(2)}' for i in final_schedule_surgeries['End_time']
        ]

        #print('Surgeries Scheduled')

        a.drop(['Processed_Procedures', 'Duration', 'Preferred OT', 'Age', 'ot', 'number ots'], axis=1, inplace=True)
        a.columns = [
            'Date of Surgery', 'Age/Sex', 'surgery', 'Surgeon', 'Department',
            'Name of the Patient', 'Special Equipment', 'MRD'
        ]
        #print('Rename Done')
        result = pd.merge(a, final_schedule_surgeries, on='MRD', how='inner')
        #print('Merge Done')
        #print(result.head())

        result.drop_duplicates(['Age/Sex', 'surgery_x', 'Surgeon', 'Name of the Patient'], inplace=True)
        result.drop(['Doctor', 'surgery_y'], axis=1, inplace=True)
        result.columns = [
            'Date of Surgery', 'Age/Sex', 'surgery', 'Surgeon', 'Department',
            'Name of the Patient', 'Special Equipment', 'MRD', 'OT', 'Start_time', 'End_time'
        ]
        result.fillna('Null', inplace=True)
        #print(result)

        return Response(result.to_dict(), status=200, headers=headers)
    
## OT Staff analytics
## Count in the dashboard

class OTstaffNumberCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Base queryset
        queryset = Scheduled_Surgeries.objects

        # Filter queryset based on the provided date range
        if start_date and end_date:
            queryset = queryset.filter(surgery_date__range=(start_date, end_date))
            if not queryset.exists():
                message = f"No OT Staff found between {start_date.strftime('%m/%d/%Y')} and {end_date.strftime('%m/%d/%Y')}."
                return Response({'message': message})
            count_message = f"Count of OT Staff between {start_date.strftime('%m/%d/%Y')} and {end_date.strftime('%m/%d/%Y')}: "
        elif start_date:  # Only the start_date is provided
            queryset = queryset.filter(surgery_date__gte=start_date)
            if not queryset.exists():
                message = f"No OT Staff found between starting from {start_date.strftime('%m/%d/%Y')}."
                return Response({'message': message})
            count_message = f"Count of OT Staff from {start_date.strftime('%m/%d/%Y')} onwards: "
        elif end_date:  # Only the end_date is provided
            queryset = queryset.filter(surgery_date__lte=end_date)
            if not queryset.exists():
                message = f"No OT Staff found up to {end_date.strftime('%m/%d/%Y')}."
                return Response({'message': message})
            count_message = f"Count of OT Staff up to {end_date.strftime('%m/%d/%Y')}: "
        else:
            count_message = "Count of OT Staff across all dates: "

        # Calculate the count
        count = queryset.values('technician_tl').distinct().count()

        return Response({'message': count_message + str(count)})
    
# Surgery count for each OT Staff
class OTstaffSurgeriesCountAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Create the base query for Scheduled Surgeries
        base_query = Monitoring.objects

        # Apply date filters based on the provided date range
        if start_date and end_date:
            base_query = base_query.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            base_query = base_query.filter(surgery_date__gte=start_date)
        elif end_date:
            base_query = base_query.filter(surgery_date__lte=end_date)

        # Exclude null values for the technician_tl field
        base_query = base_query.exclude(technician_tl__isnull=True)

        # Aggregate the counts of surgeries per technician
        staff_counts = base_query.values('technician_tl').annotate(count=Count('technician_tl')).order_by('technician_tl')

        # Format the response data
        if staff_counts:
            data = [{'staff_name':staff['technician_tl'],'count': staff['count']} for staff in staff_counts]
            if start_date and end_date:
                message = {f"Count of surgeries per staff from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}": data}
            elif start_date:
                message = {f"Count of surgeries per staff from {start_date.strftime('%Y-%m-%d')} onwards": data}
            elif end_date:
                message = {f"Count of surgeries per staff up to {end_date.strftime('%Y-%m-%d')}": data}
            else:
                message = {f"Count of surgeries per staff across all dates": data}
        else:
            message = {"No surgeries found for the specified dates.":0}

        return Response(message)
    '''def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Construct the base query
        if start_date and end_date:
            surgeries = Scheduled_Surgeries.objects.filter(surgery_date__range=(start_date, end_date))
        elif start_date:
            surgeries = Scheduled_Surgeries.objects.filter(surgery_date__gte=start_date)
        elif end_date:
            surgeries = Scheduled_Surgeries.objects.filter(surgery_date__lte=end_date)
        else:
            surgeries = Scheduled_Surgeries.objects.all()

        # Aggregate the counts of surgeries per OT number
        otstaff_counts = surgeries.values('ot_staff_id').annotate(count=Count('ot_staff_id')).order_by('ot_staff_id')

        # Fetch OT staff names and format the response data
        data = []
        for otstaff_count in otstaff_counts:
            ot_staff_id = otstaff_count['ot_staff_id']
            ot_staff_name = OTstaff.objects.get(ot_staff_id=ot_staff_id).name
            data.append({ot_staff_name: otstaff_count['count']})

        # Format the response data
        if otstaff_counts:
            #data = [{'ot_number': ot['ot_number'], 'count': ot['count']} for ot in ot_counts]
            data = [{ot['ot_number']:ot['count']} for ot in otstaff_counts]
            if start_date and end_date:
                message = f"Count of surgeries per OT Staff from {start_date.strftime('%m/%d/%Y')} to {end_date.strftime('%m/%d/%Y')}"
                result = {message:data}
            elif start_date:
                message = f"Count of surgeries per OT Staff from {start_date.strftime('%m/%d/%Y')} onwards"
                result = {message:data}
            elif end_date:
                message = f"Count of surgeries per OT Staff up to {end_date.strftime('%m/%d/%Y')}"
                result = {message:data}
            else:
                message = f"Count of surgeries per OT Staff on all dates"
                result = {message:data}
        else:
            result = "No surgeries found for the specified dates."

        #return Response({'message': message}) 
        return Response(result) '''

# Average duration of each Staff
class OTstaffAverageSurgeryDurationAPI(APIView):
    def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Start with the base queryset for Scheduled Surgeries
        surgeries = Monitoring.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            surgeries = surgeries.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            surgeries = surgeries.filter(surgery_date__gte=start_date)
        elif end_date:
            surgeries = surgeries.filter(surgery_date__lte=end_date)

        # Calculate surgery duration
        surgeries = surgeries.annotate(
            duration=ExpressionWrapper(
                F('wheeled_out_time_to_Post_op_ICU') - F('patient_wheel_in_OT'),
                output_field=fields.DurationField()
            )
        )

        # Filter out surgeries with no end time or start time
        surgeries = surgeries.exclude(wheeled_out_time_to_Post_op_ICU=None).exclude(patient_wheel_in_OT=None).exclude(technician_tl__isnull=True)

        # Calculate average duration for each doctor
        average_durations = surgeries.values('technician_tl').annotate(
            average_duration=Avg('duration')
        ).order_by('technician_tl')

        # Convert average duration to a readable format
        response_data = {
            staff['technician_tl']: str(timedelta(seconds=staff['average_duration'].total_seconds())) if staff['average_duration'] else '00:00:00' for staff in average_durations
        }
        result = []
        for k,v in response_data.items():
            result.append({'staff_name':k,'duration':v})

        return Response({'message':result})
    
    '''def get(self, request):
        # Deserialize input data
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        start_date = serializer.validated_data.get('start_date')
        end_date = serializer.validated_data.get('end_date')

        # Start with the base queryset for Scheduled Surgeries
        surgeries = Monitoring.objects

        # Apply filters based on the provided date range
        if start_date and end_date:
            surgeries = surgeries.filter(surgery_date__range=[start_date, end_date])
        elif start_date:
            surgeries = surgeries.filter(surgery_date__gte=start_date)
        elif end_date:
            surgeries = surgeries.filter(surgery_date__lte=end_date)

        # Calculate surgery duration
        surgeries = surgeries.annotate(
            duration=ExpressionWrapper(
                F('wheeled_out_time_to_Post_op_ICU') - F('patient_wheel_in_OT'),
                output_field=fields.DurationField()
            )
        )

        # Filter out surgeries with no end time or start time
        surgeries = surgeries.exclude(wheeled_out_time_to_Post_op_ICU=None).exclude(patient_wheel_in_OT=None)

        # Calculate average duration for each doctor
        average_durations = surgeries.values('ot_staff_id').annotate(
            average_duration=Avg('duration')
        ).order_by('ot_staff_id')

        # Fetch OT staff names and format the response data
        data = []
        for average_duration in average_durations:
            ot_staff_id = average_duration['ot_staff_id']
            ot_staff_name = OTstaff.objects.get(ot_staff_id=ot_staff_id).name
            duration = average_duration['average_duration']
            duration_str = str(timedelta(seconds=duration.total_seconds())) if duration else '00:00:00'
            data.append({ot_staff_name: duration_str})

        # Construct the response
        result = {"Average Surgery Duration per OT Staff": data} if data else "No data found for the specified dates."
        return Response(result)''' 
    
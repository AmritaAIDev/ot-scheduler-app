from django.urls import path
from .views import UserCreate, LoginView
from rest_framework_simplejwt.views import TokenRefreshView
from . import views
from .views import UserCreate, UserUpdateView, LoginView, DoctorListCreateView,OTListCreateView, PatientListCreateView, ProcedureListCreateView, ScheduleListCreateView, MonitorListCreateView, OTstaffListCreateView, OTSchedulerView, OTNumberCountAPI, OTSurgeriesCountAPI, OTTimeSlotUsageAPI, AvgMonitoringStepsAPIView, OTUtilizationAPIView, DoctorNumberCountAPI,DoctorSurgeriesCountAPI, DoctorTimeSlotUsageAPI, DoctorAverageSurgeryDurationAPI, DepartmentNumberCountAPI, DepartmentSurgeryCountAPI, ProcedureCountAPI, ProcedureTimeComparisonAPI, SurgeryTypePercentageAPI, SurgeryTimingPercentageAPI, PatientCountAPI, GenderDistributionAPI, AgeDistributionAPI, SurgeryDateAPI, AvgTimeDifferenceAPIView, UniqueDepartmentSurgeryCountAPI, OTstaffNumberCountAPI,OTstaffSurgeriesCountAPI, OTstaffAverageSurgeryDurationAPI,ExcelProcessingView
from rest_framework_simplejwt.views import TokenRefreshView
from rest_framework.routers import DefaultRouter
#from django.contrib.auth.views import PasswordResetView, PasswordResetConfirmView, PasswordResetCompleteView


router = DefaultRouter()
router.register(r'doctors', DoctorListCreateView, basename='docotr-data-list-create')
router.register(r'OT', OTListCreateView, basename='OT-data-list-create')
router.register(r'patient', PatientListCreateView, basename='patient-list-create')
router.register(r'procedure', ProcedureListCreateView, basename='procedure-list-create')
router.register(r'schedule', ScheduleListCreateView, basename='schedule-list-create')
router.register(r'monitor', MonitorListCreateView, basename='monitor-list-create')
router.register(r'otstaff', OTstaffListCreateView, basename='ot-staff-list-create')


urlpatterns = [
    path('register/', UserCreate.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('ot-count/', OTNumberCountAPI.as_view(), name = 'ot_count'),
    path('ot-surgery-count/',OTSurgeriesCountAPI.as_view(), name = 'ot_surgery_count'),
    path('ot-time-slot-usage/', OTTimeSlotUsageAPI.as_view(), name='ot-time-slot-usage'),
    path('monitoring-steps-avg/',AvgMonitoringStepsAPIView.as_view()),
    path('percent-ot-utilization/',OTUtilizationAPIView.as_view()),
    path('avg-time-difference/', AvgTimeDifferenceAPIView.as_view(), name='avg-time-difference'),
    path('doctor-count/',DoctorNumberCountAPI.as_view(), name='doctor_count'),
    path('doctor-surgery-count/',DoctorSurgeriesCountAPI.as_view(), name='doctor-surgery-count'),
    path('doctor-time-slot-usage/',DoctorTimeSlotUsageAPI.as_view(), name = 'doctor-time-slot'),
    path('doctor-average-time/',DoctorAverageSurgeryDurationAPI.as_view()),
    path('department-count/',DepartmentNumberCountAPI.as_view()),
    path('surgery-department-count/',DepartmentSurgeryCountAPI.as_view()),
    path('unique-department-surgery-count/',UniqueDepartmentSurgeryCountAPI.as_view()),
    path('procedure-count/', ProcedureCountAPI.as_view()),
    path('procedure-time-comparison/', ProcedureTimeComparisonAPI.as_view(), name='procedure-time-comparison'),
    path('surgery-type-percentage/', SurgeryTypePercentageAPI.as_view()),
    path('surgery-timing-percentage/', SurgeryTimingPercentageAPI.as_view()),
    path('patient-count/', PatientCountAPI.as_view(), name='patient-count'),
    path('gender-distribution/', GenderDistributionAPI.as_view(), name='gender-distribution'),
    path('age-distribution/', AgeDistributionAPI.as_view(), name='age-distribution'),
    path('date-range/',SurgeryDateAPI.as_view()),
    path('ot-schedule/',OTSchedulerView.as_view()),
    path('ot_staff_count/',OTstaffNumberCountAPI.as_view()),
    path('otstaff-surgery-count/',OTstaffSurgeriesCountAPI.as_view()),
    path('otstaff-avg-time/',OTstaffAverageSurgeryDurationAPI.as_view()),
    #path('previous-end-times/', get_previous_end_times),
    #path('emergency-schedule',EmergencySchedulerView.as_view()),
    #path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    #path('token-valid/', TokenValidView.as_view(), name='token-valid'),
    #path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path('user/update/', UserUpdateView.as_view(), name='user-update'),
    #path('password-reset/', PasswordResetView.as_view(), name='password_reset'),
    #path('password-reset/confirm/<uidb64>/<token>/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    #path('password-reset/complete/', PasswordResetCompleteView.as_view(), name='password_reset_complete'),
    path('parse-excel/', ExcelProcessingView.as_view(), name='parse-excel'),
]


urlpatterns += router.urls
from django.urls import path
from .views import UserCreate, LoginView
from rest_framework_simplejwt.views import TokenRefreshView
from . import views
from .views import UserCreate, UserUpdateView, LoginView, DoctorListCreateView,OTListCreateView, PatientListCreateView, ProcedureListCreateView, ScheduleListCreateView, MonitorListCreateView
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


urlpatterns = [
    path('register/', UserCreate.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    #path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    #path('token-valid/', TokenValidView.as_view(), name='token-valid'),
    #path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path('user/update/', UserUpdateView.as_view(), name='user-update'),
    #path('password-reset/', PasswordResetView.as_view(), name='password_reset'),
    #path('password-reset/confirm/<uidb64>/<token>/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    #path('password-reset/complete/', PasswordResetCompleteView.as_view(), name='password_reset_complete'),
]


urlpatterns += router.urls
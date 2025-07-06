import 'package:arwa_app/core/services/patient_service.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/patient_info_response.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:arwa_app/features/home/presentation/screens/clinic_visit_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/home_visit_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingPatientInfo = false;
  Patient? _patient;
  BookingAppointmentData? _bookingData;
  List<dynamic>? _clinicReservations;
  List<dynamic>? _homeServices;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPatientInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatientInfo() async {
    setState(() {
      _isLoadingPatientInfo = true;
    });
    try {
      final patientRepository = GetIt.instance<PatientRepository>();
      final patientInfoResponse = await patientRepository.getPatientInfo();
      _patient = patientInfoResponse.patient;
      _bookingData = patientInfoResponse.bookingAppointmentData;
      _clinicReservations = patientInfoResponse.reservations;
      _homeServices = patientInfoResponse.homeServices;
    } catch (e) {
      debugPrint('Error fetching patient info: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPatientInfo = false;
        });
      }
    }
  }

  void _navigateToHomeVisit() {
    Get.to(() => const HomeVisitScreen(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
  }

  void _navigateToClinicVisit() {
    Get.to(() => const ClinicVisitScreen(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget _buildTabsSection(bool isDarkMode) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withOpacity(isDarkMode ? 0.2 : 0.1),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.grey[600],
                labelStyle: const TextStyle(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                tabs: [
                  Tab(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_hospital_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  context.tr('home.clinic_reservations'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontWeight: _tabController.index == 0 ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 14,
                                    color: _tabController.index == 0 
                                      ? AppColors.primary 
                                      : (isDarkMode ? Colors.white70 : Colors.grey[600]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Tab(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  context.tr('home.home_reservations'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontWeight: _tabController.index == 1 ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 14,
                                    color: _tabController.index == 1 
                                      ? AppColors.primary 
                                      : (isDarkMode ? Colors.white70 : Colors.grey[600]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildClinicReservationsTab(isDarkMode),
                  _buildHomeReservationsTab(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('app.name'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Get.to(() => const SettingsScreen(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
            },
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ],
      ),
      body: SafeArea(
          child: _isLoadingPatientInfo
            ? _buildShimmerLoading(isDarkMode)
              : RefreshIndicator(
                  onRefresh: _fetchPatientInfo,
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        _buildProfileCard(_patient!, isDarkMode),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context.tr('home.clinic_visit'),
                                Icons.local_hospital_outlined,
                                AppColors.primary,
                                _navigateToClinicVisit,
                                isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionButton(
                                context.tr('home.home_visit'),
                                Icons.home_outlined,
                                AppColors.secondary,
                                _navigateToHomeVisit,
                                isDarkMode,
                            ),
                          ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildTabsSection(isDarkMode),
                        ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card Shimmer
              Container(
                height: 140,
                decoration: BoxDecoration(
                    color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  ),
                ),
              const SizedBox(height: 28),
              
              // Action Buttons Shimmer
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                      color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Tabs Container Shimmer
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    // Tab Bar Shimmer
                    Container(
                      height: 48,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Tab Content Shimmer
                    ...List.generate(3, (index) => 
                      Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
      ),
    );
  }

  Widget _buildProfileCard(Patient user, bool isDarkMode) {
    String formatBirthDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return "-";
      try {
        final DateTime date = DateTime.parse(dateString);
        final String locale = context.locale.languageCode;
        final DateFormat formatter = DateFormat.yMMMMd(locale);
        return formatter.format(date);
      } catch (e) {
        return "-";
      }
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
            ),
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 60), // Space for the avatar
        Text(
                user.username ?? "-",
                style: TextStyle(
                  fontFamily: 'Almarai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
                formatBirthDate(user.birthDate),
          style: TextStyle(
                  fontFamily: 'Almarai',
            fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('home.file_number'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 12,
                              color: isDarkMode ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phone ?? "-",
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
      ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
                          Text(
                            context.tr('home.national_id'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 12,
                              color: isDarkMode ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.id.toString(),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
          ),
        ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Profile Circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              user.username!.isNotEmpty ? user.username![0].toUpperCase() : '',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 32,
                fontWeight: FontWeight.bold,
            color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color.withOpacity(isDarkMode ? 0.13 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 4),
          ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicReservationsTab(bool isDarkMode) {
    if (_clinicReservations == null || _clinicReservations!.isEmpty) {
      return _buildEmptyReservationsView(
        isDarkMode, 
        Icons.local_hospital_outlined, 
        AppColors.primary, 
        context.tr('home.no_clinic_reservations')
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clinicReservations!.length,
      itemBuilder: (context, index) {
        final reservation = _clinicReservations![index];
        return _buildReservationCard(
          isDarkMode,
          reservation['serviceId'].toString(),
          reservation['symptoms'] ?? '-',
          'P', // Status from reservation['status']
          Icons.local_hospital_outlined,
          AppColors.primary,
        );
      },
    );
  }

  Widget _buildHomeReservationsTab(bool isDarkMode) {
    if (_homeServices == null || _homeServices!.isEmpty) {
      return _buildEmptyReservationsView(
        isDarkMode, 
        Icons.home_outlined, 
        AppColors.secondary, 
        context.tr('home.no_home_reservations')
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _homeServices!.length,
      itemBuilder: (context, index) {
        final homeService = _homeServices![index];
        
        // Format the date if available
        String formattedDate = '-';
        if (homeService['visitDate'] != null) {
          try {
            final DateTime date = DateTime.parse(homeService['visitDate']);
            final String locale = context.locale.languageCode;
            final DateFormat formatter = DateFormat.yMMMd(locale);
            formattedDate = formatter.format(date);
          } catch (e) {
            formattedDate = '-';
          }
        }
        
        return _buildReservationCard(
          isDarkMode,
          homeService['service'] ?? '-',
          homeService['symptoms'] ?? '-',
          formattedDate,
          Icons.home_outlined,
          AppColors.secondary,
        );
      },
    );
  }
  
  Widget _buildEmptyReservationsView(bool isDarkMode, IconData icon, Color color, String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : color.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: isDarkMode ? Colors.white.withOpacity(0.5) : color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildReservationCard(
    bool isDarkMode, 
    String title, 
    String description, 
    String status, 
    IconData icon, 
    Color color
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.grey[100]!,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty && description != '-') ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'P':
        return Colors.amber;
      case 'C':
        return Colors.red;
      case 'D':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'P':
        return context.tr('reservation.pending');
      case 'C':
        return context.tr('reservation.cancelled');
      case 'D':
        return context.tr('reservation.done');
      default:
        return status;
    }
  }
} 
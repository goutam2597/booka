import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/providers/date_time_selection_provider.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/booking_text_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimeSelectionScreen extends StatelessWidget {
  final void Function(
    DateTime date,
    AvailableTimeResponseModel slot,
    int persons,
  )
  onNext;
  final ServicesModel service;
  final StaffModel staff;
  final VoidCallback onBack;

  const DateTimeSelectionScreen({
    super.key,
    required this.service,
    required this.staff,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DateTimeSelectionProvider(service: service, staff: staff)..init(),
      builder: (context, _) {
        final p = context.watch<DateTimeSelectionProvider>();
        return _buildScaffold(context, p);
      },
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    DateTimeSelectionProvider p, {
    int? visibleMax,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BookingTextButtonWidget(
          onTap: onBack,
          text: 'Prev Step',
          icon: Icons.arrow_back,
        ),
        BookingTextButtonWidget(
          iconRight: true,
          onTap: () => _handleNext(context, p, visibleMax: visibleMax),
          text: 'Next Step',
          icon: Icons.arrow_forward,
          iconColor: AppColors.primaryColor,
          textColor: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildScaffold(BuildContext context, DateTimeSelectionProvider p) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onBack();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CustomHeaderTextWidget(text: 'Select Date & Time'),
                ),
                const SizedBox(height: 16),

                /// Calendar card
                Card(
                  color: Colors.grey.shade100,
                  child: TableCalendar(
                    daysOfWeekHeight: 32,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontWeight: FontWeight.w500),
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    firstDay: DateTime.now(),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: p.focusedDay,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Previous'.tr,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      titleTextFormatter: (date, locale) => DateFormat.yMMMM(
                        locale,
                      ).format(date).toUpperCase().tr,

                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      rightChevronIcon: Row(
                        children: [
                          Text(
                            'Next'.tr,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),

                    selectedDayPredicate: (day) =>
                        p.selectedDate != null &&
                        isSameDay(p.selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      final isPast = selectedDay.isBefore(
                        DateTime.now().subtract(const Duration(days: 1)),
                      );
                      if (p.isWeekend(selectedDay) || isPast) return;
                      p.selectDate(selectedDay, focusedDay);
                      p.fetchHoursForDate(selectedDay);
                    },
                    enabledDayPredicate: (day) {
                      final isPast = day.isBefore(
                        DateTime.now().subtract(const Duration(days: 1)),
                      );
                      return !p.isWeekend(day) && !isPast;
                    },
                    weekendDays: p.globalWeekend.toList(),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final weekend = p.isWeekend(day);
                        return Center(
                          child: Opacity(
                            opacity: weekend ? 0.35 : 1.0,
                            child: Text('${day.day}'),
                          ),
                        );
                      },

                      todayBuilder: (context, day, focusedDay) {
                        final isWeekend = p.isWeekend(day);

                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isWeekend
                                  ? Colors.grey.shade400
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (p.selectedDate == null) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 22, top: 12, bottom: 24),
                    child: Text(
                      "Pick a date to see available time slots.".tr,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(context, p),
                ] else
                  FutureBuilder<List<AvailableTimeResponseModel>>(
                    future: p.availableHoursFuture,
                    builder: (context, snapshot) {
                      int? visibleMax;
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final int? rawMax = snapshot.data!.first.maxPerson;
                        if (rawMax != null && rawMax > 0) {
                          // Previously capped to 3; now show full maxPerson from API
                          visibleMax = rawMax;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTimeSlotSection(context, p, snapshot),

                          if (visibleMax != null && visibleMax > 0) ...[
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Align(
                                alignment: Alignment.center,
                                child: CustomHeaderTextWidget(
                                  text: 'Number of Persons'.tr,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 180,
                              child: DropdownButtonFormField<int>(
                                borderRadius:  BorderRadius.circular(12),
                                dropdownColor: Colors.white,
                                initialValue: p.selectedPersons,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                hint: Text('Select persons'.tr),
                                items: List.generate(visibleMax, (i) {
                                  final value = i + 1;
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      '$value ${value == 1 ? 'Person'.tr : 'Persons'.tr}',
                                    ),
                                  );
                                }),
                                onChanged: (val) {
                                  if (val != null) p.selectPersons(val);
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          _buildNavigationButtons(
                            context,
                            p,
                            visibleMax: visibleMax,
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext(
    BuildContext context,
    DateTimeSelectionProvider p, {
    int? visibleMax,
  }) {
    if (p.selectedDate == null || p.selectedTime == null) {
      CustomSnackBar.show(
        context,
        "Please select a date and a time slot!",
        title: 'Error!',
        icon: Icons.error_outline,
        iconBgColor: AppColors.snackError,
      );
      return;
    }
    if (visibleMax != null && visibleMax > 0) {
      if (p.selectedPersons == null) {
        CustomSnackBar.show(
          context,
          "Please select number of persons!",
          title: 'Error!',
          icon: Icons.error_outline,
          iconBgColor: AppColors.snackError,
        );
        return;
      }
      onNext(p.selectedDate!, p.selectedTime!, p.selectedPersons!);
      return;
    }
    onNext(p.selectedDate!, p.selectedTime!, 1);
  }

  Widget _buildTimeSlotSection(
    BuildContext context,
    DateTimeSelectionProvider p,
    AsyncSnapshot<List<AvailableTimeResponseModel>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CustomCPI());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 22, top: 12, bottom: 24),
        child: Text(
          "No slots available for this date.",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    final timeSlots = snapshot.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: CustomHeaderTextWidget(text: 'Available Time Slots'.tr),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: timeSlots.map((time) {
            final isSelected = p.selectedTime?.id == time.id;
            return ChoiceChip(
              showCheckmark: false,
              label: Text(
                '${time.startTime} - ${time.endTime}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              onSelected: (_) => p.selectTime(time),
            );
          }).toList(),
        ),
      ],
    );
  }
}

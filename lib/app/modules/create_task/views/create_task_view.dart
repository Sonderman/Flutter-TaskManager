import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/modules/create_task/controllers/create_task_controller.dart';

/// View for the Create Task screen.
///
/// Displays a form allowing the user to enter task details (name, period, optional time)
/// and save the new task. Uses [GetView] to access the [CreateTaskController].
class CreateTaskView extends GetView<CreateTaskController> {
  const CreateTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Task"), centerTitle: true),
      // Floating Action Button to trigger saving the task.
      floatingActionButton: FloatingActionButton.extended(
        // Make onPressed async and await the controller method
        onPressed: () async {
          await controller.saveTask();
        },
        icon: const Icon(Icons.save_alt_outlined),
        label: const Text("Save Task"),
        tooltip: 'Save Task',
      ),
      body: SingleChildScrollView(
        // Padding around the form content.
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        // Form widget to enable validation.
        child: Form(
          key: controller.formKey, // Link form key from controller
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
            children: [
              // Section for selecting the task period.
              _buildPeriodSelector(),
              SizedBox(height: 25.h), // Responsive spacing
              // Section for entering the task name.
              _buildTaskNameInput(),
              SizedBox(height: 25.h), // Responsive spacing
              // Section for picking the time (visible only for "Daily" period).
              _buildTimePicker(context),
              SizedBox(height: 80.h), // Add space at the bottom for FAB
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the segmented button selector for choosing the task period.
  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            'Task Period',
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Obx(
              () => SegmentedButton<String>(
                segments:
                    controller.periodOptions.map((period) {
                      return ButtonSegment<String>(
                        value: period,
                        label: Text(period, style: TextStyle(fontSize: 14.sp)),
                        icon: Icon(
                          period == 'Daily'
                              ? Icons.calendar_view_day
                              : period == 'Weekly'
                              ? Icons.calendar_view_week
                              : Icons.calendar_view_month,
                          size: 20.sp,
                        ),
                      );
                    }).toList(),
                selected: {controller.selectedPeriod.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.selectedPeriod.value = newSelection.first;
                },
                style: Theme.of(context).segmentedButtonTheme.style,
                showSelectedIcon: true,
                multiSelectionEnabled: false,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds the text input field for the task name.
  Widget _buildTaskNameInput() {
    return TextFormField(
      controller: controller.nameController, // Link to controller's text controller
      onTapOutside: (event) {
        FocusScope.of(Get.context!).unfocus();
      },
      decoration: InputDecoration(
        labelText: 'Task Name',
        hintText: 'Enter the name of your task',
        prefixIcon: const Icon(Icons.task_alt_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), // Responsive radius
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 16.w,
        ), // Responsive padding
      ),
      style: TextStyle(fontSize: 16.sp), // Responsive font size
      validator: controller.validateTaskName, // Link to controller's validator function
      textInputAction: TextInputAction.done, // Action button on keyboard
    );
  }

  /// Builds the time picker input field, visible only for the "Daily" period.
  Widget _buildTimePicker(BuildContext context) {
    // Obx makes the Visibility widget rebuild when controller.selectedPeriod changes.
    return Obx(
      () => Visibility(
        // Show only if the selected period is "Daily".
        visible: controller.selectedPeriod.value == "Daily",
        child: TextFormField(
          controller: controller.timeController, // Link to controller's time text controller
          readOnly: true, // Make the field read-only, interaction via onTap
          onTap: () => controller.pickTime(context), // Call controller's pickTime on tap
          decoration: InputDecoration(
            labelText: 'Time (Optional)',
            hintText: 'Select a time for the task',
            prefixIcon: const Icon(Icons.access_time_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded), // Visual cue for picker
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ), // Responsive radius
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 16.w,
            ), // Responsive padding
          ),
          style: TextStyle(fontSize: 16.sp), // Responsive font size
        ),
      ),
    );
  }
}

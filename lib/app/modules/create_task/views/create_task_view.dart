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
      appBar: AppBar(
        title: const Text("Create New Task"),
        centerTitle: true,
      ),
      // Floating Action Button to trigger saving the task.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.saveTask, // Call controller's save method
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

  /// Builds the dropdown selector for choosing the task period.
  Widget _buildPeriodSelector() {
    // Obx makes the DropdownButton rebuild when controller.selectedPeriod changes.
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedPeriod.value, // Current value from controller
        // List of DropdownMenuItem widgets built from controller.periodOptions.
        items: controller.periodOptions.map((String period) {
          return DropdownMenuItem<String>(
            value: period,
            child: Text(period),
          );
        }).toList(),
        // Callback function when a new period is selected.
        onChanged: controller.changePeriod,
        // Styling for the dropdown.
        decoration: InputDecoration(
          labelText: 'Task Period',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), // Responsive radius
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w), // Responsive padding
        ),
        // Style for the dropdown text.
        style: TextStyle(fontSize: 16.sp), // Responsive font size
        icon: const Icon(Icons.arrow_drop_down_rounded), // Dropdown icon
        isExpanded: true, // Make dropdown take full width
      ),
    );
  }

  /// Builds the text input field for the task name.
  Widget _buildTaskNameInput() {
    return TextFormField(
      controller: controller.nameController, // Link to controller's text controller
      decoration: InputDecoration(
        labelText: 'Task Name',
        hintText: 'Enter the name of your task',
        prefixIcon: const Icon(Icons.task_alt_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), // Responsive radius
        contentPadding:
            EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w), // Responsive padding
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
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), // Responsive radius
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w), // Responsive padding
          ),
          style: TextStyle(fontSize: 16.sp), // Responsive font size
        ),
      ),
    );
  }
}

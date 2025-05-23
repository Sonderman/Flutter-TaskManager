import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taskmanager/app/data/models/task_model.dart';
import 'package:taskmanager/app/modules/home/controllers/home_controller.dart';
import 'package:taskmanager/app/modules/home/views/keep_alive_wrapper.dart';

/// The main view for the Home screen.
///
/// Displays the task list categorized by period (Daily, Weekly, Monthly) using tabs,
/// allows switching between active and finished tasks via the bottom navigation bar,
/// provides navigation to create tasks and settings.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and settings icon
      appBar: AppBar(
        // Obx ensures the title updates reactively when the bottom nav index changes.
        title: Obx(
          () =>
              Text(controller.currentBottomNavIndex.value == 0 ? "Active Tasks" : "Finished Tasks"),
        ),
        centerTitle: true,
        actions: [
          // Settings icon button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.goToSettings, // Navigate to settings screen
            tooltip: 'Settings',
          ),
        ],
      ),
      // Body containing the TabBarView to display tasks for the selected period
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
              indicatorColor:
                  Theme.of(context).brightness == Brightness.dark ? Colors.orange : null,
              dividerHeight: 1.sp,
              indicatorWeight: 4.sp,
              controller: controller.tabController, // Link to the controller's TabController
              tabs:
                  controller.periods
                      .map((period) => _buildTabItem(period)) // Build tabs dynamically
                      .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children:
                    controller.periods
                        .map(
                          (period) => Obx(
                            () => KeepAliveWrapper(
                              key: ValueKey('${period}_${controller.currentBottomNavIndex.value}'),
                              // Pass the period to the buildTaskList method
                              child: _buildTaskList(period),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button to navigate to the create task screen
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToCreateTask, // Call controller method on press
        tooltip: 'Create Task',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // Position FAB in the center
      // Bottom Navigation Bar to switch between Active and Finished tasks
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentBottomNavIndex.value,
          onTap: controller.changeBottomNavIndex,
          iconSize: 40, // Increased icon size
          selectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.orange : null,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14),
          elevation: 8, // Add shadow to bar
          type: BottomNavigationBarType.fixed, // Better visual consistency
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt, color: Get.theme.colorScheme.onSurface.withOpacity(0.6)),
              activeIcon: Icon(
                Icons.list_alt,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Get.theme.colorScheme.primary,
              ),
              label: "Active",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.done_all, color: Get.theme.colorScheme.onSurface.withOpacity(0.6)),
              activeIcon: Icon(
                Icons.done_all,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Get.theme.colorScheme.primary,
              ),
              label: "Finished",
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single tab item for the TabBar.
  /// [name]: The text label for the tab.
  Widget _buildTabItem(String name) {
    // Use ScreenUtil for responsive font size
    return Tab(
      child: Text(
        name,
        style: TextStyle(fontSize: 18.sp, fontFamily: 'Roboto', fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Builds the list view that displays tasks for the given period.
  ///
  /// [period]: The period to display tasks for (Daily, Weekly, Monthly)
  /// Uses Obx to reactively update the list when dependencies change (e.g., _allTasks, currentBottomNavIndex).
  Widget _buildTaskList(String period) {
    return Obx(() {
      // Get the filtered tasks for the specific period using the controller's getter
      final tasks = controller.getTasksForView(period);
      // Show a message if the filtered list is empty
      if (tasks.isEmpty) {
        return Center(
          child: Text(
            "No tasks found for this section.",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        );
      }
      // Build the list using ListView.separated
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h), // Responsive padding
        // Use the length of the locally fetched tasks list
        itemCount: tasks.length,
        itemBuilder: (_, index) {
          // Get the task from the locally fetched list
          final task = tasks[index];
          return _buildTaskItem(task); // Build each task item
        },
        separatorBuilder: (_, index) => SizedBox(height: 10.h), // Responsive spacing
      );
    });
  }

  /// Builds a single task item card with Dismissible functionality.
  /// [task]: The [Task] object to display.
  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.id), // Unique key for Dismissible
      // Configure swipe directions based on task completion status
      direction: DismissDirection.horizontal,
      // Confirmation logic before dismissing
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (controller.currentBottomNavIndex.value == 1) {
            // Swipe right on finished task: Mark as active
            await controller.markTaskAsDone(task, isDone: false);
          } else {
            // Swipe right on active task: Mark as finished
            await controller.markTaskAsDone(task, isDone: true);
          }
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          // Swipe left (active) or right (finished): Delete
          await controller.deleteTask(task.id, task.name);
          return false; // Don't actually dismiss, controller handles removal
        }
        return false; // Should not happen
      },
      // Background shown when swiping right (Mark as active)
      background: _buildDismissibleBackground(
        color: controller.currentBottomNavIndex.value == 0 ? Colors.green : Colors.blue,
        icon: controller.currentBottomNavIndex.value == 0 ? Icons.done : Icons.arrow_back,
        alignment: Alignment.centerLeft,
        label: controller.currentBottomNavIndex.value == 0 ? "Mark as Done" : "Mark as Active",
      ),
      // Background shown when swiping left (Delete)
      secondaryBackground: _buildDismissibleBackground(
        color: Colors.red,
        icon: Icons.delete_sweep,
        alignment: Alignment.centerRight,
        label: "Delete",
      ),
      // The actual task item content displayed in a Card
      child: Stack(
        children: [
          Card(
            elevation: 2, // Subtle shadow
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 8.h,
                horizontal: 16.w,
              ), // Responsive padding
              // Leading icon (check mark) only shown for active tasks
              leading:
                  controller.currentBottomNavIndex.value == 0
                      ? Icon(Icons.radio_button_unchecked, color: Get.theme.colorScheme.primary)
                      : Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ), // Show check for finished tasks
              // Task name
              title: Text(
                task.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  // Add strikethrough if task is done
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                  color: task.isDone ? Colors.grey : null,
                ),
              ),
              // Optional time display for daily tasks
              subtitle:
                  task.time != null && task.period == "Daily"
                      ? Text(task.time!, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]))
                      : null,
              // Trailing delete icon (visual cue, action handled by Dismissible)
              trailing: Builder(
                builder:
                    (context) => Icon(
                      Icons.delete_outline,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.red
                              : Colors.grey[400],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget to build the background for the Dismissible item.
  Widget _buildDismissibleBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0), // Match Card shape
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w), // Responsive padding
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp), // Responsive icon size
          SizedBox(height: 4.h), // Responsive spacing
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ), // Responsive text
          ),
        ],
      ),
    );
  }
}

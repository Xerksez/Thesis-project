import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:web_app/services/task_service.dart';
import 'package:web_app/themes/styles.dart';
import 'package:universal_html/html.dart' as html;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> addresses = [];
  Map<int, List<Map<String, dynamic>>> jobs = {};
  Map<int, List<Map<String, dynamic>>> actualizations = {};
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

 @override
void dispose() {
  // Unfocus any text fields or HTML inputs before disposing
  FocusScope.of(context).unfocus();
  super.dispose();
}

  
  Future<void> _fetchData() async {
  try {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    final userId = _getCookieValue('userId'); // Retrieve userId from cookies
    if (userId == null) throw Exception('User ID is missing from cookies.');

    addresses = await TaskService.getAddressesForUser(int.parse(userId));
    print('[UI] Addresses fetched: $addresses');

    for (final address in addresses) {
      final addressId = address['addressId'];

      try {
        final tasks = await TaskService.fetchTasksByAddress(addressId);
        jobs[addressId] = tasks;

        for (final job in tasks) {
          final jobId = job['id'];
          try {
            final jobActualizations = await TaskService.fetchJobActualizations(jobId);
            actualizations[jobId] = jobActualizations;
          } catch (e) {
            actualizations[jobId] = [];
            print('[UI] Error fetching actualizations for job $jobId: $e');
          }
        }
      } catch (e) {
        jobs[addressId] = [];
        print('[UI] Error fetching tasks for address $addressId: $e');
      }
    }
  } catch (e) {
    setState(() {
      _isError = true;
    });
    print('Error fetching data: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}





String? _getCookieValue(String key) {
  final cookies = html.window.document.cookie; // Get cookies from document
  if (cookies != null) {
    for (final cookie in cookies.split(';')) {
      final parts = cookie.split('=');
      if (parts[0].trim() == key) {
        return parts[1].trim();
      }
    }
  }
  return null;
}

Future<void> _editTaskDialog(
    int jobId, String jobName, DateTime currentStartTime, DateTime currentEndTime) async {
  final nameController = TextEditingController(text: jobName);
  DateTime? startTime = currentStartTime;
  DateTime? endTime = currentEndTime;
  bool allDay = false;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppStyles.transparentWhite, // Apply transparent background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners for dialog
          ),
          title: const Text('Edit Task', style: AppStyles.headerStyle), // Styled title
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  cursorColor: AppStyles.cursorColor,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startTime ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => startTime = date);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // Black text color for Start Time
                      ),
                      child: const Text('Start Time'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      startTime != null
                          ? '${startTime!.year}-${startTime!.month.toString().padLeft(2, '0')}-${startTime!.day.toString().padLeft(2, '0')}'
                          : 'Select Start Time',
                      style: AppStyles.textStyle, // Styled text
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endTime ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => endTime = date);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // Black text color for End Time
                      ),
                      child: const Text('End Time'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      endTime != null
                          ? '${endTime!.year}-${endTime!.month.toString().padLeft(2, '0')}-${endTime!.day.toString().padLeft(2, '0')}'
                          : 'Select End Time',
                      style: AppStyles.textStyle, // Styled text
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: allDay,
                      onChanged: (value) {
                        setState(() {
                          allDay = value!;
                        });
                      },
                    ),
                    const Text('All Day', style: AppStyles.textStyle), // Styled text
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Black text color for Cancel
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && startTime != null && endTime != null) {
                  // Adjust the start and end times based on whether "All Day" is checked
                  final adjustedStartTime = allDay
                      ? DateTime(startTime!.year, startTime!.month, startTime!.day, 0, 0, 0).toUtc()
                      : startTime!.toUtc();

                  final adjustedEndTime = allDay
                      ? DateTime(endTime!.year, endTime!.month, endTime!.day, 23, 59, 59).toUtc()
                      : DateTime(endTime!.year, endTime!.month, endTime!.day + 1, 0, 0, 0).toUtc();

                  try {
                    await TaskService.editTask(
                      jobId: jobId,
                      patchOperations: [
                        {'op': 'replace', 'path': '/name', 'value': nameController.text},
                        {'op': 'replace', 'path': '/startTime', 'value': adjustedStartTime.toIso8601String()},
                        {'op': 'replace', 'path': '/endTime', 'value': adjustedEndTime.toIso8601String()},
                        {'op': 'replace', 'path': '/allDay', 'value': allDay},
                      ],
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update task.')),
                    );
                  }
                }
              },
              style: AppStyles.buttonStyle(), // Styled button
              child: const Text('Save Changes'),
            ),
          ],
        ),
      );
    },
  );
}


  Future<void> _reloadDataForJob(int jobId) async {
    try {
      final jobActualizations = await TaskService.fetchJobActualizations(jobId);
      setState(() {
        actualizations[jobId] = jobActualizations;
      });
      print('[UI] Reloaded actualizations for Job ID: $jobId: $jobActualizations');
    } catch (e) {
      setState(() {
        actualizations[jobId] = [];
      });
      print('[UI] No actualizations found for Job ID: $jobId');
    }
  }

  Future<void> _toggleJobActualizationStatus(int actualizationId, int jobId) async {
    try {
      await TaskService.toggleJobActualizationStatus(actualizationId);
      await _reloadDataForJob(jobId);
      print('[UI] Toggled status for Job Actualization ID: $actualizationId');
    } catch (e) {
      print('Error toggling status for job actualization ID $actualizationId: $e');
    }
  }

Future<void> _deleteJob(int jobId, int addressId) async {
  try {
    await TaskService.deleteJob(jobId);
    print('[UI] Successfully deleted Job ID: $jobId');

    setState(() {
      jobs[addressId] = jobs[addressId]!.where((job) => job['id'] != jobId).toList();
      actualizations.remove(jobId);
      if (jobs[addressId]!.isEmpty) {
        jobs.remove(addressId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job deleted successfully.')),
    );

    // Reload the current screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => super.widget,
        transitionDuration: Duration.zero, // No animation
        reverseTransitionDuration: Duration.zero, // No animation
      ),
    );
  } catch (e) {
    print('Error deleting Job ID: $jobId: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete job: $e')),
    );
  }
}

 Future<void> _addTask(int addressId) async {
  final nameController = TextEditingController();
  final messageController = TextEditingController();
  DateTime? startTime, endTime;

  await showDialog(
  context: context,
  builder: (context) {
    bool allDay = false;
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppStyles.transparentWhite, // Apply transparent background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners for dialog
        ),
        title: const Text('Add Task', style: AppStyles.headerStyle), // Styled title
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                cursorColor: AppStyles.cursorColor,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                cursorColor: AppStyles.cursorColor,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => startTime = date);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black, // Black text color for Start Time
                    ),
                    child: const Text('Start Time'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    startTime != null
                        ? '${startTime!.year}-${startTime!.month.toString().padLeft(2, '0')}-${startTime!.day.toString().padLeft(2, '0')}'
                        : 'Select Start Time',
                    style: AppStyles.textStyle, // Styled text
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => endTime = date);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black, // Black text color for End Time
                    ),
                    child: const Text('End Time'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    endTime != null
                        ? '${endTime!.year}-${endTime!.month.toString().padLeft(2, '0')}-${endTime!.day.toString().padLeft(2, '0')}'
                        : 'Select End Time',
                    style: AppStyles.textStyle, // Styled text
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: allDay,
                    onChanged: (value) {
                      setState(() {
                        allDay = value!;
                      });
                    },
                  ),
                  const Text('All Day', style: AppStyles.textStyle), // Styled text
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Cancel
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  messageController.text.isNotEmpty &&
                  startTime != null &&
                  endTime != null) {
                final adjustedStartTime = allDay
                    ? DateTime(startTime!.year, startTime!.month, startTime!.day, 0, 0, 0).toUtc()
                    : startTime!.toUtc();
                final adjustedEndTime = allDay
                    ? DateTime(endTime!.year, endTime!.month, endTime!.day, 23, 59, 59).toUtc()
                    : endTime!.toUtc();

                await TaskService.addJob(
                  name: nameController.text,
                  message: messageController.text,
                  startTime: adjustedStartTime,
                  endTime: adjustedEndTime,
                  allDay: allDay,
                  addressId: addressId,
                );
                Navigator.pop(context);
                await _fetchData();
              }
            },
            style: AppStyles.buttonStyle(), // Styled button
            child: const Text('Add'),
          ),
        ],
      ),
    );
  },
);

}

Future<void> _manageUsers(int jobId, int addressId) async {
  try {
    final assignedUsers = await TaskService.fetchAssignedUsers(jobId);
    final allTeammates = await TaskService.fetchTeamMembers(addressId);

    final availableUsers = allTeammates
        .where((user) => !assignedUsers.any((assigned) => assigned['id'] == user['id']))
        .toList();

    List<int> selectedUserIds = [];
    List<Map<String, dynamic>> selectedUsers = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppStyles.transparentWhite, // Apply transparent background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners for dialog
          ),
          title: const Text(
            'Manage Users',
            style: AppStyles.headerStyle, // Styled title
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (assignedUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No users currently assigned to this job.',
                      style: AppStyles.textStyle, // Styled text
                    ),
                  ),
                if (assignedUsers.isNotEmpty)
                  ...assignedUsers.map((user) {
                    return ListTile(
                      title: Text(
                        '${user['name']} ${user['surname']}',
                        style: AppStyles.textStyle, // Styled text
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color.fromARGB(255, 0, 0, 0)),
                        onPressed: () async {
                          await TaskService.deleteUserFromJob(jobId, user['id']);
                          setState(() {
                            assignedUsers.remove(user);
                            availableUsers.add(user);
                          });
                          await _reloadDataForJob(jobId);
                        },
                      ),
                    );
                  }).toList(),
                if (assignedUsers.isNotEmpty) const Divider(), // Divider between sections
                if (availableUsers.isNotEmpty)
                  ...availableUsers.map((user) {
                    final isSelected = selectedUserIds.contains(user['id']);
                    return CheckboxListTile(
                      title: Text(
                        '${user['name']} ${user['surname']}',
                        style: AppStyles.textStyle, // Styled text
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedUserIds.add(user['id']);
                            selectedUsers.add(user);
                          } else {
                            selectedUserIds.remove(user['id']);
                            selectedUsers.removeWhere((u) => u['id'] == user['id']);
                          }
                        });
                      },
                      activeColor: Colors.blue, // Checkbox color
                      controlAffinity: ListTileControlAffinity.leading, // Checkbox position
                    );
                  }).toList(),
                if (availableUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No unassigned users available to add.',
                      style: AppStyles.textStyle, // Styled text
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Black text color for Cancel
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedUserIds.isNotEmpty) {
                  for (int userId in selectedUserIds) {
                    await TaskService.assignUserToTask(jobId, userId);
                    final assignedUser =
                        availableUsers.firstWhere((user) => user['id'] == userId);
                    setState(() {
                      availableUsers.remove(assignedUser);
                      assignedUsers.add(assignedUser);
                    });
                  }
                  selectedUserIds.clear();
                  selectedUsers.clear();
                  await _reloadDataForJob(jobId);
                }
                Navigator.pop(context);
              },
              style: AppStyles.buttonStyle(), // Styled button
              child: const Text('Add Selected Users'),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    print('Error managing users for job ID $jobId: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to manage users: $e')),
    );
  }
}




  Widget _buildImageList(List<String> images) {
    return images.isNotEmpty
        ? SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index];
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Image.network(imageUrl, fit: BoxFit.contain),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          )
        : const Text('No images available.');
  }

@override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return const Center(
        child: Text(
          'Failed to load data',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(144, 81, 85, 87),
        actions: [
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: _fetchData, // Trigger refresh function
      tooltip: 'Refresh',
    ),
  ],
      ),
      body: Container(
        decoration: AppStyles.backgroundDecoration,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: addresses.map((address) {
            final addressId = address['addressId'];
            final addressName = address['name'];
            final addressJobs = jobs[addressId] ?? [];

            return Card(
              color: AppStyles.transparentWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addressName,
                      style: AppStyles.headerStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppStyles.primaryBlue),
                      onPressed: () => _addTask(addressId),
                    ),
                  ],
                ),
                children: addressJobs.isEmpty
                    ? [
                        const ListTile(
                          title: Text(
                            'There are no jobs for this team',
                            style: AppStyles.textStyle,
                          ),
                        ),
                      ]
                    : addressJobs.map((job) {
                        final jobId = job['id'];
                        final jobName = job['name'];
                        final jobActualizations = actualizations[jobId] ?? [];

                        return ExpansionTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(jobName, style: AppStyles.textStyle),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Color.fromARGB(255, 0, 0, 0)),
   onPressed: () {
  try {
    // Parse 'startTime' and 'endTime' correctly
    final startTime = job['startTime'] != null
        ? (job['startTime'] is String
            ? DateTime.parse(job['startTime']).toUtc() // Parse string and ensure UTC
            : job['startTime'] is DateTime
                ? (job['startTime'] as DateTime).toUtc() // Ensure DateTime is UTC
                : null)
        : null;

    final endTime = job['endTime'] != null
        ? (job['endTime'] is String
            ? DateTime.parse(job['endTime']).toUtc() // Parse string and ensure UTC
            : job['endTime'] is DateTime
                ? (job['endTime'] as DateTime).toUtc() // Ensure DateTime is UTC
                : null)
        : null;

    // Validate parsed times
    if (startTime != null && endTime != null) {
      // Call the edit dialog with properly parsed values
      _editTaskDialog(
        jobId,
        jobName,
        startTime,
        endTime,
      );
    } else {
      // Show error message for invalid times
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid start time or end time. Please check the job data.'),
        ),
      );
    }
  } catch (e) {
    // Handle parsing or other unexpected errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred: $e'),
      ),
    );
    print('Error parsing startTime or endTime: $e');
  }
},





                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.person_add,
                                            color: AppStyles.primaryBlue),
                                        onPressed: () =>
                                            _manageUsers(jobId, addressId),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color:
                                                Color.fromARGB(255, 10, 10, 10)),
                                        onPressed: () =>
                                            _deleteJob(jobId, addressId),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (jobActualizations.isNotEmpty)
                                const Divider(
                                  color: Colors.black26,
                                  thickness: 1,
                                  indent: 8,
                                  endIndent: 8,
                                ),
                            ],
                          ),
                          children: jobActualizations.isEmpty
                              ? [
                                  const ListTile(
                                    title: Text(
                                      'Workers did not post any updates on their jobs',
                                      style: AppStyles.textStyle,
                                    ),
                                  ),
                                ]
                              : jobActualizations.map((actualization) {
                                  final images =
                                      actualization['jobImageUrl'] as List<String>;
                                  final isDone =
                                      actualization['isDone'] == true;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          actualization['message'],
                                          style: AppStyles.textStyle,
                                        ),
                                        trailing: isDone
                                            ? ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                label: const Text('Accepted'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 2, 107, 245),
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  await _toggleJobActualizationStatus(
                                                      actualization['id'],
                                                      jobId);
                                                },
                                              )
                                            : ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons
                                                      .radio_button_unchecked,
                                                  color: Color.fromARGB(
                                                      255, 1, 112, 240),
                                                ),
                                                label: const Text('Accept'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      const Color(0xFF026BF5),
                                                ),
                                                onPressed: () async {
                                                  await _toggleJobActualizationStatus(
                                                      actualization['id'],
                                                      jobId);
                                                },
                                              ),
                                      ),
                                      _buildImageList(images),
                                    ],
                                  );
                                }).toList(),
                        );
                      }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


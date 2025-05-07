import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/themes/styles.dart';
import 'widgets/task_update_dialog.dart';
import '../../../shared/config/config.dart';

class TaskDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String taskDate;
  final int taskId;

  const TaskDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.taskDate,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<Map<String, dynamic>> jobActualizations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobActualizations();
  }

  // Fetch all job actualizations for the task
  Future<void> _fetchJobActualizations() async {
    print('Fetching Job Actualizations for Job ID: ${widget.taskId}');

    try {
      // Fetch token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('[TaskDetailScreen] Error: Token is missing or empty.');
        throw Exception('Token not found in SharedPreferences');
      }

      // Make the API request with the token in the Authorization header
      final response = await http.get(
        Uri.parse(AppConfig.getJobActualizationEndpoint(widget.taskId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Job Actualizations Fetched: $jsonData');

        setState(() {
          jobActualizations = List<Map<String, dynamic>>.from(jsonData);
          isLoading = false;
        });
      } else {
        print('Failed to fetch actualizations. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching job actualizations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showTaskUpdateDialog(BuildContext context) {
    // Debugging the jobId being passed to the TaskUpdateDialog
    print('Opening Task Update Dialog - Job ID: ${widget.taskId}');

    showDialog(
      context: context,
      builder: (_) => TaskUpdateDialog(
        jobId: widget.taskId, // Pass the taskId (jobId)
        onSave: (comment, images) {
          // Debugging after saving
          print('Task Updated - Job ID: ${widget.taskId}');
          print('Comment: $comment');
          print('Photo: ${images.map((img) => img.path).toList()}');

          // Refresh job actualizations
          _fetchJobActualizations();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(decoration: AppStyles.backgroundDecoration),
        Container(color: AppStyles.filterColor.withOpacity(0.75)),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppStyles.transparentWhite,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.title,
                              style: AppStyles.formTitleStyle,
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 245, 243, 243)),
                              onPressed: _fetchJobActualizations,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.description, 'Description', widget.description),
                        _buildDetailRow(Icons.timer, 'Start', widget.startTime),
                        _buildDetailRow(Icons.timer_off, 'End', widget.endTime),
                        _buildDetailRow(Icons.event, 'Date', widget.taskDate),

                        // Display job actualizations
                        if (jobActualizations.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          ...jobActualizations.map((actualization) {
                            return Column(
                              children: [
                                _buildJobActualizationCard(actualization),
                                const Divider(color: Colors.white),
                              ],
                            );
                          }).toList(),
                        ],

                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _showTaskUpdateDialog(context),
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                            label: const Text('Add actualization'),
                            style: AppStyles.buttonStyle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$title: $content',
              style: AppStyles.textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobActualizationCard(Map<String, dynamic> actualization) {
    final String message = actualization['message'] ?? '';
    final List<String> images = List<String>.from(actualization['jobImageUrl'] ?? []);
    final bool isDone = actualization['isDone'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.message, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Comment: $message',
                style: AppStyles.textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.cancel,
              color: isDone ? Color.fromARGB(255, 11, 164, 211) : const Color.fromARGB(255, 243, 242, 242),
              size: 24,
            ),
          ],
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildDisplayImageCarousel(images),
        ],
      ],
    );
  }

  // Carousel for displaying images from the API
  Widget _buildDisplayImageCarousel(List<String> urls) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
      ),
      items: urls.map((url) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(url),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://buildbuddybucket.s3.amazonaws.com/$url',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 100, color: Colors.white54),
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Image.network(
                'https://buildbuddybucket.s3.amazonaws.com/$imageUrl',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 150, color: Colors.white54),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

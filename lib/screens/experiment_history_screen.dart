import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ExperimentHistoryScreen extends StatefulWidget {
  const ExperimentHistoryScreen({super.key});

  @override
  State<ExperimentHistoryScreen> createState() =>
      _ExperimentHistoryScreenState();
}

class _ExperimentHistoryScreenState
    extends State<ExperimentHistoryScreen> {
  List<Map<String, dynamic>> experiments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExperiments();
  }

  Future<void> loadExperiments() async {
    final data =
    await DatabaseHelper.instance.getExperiments();

    if (!mounted) return;

    setState(() {
      experiments = data;
      isLoading = false;
    });
  }

  Future<void> deleteExperiment(int id) async {
    await DatabaseHelper.instance.deleteExperiment(id);

    await loadExperiments();
  }

  Future<void> clearAllExperiments() async {
    await DatabaseHelper.instance.clearExperiments();

    await loadExperiments();
  }

  Color activityColor(double activity) {
    if (activity >= 75) {
      return Colors.green;
    }

    if (activity >= 40) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Experiment History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,

        actions: [
          if (experiments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Clear History?',
                      ),
                      content: const Text(
                        'This will permanently delete all saved experiments.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            clearAllExperiments();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32),
        ),
      )

          : experiments.isEmpty
          ? _buildEmptyState()

          : RefreshIndicator(
        onRefresh: loadExperiments,

        child: ListView.builder(
          padding: const EdgeInsets.all(20),

          itemCount: experiments.length,

          itemBuilder: (context, index) {
            final experiment =
            experiments[index];

            return _buildExperimentCard(
              experiment,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              Icons.science_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Experiments Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Run an experiment in the Virtual Laboratory and your results will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentCard(
      Map<String, dynamic> experiment) {
    final double activity =
    (experiment['activity'] as num).toDouble();

    final Color color =
    activityColor(activity);

    final String enzyme =
    experiment['enzyme_name'];

    final String inhibitor =
    experiment['inhibitor_type'];

    final double temperature =
    (experiment['temperature'] as num).toDouble();

    final double ph =
    (experiment['ph'] as num).toDouble();

    final double substrate =
    (experiment['substrate'] as num).toDouble();

    final String unit =
    experiment['substrate_unit'];

    final String date =
    experiment['created_at'];

    final DateTime dateTime =
        DateTime.tryParse(date) ??
            DateTime.now();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2E7D32,
                    ).withValues(alpha: 0.1),

                    borderRadius:
                    BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.biotech,
                    color:
                    Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    enzyme,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                  ),

                  onPressed: () {
                    deleteExperiment(
                      experiment['id'],
                    );
                  },
                ),
              ],
            ),

            const Divider(height: 25),

            Row(
              children: [
                Expanded(
                  child: _info(
                    'Temperature',
                    '${temperature.toStringAsFixed(0)} °C',
                  ),
                ),

                Expanded(
                  child: _info(
                    'pH',
                    ph.toStringAsFixed(1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _info(
                    'Substrate',
                    '${substrate.toStringAsFixed(2)} $unit',
                  ),
                ),

                Expanded(
                  child: _info(
                    'Inhibitor',
                    inhibitor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding:
              const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color:
                color.withValues(alpha: 0.08),

                borderRadius:
                BorderRadius.circular(15),
              ),

              child: Row(
                children: [
                  const Text(
                    'Relative Activity',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${activity.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _formatDate(dateTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
      String label,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
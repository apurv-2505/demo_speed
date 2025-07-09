import 'package:flutter/material.dart';
import '../models/api_call.dart';

class CallListsWidget extends StatelessWidget {
  final List<ApiCall> queuedCalls;
  final List<String> completedCalls;

  const CallListsWidget({
    super.key,
    required this.queuedCalls,
    required this.completedCalls,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange[100],
                  child: Text(
                    'Queued Calls (${queuedCalls.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: queuedCalls.isEmpty
                      ? const Center(child: Text('No queued calls'))
                      : ListView.builder(
                          itemCount: queuedCalls.length,
                          itemBuilder: (context, index) {
                            final call = queuedCalls[index];
                            return ListTile(
                              dense: true,
                              title: Text(call.data),
                              subtitle: Text(
                                call.timestamp.toString().substring(11, 19),
                              ),
                              leading: const Icon(
                                Icons.schedule,
                                color: Colors.orange,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.green[100],
                  child: Text(
                    'Completed Calls (${completedCalls.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: completedCalls.isEmpty
                      ? const Center(child: Text('No completed calls'))
                      : ListView.builder(
                          itemCount: completedCalls.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(completedCalls[index]),
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

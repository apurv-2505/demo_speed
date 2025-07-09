import 'package:flutter/material.dart';
import '../models/api_call.dart';
import '../services/api_service.dart';
import '../services/speed_service.dart';
import '../widgets/speed_display_widget.dart';
import '../widgets/speed_config_widget.dart';
import '../widgets/call_lists_widget.dart';
import '../utils/utils.dart';

class SpeedApiDemo extends StatefulWidget {
  const SpeedApiDemo({super.key});

  @override
  State<SpeedApiDemo> createState() => SpeedApiDemoState();
}

class SpeedApiDemoState extends State<SpeedApiDemo> {
  double currentSpeed = 0.0;
  double minSpeedThreshold = 5.0;
  SpeedUnit selectedUnit = SpeedUnit.mbps;
  bool isCheckingSpeed = false;
  bool useManualInput = false;
  List<ApiCall> queuedCalls = [];
  List<String> completedCalls = [];

  final TextEditingController manualSpeedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manualSpeedController.text = '5.0';
  }

  @override
  void dispose() {
    manualSpeedController.dispose();
    super.dispose();
  }

  Future<void> checkInternetSpeed() async {
    setState(() {
      isCheckingSpeed = true;
    });

    try {
      final speed = await SpeedService.checkInternetSpeed();
      setState(() {
        currentSpeed = speed;
      });
    } catch (e) {
      setState(() {
        currentSpeed = 0.0;
      });
      showSnackBar('Speed test failed: ${e.toString()}');
    } finally {
      setState(() {
        isCheckingSpeed = false;
      });
    }
  }

  Future<void> makeApiCall(String data) async {
    await checkInternetSpeed();
    await processQueuedCalls();

    final apiCall = ApiCall(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      timestamp: DateTime.now(),
    );

    final thresholdMbps = useManualInput
        ? SpeedService.convertToMbps(
            double.tryParse(manualSpeedController.text) ?? 5.0,
            selectedUnit,
          )
        : minSpeedThreshold;

    if (currentSpeed >= thresholdMbps) {
      await executeApiCall(apiCall);
    } else {
      setState(() {
        queuedCalls.add(apiCall);
      });
      showSnackBar(
        'API call queued due to slow connection\n'
        'Current: ${SpeedService.formatSpeed(currentSpeed, selectedUnit)}\n'
        'Required: ${SpeedService.formatSpeed(thresholdMbps, selectedUnit)}',
      );
    }
  }

  Future<void> executeApiCall(ApiCall apiCall) async {
    try {
      await ApiService.executeApiCall(apiCall);
      setState(() {
        completedCalls.add(
          '${apiCall.data} - ${apiCall.timestamp.toString().substring(11, 19)}',
        );
      });
      showSnackBar('API call completed: ${apiCall.data}');
    } catch (e) {
      showSnackBar('API call error: ${e.toString()}');
    }
  }

  Future<void> processQueuedCalls() async {
    if (queuedCalls.isEmpty) return;

    await checkInternetSpeed();

    final thresholdMbps = useManualInput
        ? SpeedService.convertToMbps(
            double.tryParse(manualSpeedController.text) ?? 5.0,
            selectedUnit,
          )
        : minSpeedThreshold;

    if (currentSpeed >= thresholdMbps) {
      final callsToProcess = List<ApiCall>.from(queuedCalls);
      setState(() {
        queuedCalls.clear();
      });

      for (final call in callsToProcess) {
        await executeApiCall(call);
      }

      showSnackBar('All ${callsToProcess.length} queued API calls processed!');
    } else {
      showSnackBar(
        'Still slow connection. Cannot process queued calls.\n'
        'Current: ${SpeedService.formatSpeed(currentSpeed, selectedUnit)}\n'
        'Required: ${SpeedService.formatSpeed(thresholdMbps, selectedUnit)}',
      );
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void onUnitChanged(SpeedUnit newUnit) {
    setState(() {
      selectedUnit = newUnit;
      if (!useManualInput) {
        minSpeedThreshold = SpeedService.convertToMbps(
          SpeedService.convertFromMbps(minSpeedThreshold, selectedUnit),
          selectedUnit,
        );
      }
    });
  }

  void onManualInputChanged(bool value) {
    setState(() {
      useManualInput = value;
      if (useManualInput) {
        manualSpeedController.text = SpeedService.convertFromMbps(
          minSpeedThreshold,
          selectedUnit,
        ).toStringAsFixed(1);
      }
    });
  }

  void onThresholdChanged(double value) {
    setState(() {
      minSpeedThreshold = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final thresholdMbps = useManualInput
        ? SpeedService.convertToMbps(
            double.tryParse(manualSpeedController.text) ?? 5.0,
            selectedUnit,
          )
        : minSpeedThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed-Based API Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SpeedDisplayWidget(
              currentSpeed: currentSpeed,
              thresholdMbps: thresholdMbps,
              selectedUnit: selectedUnit,
              isCheckingSpeed: isCheckingSpeed,
            ),
            const SizedBox(height: 16),
            SpeedConfigWidget(
              selectedUnit: selectedUnit,
              useManualInput: useManualInput,
              minSpeedThreshold: minSpeedThreshold,
              manualSpeedController: manualSpeedController,
              onUnitChanged: onUnitChanged,
              onManualInputChanged: onManualInputChanged,
              onThresholdChanged: onThresholdChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCheckingSpeed
                        ? null
                        : () => makeApiCall(Utils.generateRandomData()),
                    child: Text(
                      isCheckingSpeed ? 'Checking Speed...' : 'Make API Call',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (queuedCalls.isNotEmpty && !isCheckingSpeed)
                        ? processQueuedCalls
                        : null,
                    child: Text(
                      isCheckingSpeed
                          ? 'Checking...'
                          : 'Process Queue (${queuedCalls.length})',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CallListsWidget(
                queuedCalls: queuedCalls,
                completedCalls: completedCalls,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/api_call.dart';
import '../services/speed_service.dart';

class SpeedDisplayWidget extends StatelessWidget {
  final double currentSpeed;
  final double thresholdMbps;
  final SpeedUnit selectedUnit;
  final bool isCheckingSpeed;

  const SpeedDisplayWidget({
    super.key,
    required this.currentSpeed,
    required this.thresholdMbps,
    required this.selectedUnit,
    required this.isCheckingSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Speed: ${SpeedService.formatSpeed(currentSpeed, selectedUnit)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: currentSpeed / 50,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                currentSpeed >= thresholdMbps ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCheckingSpeed
                  ? 'Checking speed...'
                  : (currentSpeed >= thresholdMbps
                        ? 'Speed OK'
                        : 'Speed Too Slow'),
              style: TextStyle(
                color: currentSpeed >= thresholdMbps
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentSpeed > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Required: ${SpeedService.formatSpeed(thresholdMbps, selectedUnit)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

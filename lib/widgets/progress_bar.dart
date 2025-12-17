import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';
import '../services/audio_player_service.dart'; // ✅ THÊM

class ProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.position.inMilliseconds.toDouble();
    final max = widget.duration.inMilliseconds.toDouble();

    final playerService = AudioPlayerService(); // ✅ THÊM

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.darkGrey,
            thumbColor: AppColors.white,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(0.0, max),
            min: 0.0,
            max: max > 0 ? max : 1.0,
            onChanged: (newValue) {
              setState(() {
                _dragValue = newValue;
              });
            },
            onChangeEnd: (newValue) async {
              widget.onSeek(
                Duration(milliseconds: newValue.toInt()),
              );

              await playerService.savePlayerState();

              _dragValue = null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(
                  Duration(milliseconds: value.toInt()),
                ),
                style: AppTextStyles.caption,
              ),
              Text(
                DurationFormatter.format(widget.duration),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

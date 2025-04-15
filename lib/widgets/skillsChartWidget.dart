import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:swifty_companion/models/user.dart';
import 'package:swifty_companion/models/cursus.dart';

class SkillsChart extends StatelessWidget {
  final User user;
  final Cursus cursus;

  const SkillsChart({
    super.key,
    required this.user,
    required this.cursus,
  });

  @override
  Widget build(BuildContext context) {
    final displaySkills = cursus.skills.length > 10
        ? cursus.skills.sublist(0, 10)
        : cursus.skills;

    return cursus.skills.length >= 3 ? Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Level: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Text(
                    cursus.level.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: () {
                  final level =
                      cursus.level;
                  return level - level.floor();
                }(),
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(
                touchCallback: (FlTouchEvent event, response) {},
                enabled: true,
              ),
              dataSets: [
                RadarDataSet(
                  fillColor: Colors.blue.withValues(alpha: 0.4),
                  borderColor: Colors.blue,
                  entryRadius: 5,
                  borderWidth: 2.0,
                  dataEntries: displaySkills.map((skill) => RadarEntry(value: skill.level)).toList(),
                ),
              ],
              radarShape: RadarShape.polygon,
              radarBorderData: BorderSide(color: Colors.grey, width: 1),
              ticksTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
              tickBorderData: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              gridBorderData: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: const TextStyle(
                fontSize: 10,
                overflow: TextOverflow.ellipsis,
              ),
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: displaySkills[index].name,
                  angle: angle,
                );
              },
              tickCount: 5,
              radarBackgroundColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          children:
          displaySkills
              .map(
                (skill) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '${skill.name}: ${skill.level.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          )
              .toList(),
        ),
      ],
    ):
    const Center(
      child: Text(
        'Not enough skills to display',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    )
    ;
  }

}
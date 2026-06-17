import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/analysis/analysis_bloc.dart';
import '../bloc/analysis/analysis_state.dart';

class AnalysisScreen extends StatelessWidget {
  final String keyword;

  const AnalysisScreen({this.keyword = '', super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Row(
                children: [
                  const Icon(FontAwesomeIcons.chartLine, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Publication Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Yearly growth trends of publications',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Content Body
              Expanded(
                child: BlocBuilder<AnalysisBloc, AnalysisState>(
                  builder: (context, state) {
                    if (state is AnalysisInitial) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.chartArea,
                              size: 64,
                              color: AppTheme.borderNeon,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Please perform a search in the Search tab to view trends analysis.',
                              textAlign: Center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is AnalysisLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryNeon,
                        ),
                      );
                    }

                    if (state is AnalysisFailure) {
                      return Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: AppTheme.accentRose),
                        ),
                      );
                    }

                    if (state is AnalysisSuccess) {
                      if (state.trendData.isEmpty) {
                        return const Center(
                          child: Text(
                            'No trend data found for this topic.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        );
                      }

                      return _buildTrendAnalysis(context, state.trendData, state.keyword);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis(BuildContext context, Map<int, int> trendData, String keyword) {
    // Sort years to plot line chart chronologically
    final sortedYears = trendData.keys.toList()..sort();
    
    // Filter out outliers/unreasonable years (e.g. year 0 or futures)
    final filteredYears = sortedYears.where((year) => year > 1950 && year <= DateTime.now().year).toList();

    // Map to spots
    final List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < filteredYears.length; i++) {
      final year = filteredYears[i];
      final count = trendData[year]!.toDouble();
      spots.add(FlSpot(i.toDouble(), count));
      if (count < minY) minY = count;
      if (count > maxY) maxY = count;
    }

    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 100;

    // Peak calculation
    int peakYear = filteredYears.first;
    int maxCount = -1;
    trendData.forEach((year, count) {
      if (year > 1950 && year <= DateTime.now().year && count > maxCount) {
        maxCount = count;
        peakYear = year;
      }
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.3)),
            ),
            child: Text(
              'Keyword: $keyword',
              style: const TextStyle(
                color: AppTheme.primaryNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Peak metric card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassBox(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryNeon.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(FontAwesomeIcons.fire, color: AppTheme.secondaryNeon, size: 20),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peak Research Year',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$peakYear ($maxCount publications)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Chart Section
          const Text(
            'Timeline Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
            decoration: AppTheme.glassBox(
              color: AppTheme.darkCardBackground.withOpacity(0.3),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < filteredYears.length) {
                          // Show title only for first, last, and middle points to prevent overlap
                          if (idx == 0 || idx == filteredYears.length - 1 || idx == (filteredYears.length / 2).floor()) {
                            return Text(
                              filteredYears[idx].toString(),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (filteredYears.length - 1).toDouble(),
                minY: minY * 0.9,
                maxY: maxY * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryNeon.withOpacity(0.2),
                          AppTheme.secondaryNeon.withOpacity(0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

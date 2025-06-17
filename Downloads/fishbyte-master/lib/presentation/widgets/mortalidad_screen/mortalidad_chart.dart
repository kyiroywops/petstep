import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:fishbyte/presentation/providers/data/mortality_provider.dart';

class MortalidadChartWidget extends ConsumerWidget {
  const MortalidadChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMonthProvider);
    final monthlyData = ref.watch(mortalityDataProvider);
    
    if (monthlyData.isEmpty) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final maxMortalidad = monthlyData.reduce((a, b) => a > b ? a : b);
    final minMortalidad = monthlyData.reduce((a, b) => a < b ? a : b);
    final promedio = monthlyData.reduce((a, b) => a + b) / monthlyData.length;
    final totalMes = monthlyData.reduce((a, b) => a + b);
    final ultimoRegistro = monthlyData.last;
    final porcentajeCambio = monthlyData.length > 1 
        ? ((monthlyData.last - monthlyData[monthlyData.length - 2]) / 
           monthlyData[monthlyData.length - 2] * 100).toStringAsFixed(1)
        : '0.0';

    final formattedDate = DateFormat('MMMM yyyy', 'es_ES').format(selectedDate)
        .replaceFirstMapped(RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase());

    return Container(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ref, formattedDate),
              Divider(color: Colors.grey.shade800, thickness: 1.5),
              SizedBox(height: 10),
              _buildChart(maxMortalidad.toDouble(), monthlyData),
              SizedBox(height: 20),
              _buildMainStats(maxMortalidad, minMortalidad, promedio),
              SizedBox(height: 5),
              _buildLastRecord(ultimoRegistro, porcentajeCambio, monthlyData),
              SizedBox(height: 5),
              _buildAdditionalStats(totalMes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mortalidad diaria',
          style: GoogleFonts.outfit(
            fontSize: 18,
            color: Colors.grey.shade300,
            fontWeight: FontWeight.w800,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.chevronLeft,
                size: 11,
                color: Colors.grey.shade300,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _changeMonth(ref, -1);
              },
            ),
            Text(
              formattedDate,
              style: GoogleFonts.outfit(
                color: Colors.grey.shade300,
                fontSize: 11,
                fontWeight: FontWeight.bold
              ),
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.chevronRight,
                size: 11,
                color: Colors.grey.shade300,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _changeMonth(ref, 1);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _changeMonth(WidgetRef ref, int offset) {
    final current = ref.read(selectedMonthProvider);
    final newDate = DateTime(current.year, current.month + offset, 1);
    ref.read(selectedMonthProvider.notifier).state = newDate;
  }

  Widget _buildChart(double maxMortalidad, List<int> data) {
  return SizedBox(
    height: 220,
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: maxMortalidad + 10,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final dayNumber = (value.toInt() + 1).toString();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dayNumber,
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(maxMortalidad),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.outfit(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.redAccent.shade400,
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent.shade400.withOpacity(0.2),
                  Colors.transparent
                ],
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: Colors.redAccent.shade400,
                  strokeWidth: 0,
                ),
            ),
          ),
        ],
      ),
    ),
  );
}

double _calculateInterval(double maxValue) {
  if (maxValue > 100) return 20;
  if (maxValue > 50) return 10;
  return 5;
}

  Widget _buildMainStats(int max, int min, double promedio) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Máximo', '$max', FontAwesomeIcons.arrowUp),
          _buildStatItem('Mínimo', '$min', FontAwesomeIcons.arrowDown),
          _buildStatItem('Promedio', promedio.toStringAsFixed(1), FontAwesomeIcons.chartLine),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade400),
        SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.grey.shade500,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.grey.shade300,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildLastRecord(int ultimoRegistro, String porcentajeCambio, List<int> data) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ÚLTIMO REGISTRO',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$ultimoRegistro peces',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Hace 1 día',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$porcentajeCambio%',
                style: GoogleFonts.outfit(
                  color: data.length > 1 && ultimoRegistro > data[data.length - 2] 
                      ? Colors.redAccent.shade400 
                      : Colors.greenAccent.shade400,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'vs el dia anterior',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats(int totalMes) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAdditionalItem('Total mes', '$totalMes', FontAwesomeIcons.calculator),
          _buildAdditionalItem('Días críticos', '8', FontAwesomeIcons.exclamationTriangle),
          _buildAdditionalItem('Mejor día', '25°', FontAwesomeIcons.calendarCheck),
        ],
      ),
    );
  }

  Widget _buildAdditionalItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.grey.shade300,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
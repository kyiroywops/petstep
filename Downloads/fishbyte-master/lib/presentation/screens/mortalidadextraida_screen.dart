import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:fishbyte/presentation/providers/data/mortality_provider.dart';
import 'package:fishbyte/presentation/widgets/mortalidad_screen/mortalidad_chart.dart';
class MortalidadExtraidaScreen extends ConsumerStatefulWidget {
  @override
  _MortalidadExtraidaScreenState createState() => _MortalidadExtraidaScreenState();
}

class _MortalidadExtraidaScreenState extends ConsumerState<MortalidadExtraidaScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  void _changeMonth(int offset) {
    final current = ref.read(selectedMonthProvider);
    final newDate = DateTime(current.year, current.month + offset, 1);
    ref.read(selectedMonthProvider.notifier).state = newDate;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedMonthProvider);
    final mortalityData = ref.watch(mortalityDataProvider);
    
    final currentMonthDates = _getMonthDates(selectedDate);
    final currentMonthName = DateFormat('MMMM yyyy', 'es_ES')
        .format(selectedDate)
        .replaceFirstMapped(RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Mortalidad global extraída',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.grey.shade300,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    
                  },
                  child: SvgPicture.asset(
                    'assets/svg/info.svg',
                    color: Colors.white,
                    height: 20,
                  ),
                ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey.shade800,
                          height: 20,
                          thickness: 1.5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.chevronLeft,
                                size: 14,
                                color: Colors.grey.shade300,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _changeMonth(-1);
                              },
                            ),
                            Text(
                              currentMonthName,
                              style: GoogleFonts.outfit(
                                color: Colors.grey.shade300,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.chevronRight,
                                size: 14,
                                color: Colors.grey.shade300,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _changeMonth(1);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 280,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: currentMonthDates.length,
                            itemBuilder: (context, index) {
                              final day = currentMonthDates[index];
                              final mortality = index < mortalityData.length 
                                  ? mortalityData[index] 
                                  : 0;
                              
                              return Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.transparent,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('d').format(day),
                                      style: GoogleFonts.outfit(
                                        color: Colors.grey.shade300,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Text(
                                        mortality.toString(),
                                        style: GoogleFonts.outfit(
                                          color: _getDayColor(mortality),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              _buildLegendItem("Alta", Colors.redAccent.shade400),
                              const SizedBox(width: 15),
                              _buildLegendItem("Media", Colors.orangeAccent.shade400),
                              const SizedBox(width: 15),
                              _buildLegendItem("Baja", Colors.greenAccent.shade400),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const MortalidadChartWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDayColor(int mortality) {
    if (mortality == 0) return Colors.grey;
    if (mortality > 5) return Colors.redAccent.shade400;
    if (mortality > 8) return Colors.orangeAccent.shade400;
    return Colors.greenAccent.shade400;
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.outfit(
            color: Colors.grey.shade300,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  List<DateTime> _getMonthDates(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastOfMonth.day,
      (index) => firstOfMonth.add(Duration(days: index)),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fishbyte/presentation/providers/pendingcount_provider.dart';
import 'package:fishbyte/presentation/providers/senttotal_counter_provider.dart';
import 'package:fishbyte/presentation/widgets/casos_screen/dialog_estados_widget.dart';
/// Barra Superior de estado, extraída a su propio widget
class TopStatusBarWidget extends ConsumerWidget {
  const TopStatusBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentAsync = ref.watch(sentCounterProvider);
    final pendingCount = ref.watch(pendingReportsCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Estado de Casos',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const StateDialogInfo();
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svg/info.svg',
                    color: Colors.white,
                    height: 20,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade800),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // “Casos enviados” (con sentAsync)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/allrecents');
                  },
                  child: Column(
                    children: [
                      sentAsync.when(
                        loading: () => Text(
                          '...',
                          style: GoogleFonts.outfit(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        error: (err, st) => Text(
                          'ERR',
                          style: GoogleFonts.outfit(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.redAccent,
                          ),
                        ),
                        data: (count) => Text(
                          '$count',
                          style: GoogleFonts.outfit(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Casos enviados',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // “Casos pendientes”
                Column(
                  children: [
                    Text(
                      '$pendingCount',
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.redAccent.shade400,
                      ),
                    ),
                    Text(
                      'Casos pendientes',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';

// import 'package:fishbyte/presentation/providers/login/centers_provider.dart';

// void showCenterBottomSheet(BuildContext context, WidgetRef globalRef) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.grey.shade900,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) {
//       return Consumer(builder: (context, ref, _) {
//         final centersAsync = ref.watch(centersProvider);
//         final selectedCenter = ref.watch(selectedCenterProvider);

//         return centersAsync.when(
//           data: (centers) {
//             // Determinamos el índice de la empresa seleccionada actualmente
//             int initialIndex = 0;
//             if (selectedCenter != null) {
//               final selectedIndex = centers.indexWhere((c) => c.label == selectedCenter.label);
//               if (selectedIndex != -1) {
//                 initialIndex = selectedIndex;
//               }
//             }

//             final controller = FixedExtentScrollController(initialItem: initialIndex);

//             return Container(
//               height: 500,
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   SizedBox(height: 10),
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade600,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Selecciona tu empresa",
//                     style: GoogleFonts.outfit(
//                         fontSize: 22,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Selecciona la empresa con la que deseas trabajar.",
//                     style: GoogleFonts.outfit(
//                         fontSize: 12,
//                         color: Colors.grey.shade700,
//                         fontWeight: FontWeight.w400),
//                   ),
//                   SizedBox(height: 20),
//                   Expanded(
//                     child: ListWheelScrollView.useDelegate(
//                       controller: controller,
//                       physics: FixedExtentScrollPhysics(),
//                       itemExtent: 50,
//                       onSelectedItemChanged: (index) {
//                         HapticFeedback.lightImpact();
//                         final selected = centers[index];
                        
//                         // Actualizar el valor del provider con la empresa seleccionada
//                         ref.read(selectedCenterProvider.notifier).state = selected;
//                         // Actualizar label y value por separado
//                         ref.read(selectedCenterLabelProvider.notifier).state = selected.label;
//                         ref.read(selectedCenterValueProvider.notifier).state = selected.value;


//                         ref.refresh(graphQLClientProvider);

//                       },
//                       childDelegate: ListWheelChildBuilderDelegate(
//                         builder: (context, index) {
//                           final center = centers[index];
//                           final isSelected = selectedCenter != null &&
//                               center.label == selectedCenter.label;
//                           return Center(
//                             child: Container(
//                               width: double.infinity,
//                               padding: EdgeInsets.symmetric(vertical: 10),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Colors.grey.shade800.withOpacity(0.7)
//                                     : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 center.label,
//                                 style: GoogleFonts.outfit(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w400,
//                                   color: Colors.white,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           );
//                         },
//                         childCount: centers.length,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       HapticFeedback.lightImpact();
//                       ref.refresh(graphQLClientProvider); 

//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     ),
//                     child: Text(
//                       "Cerrar",
//                       style: GoogleFonts.outfit(
//                           fontSize: 15,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   SizedBox(height: 30),
//                 ],
//               ),
//             );
//           },
//           loading: () => Container(
//             height: 300,
//             alignment: Alignment.center,
//             child: CupertinoActivityIndicator(),
//           ),
//           error: (err, stack) => Container(
//             height: 200,
//             alignment: Alignment.center,
//             child: Text(
//               'Error: $err',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         );
//       });
//     },
//   );
// }

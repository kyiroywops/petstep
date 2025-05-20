import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Constantes de tu BLE 
const String serviceUuid         = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String characteristicUuid  = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
const String targetDeviceName    = "ESP32-BLE";
const String targetDeviceAddress = "8C:AA:B5:A1:2C:EA";



class BluetoothConnection extends ChangeNotifier {
    // Callbacks para acciones de botones
  VoidCallback? onMoveLeftPressed;
  VoidCallback? onMoveRightPressed;
  VoidCallback? onNextPressed;

  /// Para reconexiones
  Timer? _reconnectTimer;

  /// Estado
  bool _isScanning    = false;
  bool _isConnected   = false;
  String? _errorMsg;

  // Ejemplo de buttonStates (3 bits)
  List<bool> _buttonStates = [false, false, false];
  int _previousState   = 0;
  int _buttonPressState= 0;

  /// Referencia al dispositivo conectado
  BluetoothDevice? _device;
  BluetoothCharacteristic? _targetCharacteristic;

  // Getters de estado
  bool get isScanning        => _isScanning;
  bool get isConnected       => _isConnected;
  String? get errorMessage   => _errorMsg;
  List<bool> get buttonStates=> _buttonStates;

  // ============== Escaneo ==============
  Future<void> startScan() async {
    print('🔍 Starting Bluetooth scan...');
    _setError(null);

    final isOn = await FlutterBluePlus.isOn;
    print('📱 Bluetooth status: ${isOn ? 'ON' : 'OFF'}');
    
    if (!isOn) {
      _setError("El Bluetooth está apagado o no disponible");
      return;
    }
    await requestBluetoothPermissions();

    // Iniciamos el escaneo
    _isScanning = true;
    notifyListeners();

    // Importante: usar FlutterBluePlus.startScan (método estático)
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Escuchar resultados
    FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        // Tomamos nombre e ID
        final name = r.device.name;
        final id   = r.device.id.id; // Mac en Android, UUID en iOS

        // Comparamos con tus constantes
        if (name == targetDeviceName || id == targetDeviceAddress) {
          // Detenemos escaneo
          await _stopScan();

          // Intentamos conectar
          _connectToDevice(r.device);
          break;
        }
      }
    }, onError: (e) {
      _setError(e.toString());
      _stopScan();
    });
  }

  /// Método para detener el escaneo
  Future<void> _stopScan() async {
    _isScanning = false;
    notifyListeners();
    // También es estático
    await FlutterBluePlus.stopScan();
  }

  // ============== Conexión ==============
  // En la clase BluetoothConnection, actualiza el método _connectToDevice:
  
  Future<void> _connectToDevice(BluetoothDevice device) async {
    _reconnectTimer?.cancel();
    _device = device;
    _isConnected = false;
    notifyListeners();
  
    try {
      await device.connect(autoConnect: false).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw Exception("Timeout al conectar con el dispositivo");
        },
      );
  
      print('✅ Connected successfully to ${device.name}');
      _isConnected = true;
      notifyListeners();
  
      final services = await device.discoverServices();
      
      for (final service in services) {
        print('🔍 Service UUID: ${service.uuid}');
        final characteristics = service.characteristics;
        
        for (final characteristic in characteristics) {
          print('📱 Characteristic UUID: ${characteristic.uuid}');
          
          if (characteristic.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase()) {
            _targetCharacteristic = characteristic;
            print('✅ Found target characteristic');
            
            // Habilitar notificaciones
            await characteristic.setNotifyValue(true);
            
            // Escuchar valores
            characteristic.value.listen(
              (value) {
                if (value.isNotEmpty) {
                  print('📥 Raw value: $value');
                  final state = value[0];
                  _updateButtonStates(state);
                }
              },
              onError: (error) {
                print('❌ Characteristic error: $error');
                _setError(error.toString());
              },
            );
          }
        }
      }
  
      // Monitorear desconexión
      device.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          print('📴 Device disconnected');
          _isConnected = false;
          notifyListeners();
          _scheduleReconnect(device);
        }
      });
  
    } catch (e) {
      print('❌ Connection error: $e');
      _setError(e.toString());
      _scheduleReconnect(device);
    }
  }

  /// Reintentar conexión a los 5 segundos
  void _scheduleReconnect(BluetoothDevice device) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _connectToDevice(device);
    });
  }

  // ============== Lógica de botones (notificaciones) ==============
  void _updateButtonStates(int newState) {
    print('🔄 Raw button state received: $newState');
    
    // 3 bits: 0x01, 0x02, 0x04
    final b1 = (newState & 0x01) != 0;
    final b2 = (newState & 0x02) != 0;
    final b3 = (newState & 0x04) != 0;
    
    print('🎮 Decoded button states: Left=${b1}, Right=${b2}, Next=${b3}');
    
    if (b1 && onMoveLeftPressed != null) {
      print('⬅️ Executing left button callback');
      onMoveLeftPressed!();
    }
    if (b2 && onMoveRightPressed != null) {
      print('➡️ Executing right button callback');
      onMoveRightPressed!();
    }
    if (b3 && onNextPressed != null) {
      print('✅ Executing next button callback');
      onNextPressed!();
    }
    
    _buttonStates = [b1, b2, b3];
    notifyListeners();
  }

  // ============== Ejemplos de escritura ==============
  Future<void> moveLeft() async {
    if (_targetCharacteristic == null) {
      _setError("No characteristic found (moveLeft)");
      return;
    }
    try {
      // Envía un byte 0x01
      await _targetCharacteristic!.write([0x01], withoutResponse: true);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> moveRight() async {
    if (_targetCharacteristic == null) {
      _setError("No characteristic found (moveRight)");
      return;
    }
    try {
      // Envía un byte 0x02
      await _targetCharacteristic!.write([0x02], withoutResponse: true);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ============== Helpers ==============
  void _setError(String? msg) {
    _errorMsg = msg;
    notifyListeners();
  }

  Future<void> requestBluetoothPermissions() async {
  if (await Permission.bluetoothScan.request().isGranted &&
      await Permission.bluetoothConnect.request().isGranted) {
    print("Permisos concedidos");
  } else {
    print("Permisos denegados");
  }
}



  /// Cerrar y limpiar
  Future<void> disposeService() async {
    // Cancelar timer de reconexión
    _reconnectTimer?.cancel();

    // Desconectar device
    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
    }

    _device = null;
    _targetCharacteristic = null;
  }
}

/// ====================================================
/// =       WIDGET BleTestStandaloneWidget            =
/// ====================================================

/// Este widget crea su propia instancia de [BluetoothConnection]
/// y la usa localmente. Al presionar el botón, se hace el scan
/// y, si encuentra el dispositivo, se conecta. Aparecen botones
/// de ejemplo ("Move Left"/"Move Right") que envían datos al BLE.
class BleTestStandaloneWidget extends StatefulWidget {
  const BleTestStandaloneWidget({Key? key}) : super(key: key);

  @override
  State<BleTestStandaloneWidget> createState() =>
      _BleTestStandaloneWidgetState();
}

class _BleTestStandaloneWidgetState extends State<BleTestStandaloneWidget> {
  // Creamos la instancia local
  final ble = BluetoothConnection();

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en BluetoothConnection
    ble.addListener(_onBleChanged);
  }

  @override
  void dispose() {
    // Dejamos de escuchar
    ble.removeListener(_onBleChanged);
    // Liberamos recursos
    ble.disposeService();
    super.dispose();
  }

  /// Cuando [BluetoothConnection] hace notifyListeners(),
  /// reconstruimos este widget.
  void _onBleChanged() {
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Botonera conexión bluetooth',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // cambiar el dialog por el de bluetooth con las imagenes creadas para bluetooth y explicando todo
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return const StateDialogInfo();
                    //   },
                    // );
                  },
                  child: SvgPicture.asset(
                    'assets/svg/info.svg',
                    color: Colors.white,
                    height: 20,
                  ),
                ), 
            ],
          ),

          Divider(color: Colors.grey[800]),


          // Mostrar error si existe
          if (ble.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Text(
                'Error: ${ble.errorMessage}',
                style: GoogleFonts.outfit(color: Colors.red, fontSize: 11),
              ),
            ),

          // Mostrar info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Conectado ', style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700
              )),
              Text('${ble.isConnected}', style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700
              )),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Escaneando ', style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700
              )),
              Text('${ble.isScanning}', style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700
              )),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('buttonStates (test)', style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700
              )),
              SizedBox(width: 10),
              Text('${ble.buttonStates}', style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700
              )),
            ],
          ),
          const SizedBox(height: 20),

          // Botón para escanear
          GestureDetector(
            onTap: ble.startScan,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.bluetooth, size: 15),
                  SizedBox(width: 8),
                  Text('Escanea y Conecta el dispositivo', style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w700
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botones "Move Left / Right"
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       // Solo habilitado si está conectado
          //       onPressed: ble.isConnected ? ble.moveLeft : null,
          //       child: Text('Move Left', style: GoogleFonts.outfit(fontSize: 12)),
          //     ),
          //     ElevatedButton(
          //       onPressed: ble.isConnected ? ble.moveRight : null,
          //       child: Text('Move Right', style: GoogleFonts.outfit(fontSize: 12)),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

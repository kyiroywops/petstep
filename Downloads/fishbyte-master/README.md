# 📸🐟 FishByte

Aplicación en **Flutter** para capturar fotos de pescados y subirlas a una plataforma basada en **Strapi** mediante **GraphQL**, con soporte para control mediante **Bluetooth**.

## 📖 Tabla de Contenidos

- [Introducción](#introducción)
- [Características](#características)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Selección Dinámica de Servidores](#selección-dinámica-de-servidores)
- [Conexión Bluetooth](#conexión-bluetooth)
- [API y Endpoints](#api-y-endpoints)
- [Rutas de la Aplicación](#rutas-de-la-aplicación)
- [Configuración](#configuración)
- [Errores y Soluciones](#errores-y-soluciones)
- [Contribuyentes](#contribuyentes)
- [Licencia](#licencia)
- [Integración con Supabase](#integración-con-supabase)

---

## 📌 Introducción

FishByte es una aplicación móvil desarrollada en **Flutter** que permite a los usuarios capturar imágenes de pescados y subirlas a una plataforma **Strapi** utilizando **GraphQL**. También cuenta con **integración Bluetooth** para interactuar con una botonera externa basada en **ESP32**.

---

## ✨ Características

✔ Captura de imágenes desde la cámara o galería.  
✔ Integración con **Strapi** para almacenamiento de imágenes.  
✔ Consumo de API **GraphQL** mediante **GraphQL Flutter**.  
✔ Uso de **Riverpod** para la gestión del estado.  
✔ Manejo de autenticación con **JWT**.  
✔ Monitorización de errores con **Sentry**.  
✔ **Selección dinámica de servidores** en función del centro elegido.  
✔ **Soporte Bluetooth** para control mediante botonera ESP32.  
✔ **Carga en segundo plano** con `uploadQueueProvider`.  
✔ **Soporte para iOS 15+ y Android (minSdk 23)**.  

---

## 🔧 Requisitos

- **Flutter** (versión compatible con `flutter pub get`)
- **Dart** >= 3.0
- **Strapi** con GraphQL habilitado
- **ESP32 con Bluetooth** configurado para la botonera
- **Cuenta en Sentry** (para el monitoreo de errores)
- **iOS 15+ y Android minSdk 23**

---

## 🚀 Instalación

1. Clonar este repositorio:

   ```bash
   git clone https://github.com/tuusuario/fishbyte.git
   cd fishbyte
   ```

2. Instalar dependencias de **Flutter**:

   ```bash
   flutter pub get
   ```

3. Para iOS, ejecutar:

   ```bash
   cd ios
   pod install
   ```

4. Ejecutar la aplicación en un emulador o dispositivo:

   ```bash
   flutter run
   ```

---

## 📲 Uso

1. Abrir la aplicación en un dispositivo móvil o emulador.
2. Seleccionar la empresa o centro desde el cual se trabajará.
3. Capturar o seleccionar una imagen de un pescado.
4. Enviar la imagen a **Strapi** mediante **GraphQL**.
5. Conectar la botonera **Bluetooth** si está disponible.
6. Revisar el estado de la subida en la cola de **uploadQueueProvider**.

---

## 🌐 Selección Dinámica de Servidores

La app obtiene dinámicamente la URL del backend desde un JSON alojado en **Google Cloud Storage**. Este JSON contiene la lista de empresas y sus respectivos servidores.

```dart
final url = 'https://storage.googleapis.com/pathovet-test/enterprises.json';
final response = await http.get(Uri.parse(url));
```

---

## 🔵 Conexión Bluetooth

La app soporta **Bluetooth Low Energy (BLE)** y se conecta a un **ESP32** con una botonera externa.

**Detalles de la conexión BLE**:

- **Nombre del dispositivo esperado**: `ESP32-BLE`
- **Dirección MAC esperada**: `8C:AA:B5:A1:2C:EA`
- **Servicio UUID**: `4fafc201-1fb5-459e-8fcc-c5c9c331914b`
- **Característica UUID**: `beb5483e-36e1-4688-b7f5-ea07361b26a8`

---

## 🔌 API y Endpoints

### 📍 **Autenticación**

**Login**

```graphql
mutation Login($identifier: String!, $password: String!) {
  login(input: { identifier: $identifier, password: $password }) {
    jwt
    user {
      id
      username
      email
    }
  }
}
```

**Registro de Usuario**

```graphql
mutation Register($username: String!, $email: String!, $password: String!) {
  register(input: { username: $username, email: $email, password: $password }) {
    jwt
    user {
      id
      username
      email
    }
  }
}
```

### 📍 **Subida de Imágenes**

```graphql
mutation UPLOAD_IMAGE($file: Upload!) {
  upload(file: $file) {
    data {
      id
    }
  }
}
```

### 📍 **Guardar Reportes**

```graphql
mutation SAVE_REPORT($data: ReportInput!) {
  createReport(data: $data) {
    data {
      id
    }
  }
}
```

### 📍 **Consulta de Usuario y Centros Disponibles**

```graphql
query Me {
  me {
    id
    username
    email
    role {
      name
      description
    }
  }
  centers {
    data {
      id
      attributes {
        name
        category
        species
        enterprise {
          data {
            attributes {
              name
              nickname
            }
          }
        }
      }
    }
  }
}
```

---

## 🛤 Rutas de la Aplicación con GoRouter en Lib/Config/Router/App_router.dart

```dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthCheckScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => BaseScreen(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
        GoRoute(path: '/registros', builder: (context, state) => FishPhotoSessionSetupScreen()),
        GoRoute(path: '/mortalidadextraida', builder: (context, state) => MortalidadExtraidaScreen()),
        GoRoute(path: '/configuracion', builder: (context, state) => SettingsScreen()),
      ],
    ),
  ],
);
```

---

## 🛠 Errores y Soluciones

| Error | Solución |
|-------|---------|
| `Token aún no está disponible` | Asegurar que el usuario ha iniciado sesión. |
| `GraphQL error: Unauthorized` | Token expirado, volver a iniciar sesión. |
| `Bluetooth está apagado` | Activar Bluetooth en el dispositivo. |
| `Timeout al conectar` | Asegurar que el **ESP32** está encendido. |

---

## 👥 Contribuyentes

- **[@kyiroywops](https://github.com/kyiroywops)** – Desarrollador contribuyente.

---

## 📜 Licencia

Este proyecto está licenciado bajo **MIT License**. Puedes ver más detalles en el archivo [`LICENSE`](LICENSE).

---

## 📌 Integración con Supabase

Este proyecto ha sido migrado para utilizar Supabase como proveedor de autenticación y base de datos.

## Cambios implementados

Se han realizado las siguientes modificaciones para integrar Supabase:

1. **Modelos de datos**: Se han creado clases Dart para mapear los tipos de Supabase en `lib/infrastructure/datasources/supabase_types.dart`.

2. **Repositorio de autenticación**: 
   - Se ha actualizado el repositorio de autenticación en `lib/infrastructure/repositories/auth_repository.dart` para usar Supabase en lugar de GraphQL.
   - Se implementaron métodos para login con Google, logout y verificación de sesión.

3. **Providers para Riverpod**:
   - Se ha creado un provider para el cliente de Supabase en `lib/presentation/providers/login/auth_provider.dart`.
   - Se ha creado un provider para comprobar si el usuario está autenticado.

4. **Controlador de login**:
   - Se ha actualizado el controlador en `lib/presentation/controllers/login_controller.dart` para usar el repositorio de Supabase.
   - Se implementó la escucha de cambios en el estado de autenticación.

5. **Pantalla de login**:
   - Se ha actualizado `lib/presentation/screens/login/login_screen.dart` para usar el nuevo controlador.
   - Se implementó el inicio de sesión con Google a través de Supabase.

6. **Servicio de autenticación**:
   - Se ha actualizado `lib/presentation/providers/services/auth_service.dart` para comprobar la sesión de Supabase al iniciar la app.

## Flujo de autenticación

1. La aplicación inicia y comprueba si hay una sesión activa
2. Si no hay sesión, muestra la pantalla de login
3. El usuario inicia sesión con Google
4. Supabase verifica y guarda la sesión
5. La aplicación redirige al usuario a la pantalla principal
6. El usuario puede cerrar sesión desde la pantalla de configuración

## Variables de entorno

La aplicación requiere las siguientes variables de entorno en un archivo `.env` en la raíz del proyecto:

```
SUPABASE_URL=su_url_de_supabase
SUPABASE_ANON_KEY=su_clave_anonima_de_supabase
```

## Estructura del proyecto

- `lib/infrastructure/datasources/`: Contiene los modelos de datos y tipos para Supabase
- `lib/infrastructure/repositories/`: Contiene el repositorio de autenticación
- `lib/presentation/providers/`: Contiene los providers para Riverpod
- `lib/presentation/controllers/`: Contiene los controladores para las pantallas
- `lib/presentation/screens/`: Contiene las pantallas de la aplicación

## Próximos pasos

- Implementar la gestión de datos de usuario usando la base de datos de Supabase
- Añadir sincronización de datos offline
- Implementar la subida de imágenes a Supabase Storage

# Configuración de Autenticación Nativa con Google

Este documento contiene las instrucciones para configurar correctamente la autenticación nativa con Google en la aplicación FishByte.

## Estado actual de la configuración

- ✅ **Web Client ID**: Configurado con `42667538144-m16ia0f63i8lr5qccvnif9uisa7ur1e0.apps.googleusercontent.com`
- ✅ **iOS Client ID**: Configurado con `42667538144-ckdb28nib5n7k70vtujbpsv21u6q8g5j.apps.googleusercontent.com`
- ✅ **Android Package Name**: Configurado como `com.lythium.fishbyteflutter`
- ✅ **iOS Bundle ID**: Configurado como `com.lythium.fishbyte`
- ✅ **URL Schemes**: Configurado en Info.plist y AndroidManifest.xml

## Configuración actual

La aplicación está configurada para usar la autenticación nativa con Google. Esta configuración incluye:

1. **ID de cliente web** configurado en `lib/main.dart`
2. **ID de cliente iOS** configurado en `lib/main.dart`
3. **URL Scheme iOS** configurado en `Info.plist` como `com.googleusercontent.apps.42667538144-ckdb28nib5n7k70vtujbpsv21u6q8g5j`
4. **URL Scheme Android** configurado en `AndroidManifest.xml` como `com.lythium.fishbyteflutter://login-callback`

## Verificación de configuración

Para verificar que todo está correctamente configurado:

1. **iOS**:
   - Verifica que el Bundle ID en Xcode coincida con `com.lythium.fishbyte`
   - Confirma que el URL scheme en Info.plist sea correcto
   - Verifica que el GIDClientID coincida con el ID de cliente de iOS

2. **Android**:
   - Verifica que el package name en build.gradle sea `com.lythium.fishbyteflutter`
   - Confirma que el URL scheme en AndroidManifest.xml sea correcto
   - Verifica que la huella digital SHA1 esté registrada en Google Cloud Console

## Solución de problemas

Si encuentras problemas durante la autenticación:

1. **Error en iOS**: 
   - Verifica que `GoogleSignIn` esté configurado con `clientId` para iOS
   - Confirma que el URL scheme en Info.plist coincida exactamente

2. **Error en Android**:
   - Verifica que el package name coincida exactamente
   - Confirma que la huella digital SHA1 esté registrada en Google Cloud Console

3. **Error en Supabase**:
   - Verifica que las URLs de redirección estén configuradas correctamente en el panel de Supabase
   - Confirma que los IDs de cliente estén registrados en Supabase

Para más información, consulta la documentación oficial de [Supabase Google Authentication](https://supabase.com/docs/guides/auth/social-login/auth-google) y [Google Sign-In](https://developers.google.com/identity/sign-in/ios/start-integrating). 
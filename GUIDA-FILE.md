# ADTurnistica — tutti i file del progetto

## 1. Il sito (la vera app)

**File:** `turni_lavoro.html`
**Dove va:** nel repository GitHub, rinominato **`Calcula.html`**
**Link pubblico:** https://stefanomilan1911.github.io/Calcula/Calcula.html

Contiene TUTTO: calendario, turni, reparti, strutture, guadagni,
statistiche, ferie, backup, login e scambio turni.
È un unico file: HTML + CSS + JavaScript insieme.

**Quando lo modifichi:** commit su GitHub → dopo ~1 minuto l'app si
aggiorna da sola su tutti i telefoni. Non serve rifare l'APK.

### Configurazione Firebase (dentro l'HTML, in cima)
```js
const firebaseConfig = {
  apiKey: "AIzaSyCPKNvtnM1nCPxLPyfzBUqaz6gqsc9THkU",
  authDomain: "demoonline-7c881.firebaseapp.com",
  projectId: "demoonline-7c881",
  storageBucket: "demoonline-7c881.firebasestorage.app",
  messagingSenderId: "1053541344307",
  appId: "1:1053541344307:web:6d44b0db8393e5a0ef6f46"
};
```

---

## 2. L'app Android (il "guscio")

Progetto Flutter: `.../Phone_projects/Calcula/calcula/`

### `lib/main.dart`
Il codice dell'app. Fa tre cose:
- apre il sito a schermo intero (WebView)
- gestisce il selettore file per importare i backup
- programma la notifica serale del turno del giorno dopo

### `android/app/src/main/AndroidManifest.xml`
Permessi da avere dentro `<manifest>`, prima di `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Dentro il blocco `<queries>` (serve per aprire i file dei backup):
```xml
<intent>
  <action android:name="android.intent.action.GET_CONTENT"/>
  <data android:mimeType="*/*"/>
</intent>
<intent>
  <action android:name="android.intent.action.OPEN_DOCUMENT"/>
  <data android:mimeType="*/*"/>
</intent>
```

Il nome dell'app si cambia qui: `android:label="ADTurnistica"`

### `android/app/build.gradle.kts`
Necessario per le notifiche (senza, il build fallisce):
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### `pubspec.yaml` — pacchetti installati
```
webview_flutter
webview_flutter_android
file_picker
share_plus
path_provider
flutter_local_notifications
timezone
flutter_launcher_icons   (dev)
```

Comando per reinstallarli tutti da zero:
```
flutter pub add webview_flutter webview_flutter_android file_picker share_plus path_provider flutter_local_notifications timezone
flutter pub add --dev flutter_launcher_icons
```

### `assets/icon/icon.png`
L'icona dell'app. Configurazione in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/icon.png"
```
Per rigenerare le icone: `dart run flutter_launcher_icons`

---

## 3. Comandi utili

```bash
# stare sempre nella cartella del progetto (quella con pubspec.yaml)
cd .../Calcula/calcula

flutter pub get              # installa i pacchetti
flutter analyze              # controlla errori nel codice
flutter clean                # pulisce la cache quando il build fa i capricci
flutter build apk --release  # crea l'APK
```

L'APK finito si trova in:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Regole importanti

- **Mai disinstallare l'app dal telefono di papà**: cancella tutti i dati.
  Installare il nuovo APK *sopra* al vecchio li mantiene.
- **I dati stanno nel telefono** (localStorage del browser), non su GitHub
  e non nell'APK. L'unico modo per spostarli è Esporta/Importa backup.
- Chrome e l'app Flutter hanno **archivi separati**: i dati inseriti in uno
  non compaiono nell'altro.
- Modifiche al sito → solo commit. Modifiche a notifiche/icona/nome → serve
  un nuovo APK.

---

## 5. Cose rimaste in sospeso

- Regole di sicurezza del database Firebase (ora è in "modalità test",
  cioè aperto a chiunque — va chiuso prima di dare l'app ai colleghi)
- Ammorbidire il testo del pulsante "Entra senza account online"
- Provare lo scambio turni con due account diversi

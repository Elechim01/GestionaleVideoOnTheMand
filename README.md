# 📺 Gestionale Video On The Mand

**Gestionale Video On The Mand** è una soluzione professionale per la gestione, l'archiviazione e lo streaming di contenuti video. Sviluppata in SwiftUI, l'applicazione permette di amministrare una libreria digitale con un focus particolare su prestazioni, sicurezza e monitoraggio delle risorse cloud.

---

## 🚀 Funzionalità Principali

### 📤 Caricamento Video & Anteprime
* **Upload Intelligente**: Sistema di caricamento verso Firebase Storage ottimizzato.
* **Generazione Thumbnail**: Utilizzo integrato di `QuickLook` e `AVFoundation` (tramite **ElechimCore**) per estrarre anteprime istantanee dai video, garantendo un'interfaccia fluida e visuale.
* **Gestione Metadati**: Archiviazione su Firestore di dettagli tecnici come durata, risoluzione e data di inserimento.

### 📊 Controllo dello Spazio (Storage Monitoring)
* **Monitoraggio Occupazione**: Visualizzazione in tempo reale dello spazio utilizzato rispetto ai limiti del piano cloud.
* **Ottimizzazione**: Strumenti per la pulizia della cache e la rimozione sicura dei contenuti per liberare storage.

### 🔐 Autenticazione & Sicurezza
* **Accesso Riservato**: Autenticazione sicura tramite **Firebase Auth**.
* **Gestione Sessioni**: Supporto avanzato per la persistenza dell'utente e gestione dei Refresh Token per la massima sicurezza.
* **Permessi Granulari**: Controllo degli accessi per distinguere tra amministratori (upload/delete) e utenti (view).

---

## 🏗 Architettura Modulare

Il progetto segue una filosofia di sviluppo modulare per facilitare la manutenzione e il riutilizzo del codice:

1. **App UI (GestionaleVideoOnTheMand)**: L'interfaccia utente nativa in SwiftUI (macOS/iOS).
2. **[Services](https://github.com/Elechim01/Services)**: Il "braccio operativo" che gestisce la logica di business e l'integrazione con Firebase.
3. **[ElechimCore](https://github.com/Elechim01/ElechimCore)**: Il "motore" che contiene utility di sistema, logger personalizzati e gestione centralizzata degli errori.

---

## 💻 Requisiti Tecnici
* **Piattaforme**: macOS 11.0+ (Big Sur) / iOS 18.0+
* **Linguaggio**: Swift 6.0
* **Backend**: Firebase (Auth, Firestore, Storage)
* **Framework**: SwiftUI, Combine, QuickLookThumbnailing

---

## 🛠 Installazione e Setup

1. **Clona il progetto principale**:
   ```bash
   git clone [https://github.com/Elechim01/GestionaleVideoOnTheMand.git](https://github.com/Elechim01/GestionaleVideoOnTheMand.git)

# Piano di Sviluppo per Refactoring Ticksy con Clean Architecture

---

## 🎯 Obiettivo
Passare da una struttura base a una architettura modulare, pulita e scalabile, usando:

- Separazione in layers (presentation, domain, data)
- Dependency inversion (interfacce e implementazioni separate)
- Testabilità e manutenibilità migliorate

---

## 🔨 Step Operativi

### 1. Preparazione generale

- [ ] Studia il file `clean_architecture_flutter.md` per familiarizzare con i concetti
- [ ] Prepara una cartella `domain/` per ogni feature che ancora non ce l'ha
- [ ] Centralizza i modelli usati in più feature in `core/models/`
- [ ] Centralizza i servizi comuni in `core/services/`

---

### 2. Refactoring di una feature di esempio (es. `auth`)

- [ ] Crea la cartella `domain/` con:
  - Entities
  - Repository interface
  - Use cases

- [ ] Sposta le implementazioni dei repository in `data/repositories/`
- [ ] Estrai i servizi esterni (Supabase, Firestore) in `core/services/` o in `data/services/`
- [ ] Implementa un ViewModel o Provider in `presentation/viewmodels/` per la UI

**Goal:** fare in modo che UI chiami solo ViewModel → UseCase → Repository Interface → Repository Impl → Servizio.

---

### 3. Aggiorna la UI e la gestione dello stato

- [ ] Usa Provider/ChangeNotifier solo nella Presentation
- [ ] Evita di usare servizi o chiamate Firestore direttamente nella UI
- [ ] Passa dati e comandi solo tramite UseCases

---

### 4. Ripeti per le altre feature

- [ ] `feed/`
- [ ] `wallet/`
- [ ] `memories/`
- [ ] `profile/`

Con lo stesso schema domain/data/presentation.

---

### 5. Testing

- [ ] Scrivi test unitari per UseCases
- [ ] Scrivi test mockando repository
- [ ] Testa la UI con i ViewModel

---

### 6. Miglioramenti e ottimizzazioni

- [ ] Introduci Dependency Injection (es. get_it o riverpod) per i servizi
- [ ] Migliora gestione errori e loading nello stato
- [ ] Organizza costanti e temi in `core/`

---

## 📅 Timeline (indicativa)

| Settimana | Attività                                 |
|-----------|-----------------------------------------|
| 1         | Studio e refactoring Auth completo      |
| 2         | Refactoring Feed e Wallet                |
| 3         | Refactoring Memories e Profile           |
| 4         | Testing, ottimizzazioni, dependency inj |

---

## 📌 Consigli

- Fai commit frequenti, salva ogni passo
- Mantieni tutto documentato
- Non cercare la perfezione subito: funzionalità prima, pulizia poi
- Se qualcosa è troppo complesso, chiedi aiuto o rallenta per capire bene

---

## 💬 Vuoi posso aiutarti con esempi di codice per ogni step, o scrivere template da copiare?

---


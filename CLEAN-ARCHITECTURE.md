# Guida Completa alla Clean Architecture in Flutter

> Questa guida ti spiega tutti i concetti fondamentali della Clean Architecture applicata a Flutter, con nomi chiari, esempi e dove scrivere ogni cosa nel tuo progetto.

---

## Introduzione

La Clean Architecture separa il codice in **livelli** per rendere il progetto:
- ✅ Manutenibile
- ✅ Scalabile
- ✅ Testabile
- ✅ Più facile da capire e modificare

---

## I 3 Livelli Principali

### 1. Presentation Layer

La **UI** e la logica di interazione dell'utente.

**Contiene:**
- Widget (`StatelessWidget`, `StatefulWidget`)
- Screens
- ViewModel o Provider

📁 `/features/auth/presentation/`

---

### 2. Domain Layer

La parte **più importante**. Contiene la **logica di business** pura.

**Contiene:**
- Entità (model "puliti", es. `User`, `Ticket`)
- Use Cases (cosa può fare l’utente, es. `SignIn`, `AddTicket`)
- Interfacce dei repository (`AuthRepository`, `TicketRepository`)

📁 `/features/auth/domain/`

---

### 3. Data Layer

Serve per comunicare con il mondo esterno: API, database, Supabase, Firestore...

**Contiene:**
- Repository Implementation
- Servizi esterni (`SupabaseService`, `FirestoreService`)
- Model che arrivano da Supabase/Firestore (`DTO`)

📁 `/features/auth/data/`

---

## Il Flusso dei Dati

UI (presentation)
↓
Use Case (domain)
↓
Repository Interface (domain)
↓
Repository Impl. (data)
↓
Servizi / API / DB (data)


Esempio:
- UI chiama `SignInUseCase`
- Il UseCase chiama `AuthRepository`
- `AuthRepositoryImpl` usa `SupabaseAuthService` per fare login

---

## Concetti Chiave

### Entità

Modelli puri, senza logica esterna. Es.:

```dart
class User {
  final String id;
  final String email;

  User({required this.id, required this.email});
}

📁 /domain/entities/user.dart


Use Case
Classe che contiene una sola azione dell'utente.

class SignInUseCase {
  final AuthRepository repo;

  SignInUseCase(this.repo);

  Future<User> call(String email, String password) {
    return repo.signIn(email, password);
  }
}

📁 /domain/usecases/sign_in_usecase.dart

Repository Interface

Definisce cosa puoi fare. NON COME.

abstract class AuthRepository {
  Future<User> signIn(String email, String password);
}

📁 /domain/repositories/auth_repository.dart

Repository Implementation
Implementa l’interfaccia e usa i servizi per accedere a Firestore/Supabase.


class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthService service;

  AuthRepositoryImpl(this.service);

  @override
  Future<User> signIn(String email, String password) async {
    final data = await service.login(email, password);
    return User(id: data.id, email: data.email);
  }
}
📁 /data/repositories/auth_repository_impl.dart

Servizi Esterni
Supabase, Firestore, REST API, ecc...


class SupabaseAuthService {
  Future<SupabaseUser> login(String email, String password) async {
    final result = await supabase.auth.signInWithPassword(...);
    return result.user!;
  }
}
📁 /core/services/supabase_auth_service.dart

Provider / ViewModel
Usato nella UI per collegare i UseCase ai widget.

dart
Copia
Modifica
class AuthViewModel extends ChangeNotifier {
  final SignInUseCase signInUseCase;

  AuthViewModel(this.signInUseCase);

  Future<void> signIn(String email, String password) async {
    final user = await signInUseCase(email, password);
    // salva l'utente nello stato, notifica UI ecc
  }
}

📁 /presentation/viewmodels/auth_viewmodel.dart

Regole della Clean Architecture
La UI non conosce i servizi o Firestore: parla solo con i UseCase.

Il Domain non importa nulla da data/.

Le dipendenze vanno solo verso l’interno (UI → domain → data).

Organizzazione consigliata del progetto
css
Copia
Modifica
lib/
├── core/
│   ├── theme/
│   ├── services/
│   ├── models/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       ├── screens/
│   │       └── widgets/
│   └── ...
└── main.dart

Testing
I UseCase sono facili da testare: sono solo funzioni!

Puoi fare mock dei Repository.

Scrivi test su Presentation + UseCase prima di tutto.

Checklist quando crei una nuova feature
 Scrivi i model puri (entities)

 Crea i usecases per le azioni principali

 Scrivi l’interfaccia repository

 Implementa il repository nella cartella data

 Crea un servizio Firestore/Supabase se serve

 Collega la UI usando un ViewModel o Provider

Consiglio Finale
Non serve essere perfetti. Parti da una feature semplice come auth e applica questo schema. Migliora il resto poco a poco.
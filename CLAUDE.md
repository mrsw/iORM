# Regole di codifica Delphi

## Prefissi identificatori

Rispettare sempre i seguenti prefissi:

| Prefisso | Uso |
|---|---|
| `F` | Field privato/protetto di classe |
| `A` | Parametro di funzione/procedura |
| `L` | Variabile locale |
| `C_` | Costante (non stringa) |
| `S_` | Costante stringa (`const` o `resourcestring`) |
| `T` | Tipo (class, record, enum, alias) |
| `I` | Interfaccia |
| `E` | Eccezione |

## Nomi leggibili, niente abbreviazioni

Usare sempre nomi completi e autoesplicativi. Nessuna troncatura, neanche abbreviazioni di uso comune.

- `FHasSelection` non `FHasSel`
- `LParagraph` non `LPara`
- `LLayout` non `LL`
- `BackgroundColor` non `BGColor`
- `SelectionColor` non `SelColor`
- `Position` non `Pos`

La regola vale per field (`F`), variabili locali (`L`), parametri (`A`), costanti (`C_`).

## Parametri booleani

I parametri di tipo `Boolean` non usano il prefisso `A`. Si scrivono con il solo nome:

```delphi
procedure SetBold(Bold: Boolean);       // corretto
procedure SetBold(ABold: Boolean);      // sbagliato
```

## Parametri setter — code completion

I getter/setter generati dal code completion di Delphi usano il nome convenzionale `Value` (senza prefisso `A`). Il prefisso `A` si applica solo ai metodi e funzioni implementati esplicitamente:

```delphi
procedure SetName(const Value: string);    // setter — corretto
procedure DoSomething(const AName: string); // metodo esplicito — corretto
```

## Parametri `const`

Dichiarare `const` tutti i parametri di tipo gestito (stringhe, interfacce, array dinamici, record) che non vengono modificati nel corpo del metodo:

```delphi
procedure Process(const AName: string; const AService: IMyService); // corretto
procedure Process(AName: string; AService: IMyService);              // evitare
```

Per i tipi non gestiti (interi, float, booleani, enumerati) il `const` è opzionale.

## Nomi dei metodi — prefissi operazionali

Usare prefissi coerenti per i metodi che operano su elementi esistenti:

| Prefisso | Significato |
|---|---|
| `Insert*` | Crea e inserisce un elemento nuovo |
| `Update*` | Modifica un elemento esistente al cursore |
| `Delete*` | Elimina un elemento |

**Prefissi semantici booleani ed eventi**

| Prefisso | Significato |
|---|---|
| `Is*`, `Has*`, `Can*` | Restituisce un booleano che descrive lo stato dell'oggetto (es. `IsEmpty`, `HasSelection`, `CanSave`) |
| `Do*` | Esegue un'azione o scatena un evento interno |
| `On*` | Handler di evento; il field corrispondente si chiama `FOn*` |

## Costanti

- Tutte maiuscole: `C_EDITOR_FONT_SIZE`
- Parole composte separate da underscore: `C_EDITOR_FONT_NAME` non `C_EditorFontName`
- Per costanti che rappresentano valori iniziali di proprietà modificabili, usare il prefisso `DEFAULT` dopo `C_`: `C_DEFAULT_SELECTION_COLOR`

## Formattazione

**Indentazione e struttura di base**
- Indentazione: **2 spazi** (niente tab)
- `begin` e `end` sempre su riga propria
- Vietati: `with`, `Break`, `Continue`

**Parole chiave**

Le parole chiave del linguaggio si scrivono sempre in **minuscolo**: `begin`, `end`, `uses`, `interface`, `implementation`, `nil`, `string`, `integer`, `boolean`, `var`, `type`, `const`, `procedure`, `function`, `class`, `record`, `if`, `then`, `else`, `for`, `to`, `do`, `while`, `repeat`, `until`, `case`, `try`, `except`, `finally`, `raise`, `inherited`, ecc.

**Spaziatura**
- Un spazio attorno agli operatori binari: `A + B`, `A := B`, `A = B`
- Un spazio dopo la virgola: `Foo(A, B, C)`
- Nessuno spazio prima di `(`: `Foo(X)` non `Foo (X)`
- Nessuno spazio prima di `:` nelle dichiarazioni: `Name: string` non `Name : string`
- Nessuno spazio dentro `()` e `[]`: `(A, B)` non `( A, B )`, `Items[I]` non `Items[ I ]`

**Istruzione `if`**
- Almeno 2 righe; mai tutto su una riga
- Nessuna parentesi extra attorno alla condizione: `if X > 0 then` non `if (X > 0) then`
- `begin` su riga propria dopo `then` e dopo `else`

```delphi
if LValue > 0 then
begin
  Process(LValue);
end
else
begin
  Reset;
end;
```

**Metodi anonimi**
- Mai inline: `begin` sempre su riga propria
- Nessuno spazio tra `procedure`/`function` e `(`:

```delphi
// corretto
TThread.ForceQueue(nil,
  procedure
  begin
    DoSomething;
  end);

// sbagliato
TThread.ForceQueue(nil, procedure begin DoSomething; end);
```

**Righe vuote**
- Una riga vuota tra le implementazioni consecutive dei metodi
- Una riga vuota tra le dichiarazioni di classe consecutive
- Nessuna riga vuota consecutiva (mai due righe vuote adiacenti)

**Continuazione di riga**
- Rientro di 2 spazi rispetto alla riga di apertura
- L'operatore binario termina la riga precedente, non inizia quella di continuazione:

```delphi
LResult := LFirstValue +
  LSecondValue +
  LThirdValue;
```

**Verifica `nil`**

Entrambe le forme sono accettabili: `if LObject <> nil then` e `if Assigned(LObject) then`.

## Variabili inline

In generale, dichiarare le variabili nella sezione `var` della funzione o procedura. Eccezioni ammesse:

1. Contatori di ciclo `for`: `for var I := 0 to N do` è accettabile
2. Variabili inline in blocchi condizionali la cui unica uscita è `Exit`:
   ```delphi
   if Condition then
   begin
     var LValue := Compute;
     // ... usa LValue ...
     Exit;
   end;
   ```

In nessun caso usare variabili inline in cicli quando la variabile è riutilizzata all'interno del ciclo stesso.

## Struttura delle classi

**Ordine degli specificatori di accesso**

L'ordine delle sezioni all'interno di una classe è fisso:
1. `strict private`
2. `private`
3. `strict protected`
4. `protected`
5. `public`
6. `published`

**Ordine all'interno di ogni sezione**

Rispettare questo ordine all'interno di ogni sezione di visibilità, con **una riga vuota** tra ogni gruppo:

**`public`**
1. Metodi di classe (`class function`, `class procedure`)
2. Costruttori e distruttori (`constructor`, `destructor`)
3. Altri metodi (`procedure`, `function`)
4. Proprietà (ordine alfabetico; eventi `OnXxx` in fondo)

**`protected` e `private`**
1. Campi (`F…`)
2. Metodi
3. Proprietà

I costruttori e distruttori appartengono solo alla sezione `public`.

## Proprietà

- Elenco in **ordine alfabetico** all'interno di ogni sezione
- Gli **eventi** (`OnXxx`) sempre in fondo all'elenco, dopo tutte le altre proprietà
- Usare il **field diretto** nella dichiarazione della property quando non c'è logica aggiuntiva:
  ```delphi
  property HasSelection: Boolean read FHasSelection;  // corretto
  property HasSelection: Boolean read GetHasSelection; // sbagliato se GetHasSelection fa solo Result := FHasSelection
  ```
- Usare metodi getter/setter solo quando: (1) c'è logica da eseguire, oppure (2) la classe implementa un'interfaccia che li richiede

## Namespace delle unit modello — plurale

Il segmento di namespace che identifica l'entità modello usa sempre il **plurale**:

```
App.Model.Customers.pas          ✓
App.Model.Customers.Abstracts.pas ✓
App.Model.Customers.Types.pas    ✓
App.Model.Customer.pas           ✗
```

Motivo: il segmento rappresenta un dominio (area funzionale), non un'istanza singola. I companion unit (`.Abstracts`, `.Types`, `.Strings`) leggono naturalmente come sotto-namespace del dominio plurale.

## Tipi semplici — unit `.Types`

Le definizioni di tipi semplici (enumerati, set, alias, record senza metodi) vanno in una unit companion dedicata con suffisso `.Types` nel namespace di appartenenza:

```
App.Model.User.pas          → classe TAppUser
App.Model.User.Abstracts.pas → interfaccia IAppUser
App.Model.Users.Types.pas   → TUserRole (enum), altri tipi semplici
```

Regole:
- Il suffisso `.Types` si aggiunge al namespace base (es. `App.Model.Users.Types`, non `App.Model.User.Types`).
- La unit `.Types` non ha dipendenze (o dipendenze minime): può essere usata ovunque senza rischi di dipendenze circolari.
- Le unit `.Abstracts` e le classi usano i tipi importandoli da `.Types`.
- Non mettere tipi semplici direttamente nelle unit `.Abstracts` o nelle classi.

## Sezione `uses` — posizionamento corretto

Aggiungere ogni unit alla sezione `uses` corretta in base a dove il suo contenuto viene effettivamente usato:

- **`uses` in `interface`**: solo se il tipo o l'identificatore è usato in una dichiarazione visibile nell'interfaccia (dichiarazioni di tipo, firme di metodi, campi pubblici/protetti).
- **`uses` in `implementation`**: se il tipo o l'identificatore è usato esclusivamente all'interno dei corpi dei metodi (sezione `implementation`).

```delphi
// Corretto: IMyInterface usata nella firma del metodo → interface uses
interface
uses
  My.Interfaces;

// Corretto: THelper usata solo nel corpo del metodo → implementation uses
implementation
uses
  My.Helper;
```

Non aggiungere unit all'`interface` uses per comodità: ogni dipendenza superflua nell'interfaccia aumenta il coupling e i tempi di compilazione.

**Formato**

Ogni unit va su **riga propria**, indentata di **2 spazi**, con virgola dopo ciascuna (punto e virgola solo sull'ultima):

```delphi
uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls;
```

Mai elencare più unit sulla stessa riga.

## Messaggi di validazione — pattern `resourcestring` + unit `.Strings`

Per ogni classe modello che implementa `IsValid`, i messaggi di errore/avviso vanno dichiarati come `resourcestring` in una unit companion dedicata, con suffisso `.Strings`:

```
App.Model.Customer.pas          → unit principale del modello
App.Model.Customer.Strings.pas  → resourcestring per la validazione
```

Struttura della unit `.Strings`:

```delphi
unit App.Model.Customer.Strings;

interface

resourcestring
  SCustomerNameRequired = 'Customer name is required.';

implementation
end.
```

Regole:
- Le `resourcestring` vanno dichiarate nella sezione `interface` della unit `.Strings` (devono essere accessibili da fuori).
- La unit `.Strings` va aggiunta alla sezione `implementation uses` della unit modello (le stringhe sono usate solo dentro `IsValid`).
- I nomi delle costanti seguono il prefisso `S` (vedi tabella prefissi).
- I messaggi sono scritti in inglese.
- Questo pattern è compatibile con dxGetText: `HookIntoResourceStrings` intercetta automaticamente tutte le chiamate `LoadResString` a runtime, traducendo le `resourcestring` senza modifiche al codice.

## File .pas — line ending

Scrivere sempre i file `.pas` con line ending **CRLF** (`\r\n`). I file con soli LF compilano ma l'IDE Delphi non riesce a eseguire il refactoring dei nomi. Quando si genera un file `.pas` via PowerShell, normalizzare prima di scrivere:

```powershell
$c = ($c -replace "`r`n", "`n") -replace "`n", "`r`n"
[System.IO.File]::WriteAllText($path, $c, [System.Text.Encoding]::UTF8)
```

Per file contenenti caratteri non-ASCII (emoji, ecc.) usare UTF-8 con BOM (`[System.Text.Encoding]::UTF8` in .NET include il BOM).

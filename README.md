# NeonC
IDE nativo per C e C++ su macOS (in sviluppo)

NeonC è un editor/IDE leggero scritto in Swift, basato su Liquid Glass, pensato per sviluppare in C e C++ su macOS con un’esperienza moderna e perfettamente integrata nel sistema. Il progetto è attualmente in fase attiva di sviluppo: molte funzionalità sono sperimentali o pianificate.

> Stato: sperimentale • Base: Liquid Glass • Compatibilità: macOS 26+ • Linguaggio: Swift

Nota di compatibilità: al momento NeonC è supportato ed è stato testato esclusivamente su macOS 26. Le versioni precedenti non sono supportate per adesso.

---

## Perché NeonC in futuro?
- Nativo macOS: interfaccia fluida, scorciatoie da tastiera familiari, integrazione con toolchain Apple (clang/LLDB).
- Focus su C/C++: evidenziazione sintassi, diagnostiche del compilatore e ciclo modifica–compila–esegui semplificato.
- Basato su Liquid Glass: fondazioni moderne per un’interfaccia reattiva e prestazioni elevate.
- Leggero e diretto: pensa più a “codice e build” che a configurazioni complesse.

---

## Funzionalità

Funzionalità disponibili (baseline):
- Apertura di cartelle/progetti esistenti.

Funzionalità pianificate / in corso:
- Editor con evidenziazione sintattica per C/C++.
- Integrazione con toolchain di sistema (clang/clang++).
- Compilazione ed esecuzione da interfaccia (configurazioni minime).
- Autocompletamento e diagnostiche tramite LSP (clangd).
- Debug integrato con LLDB (breakpoint, step, watch).
- Gestione configurazioni di build (Release/Debug, flag personalizzati).
- Terminale integrato e pannello output.
- Temi (chiaro/scuro) e personalizzazione font.
- Modelli di progetto (eseguibile, libreria statica/dinamica, tests).
- Navigazione simboli, “Go to Definition”, “Find References”.
- Refactoring di base (rinomina simboli).
- Supporto a CMake e compilation database (compile_commands.json).

Se vuoi contribuire a una di queste aree, vedi la sezione “Contribuire”.

---

## Requisiti
- macOS 26.
- Xcode 26 installato (per toolchain clang/LLDB e SDK).
- Xcode Command Line Tools: `xcode-select --install`
- (Opzionale) Homebrew per gestire LLVM/clangd: `brew install llvm clangd`

---

## Installazione da sorgente

1) Clona il repository:
```bash
git clone https://github.com/eliorodr2104/NeonC.git
cd NeonC
```

2) Apri il progetto in Xcode:
- Cerca e apri il file del progetto (es. `NeonC.xcodeproj` o `NeonC.xcworkspace`) se presente.
- In alternativa, apri la cartella in Xcode e genera lo schema di build.

4) Compila ed esegui l’app da Xcode (⌘R).

Nota: se in futuro verrà fornito uno script di build o un pacchetto, questa sezione verrà aggiornata.

---

## Utilizzo (anteprima)
- Apri una cartella con file C/C++.

---

## Roadmap
- Fase 1: Stabilizzare editor, integrazione clang, pannello errori di compilazione.
- Fase 2: Autocompletamento e diagnostiche via clangd, navigazione simboli.
- Fase 3: Debug LLDB integrato, breakpoint e variabili locali.
- Fase 4: Supporto CMake e progetti multi-target, temi e preferenze avanzate.
- Fase 5: Estensioni/plug-in e ottimizzazioni performance.

---

## Struttura (indicativa)
- App macOS in Swift (SwiftUI/AppKit dove necessario).
- Moduli per:
  - Editor e parsing di base.
  - Integrazione toolchain (clang/clang++, LLDB).
  - LSP client (clangd) per C/C++.
  - Gestione progetti e configurazioni di build.
- Fondazioni UI basate su Liquid Glass.

La struttura può evolvere durante lo sviluppo.

---

## Contribuire
Contributi e feedback sono benvenuti!

- Apri un’issue per:
  - Bug, richieste di funzionalità, domande di progettazione.
- Proponi una PR:
  - Discuti prima l’approccio in un’issue.
  - Mantieni le modifiche piccole e ben documentate.
  - Includi note su test manuali e ambiente usato (macOS/Xcode version).

Linee guida consigliate:
- Swift 5.9+ / Xcode 26.
- Segui lo stile Swift e commenta le parti non ovvie.
- Evita dipendenze non necessarie; preferisci API di sistema quando possibile.

---

## Segnalazione bug
- Descrizione chiara del problema.
- Passi per riprodurre.
- Log/Output di compilazione (se possibile).
- Versione macOS (26), Xcode e toolchain usata.

---

## Screenshot
- In arrivo (work in progress).
- Cartella prevista: `docs/` (es. `docs/screenshot-editor.png`).

---

## Licenza

---

## Contatti e link
- Repository: https://github.com/eliorodr2104/NeonC
- Issue: https://github.com/eliorodr2104/NeonC/issues

Se ti interessa NeonC, lascia una stella al repository e partecipa alla discussione sulle feature che vorresti vedere!

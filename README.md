# NeonC
IDE nativo per C e C++ su macOS (in sviluppo)

NeonC è un IDE leggero scritto in Swift e SwiftUI, con grafica basata su Liquid Glass, pensato per lo sviluppo in C e C++ su macOS con un’esperienza moderna e perfettamente integrata nel sistema. Il progetto è attualmente in fase attiva di sviluppo: molte funzionalità sono sperimentali o pianificate.

> Stato: sperimentale • Base: Liquid Glass • Compatibilità: macOS 26+ • Linguaggio: Swift

Nota di compatibilità: al momento NeonC è supportato ed è stato testato esclusivamente su macOS 26. Le versioni precedenti non sono supportate per adesso.

---

## Perché usare NeonC una volta finito lo sviluppo?
- Nativo macOS: interfaccia fluida, scorciatoie da tastiera familiari, integrazione con toolchain Apple (clang/LLDB).
- Focus su C/C++: evidenziazione sintassi, diagnostiche del compilatore e ciclo modifica–compila–esegui semplificato.
- Leggero e diretto: pensa più a “codice e build” che a configurazioni complesse.

---

## Funzionalità

Funzionalità disponibili (baseline):
- Apertura di cartelle/progetti esistenti.
- Visualizzazione della modalità editor con view ad albero delle sotto cartelle.
- Integrazione del toolchain di sistema (Xcode command line, clang/clang++, make, cmake e ninja).
- Possibilita di creare dei progetti C selezionando anche la versione del linguaggio.

Funzionalità pianificate / in corso:
- Editor con evidenziazione sintattica per C/C++.
- Compilazione ed esecuzione da interfaccia (configurazioni minime).
- Autocompletamento e diagnostiche tramite LSP (clangd).
- Debug integrato con LLDB (breakpoint, step, watch).
- Gestione configurazioni di build (Release/Debug, flag personalizzati).
- Terminale integrato e pannello output.
- Temi (chiaro/scuro) e personalizzazione font.
- Modelli di progetto (eseguibile, libreria statica/dinamica, tests).
- Navigazione simboli, “Go to Definition”, “Find References”.
- Refactoring di base (rinomina simboli).
- Supporto a CMake e compilation database.

---

## Requisiti
- macOS 26.
- Xcode 26 installato (per toolchain clang/LLDB e SDK).
- Xcode Command Line Tools: `xcode-select --install`

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

---

## Utilizzo (alpha version)
- Apri una cartella con file C/C++.
- Crea un progetto C.
- Apri il progetto e visualizza le cartelle.

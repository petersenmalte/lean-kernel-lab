# Partition: reproduzierbare Entwicklung

Offizieller Quellstand: `940f0a2ead23ef70ab1387edabb347e629111edd` aus
<https://github.com/SAIRcompetition/lean-kernel-challenge>.
Toolchain: `leanprover/lean4:v4.33.1`. Für `partition` sind ausschließlich
Lean-Core-Abhängigkeiten vorgesehen; es gibt keine zusätzliche Dependency-Lock-Datei.
Die Abhängigkeitsliste des Teilnehmerpakets ist leer.

`pins.json` hält die Prüfsummen der festen Dateien und die Hostinformationen fest.
Das offizielle Repository liegt unverändert in `../official/lean-kernel-challenge/`
und wird wegen seiner eigenen Git-Historie nicht in dieses Repository aufgenommen.
Die eigentliche Einreichungsdatei wird in `../partition/Submission.lean` abgelegt.
Es erfolgt keine externe Einreichung.

## Prüfungen und Messgrenzen

Compiler-Erfolg, universeller Beweis, Comparator-/Axiomprüfung und Kernel-Replay
sind getrennte Ergebnisse. `lake build` allein belegt keine Evaluator-Akzeptanz.
Der offizielle lokale Evaluator verwendet den vollständigen ungesetzten öffentlichen
Plan `14, 18, 22, 26, 32, 36` und eine Wall-Time-Wiederholung.
Die Standard-Zeitbudgets werden nicht verändert.

Dieser Host ist macOS/ARM64. Die offiziellen Linux-PMU-Instruktionszahlen,
Container-Isolation, cgroup-Speichergrenzen und drei Wiederholungen sind hier
nicht reproduziert. Lokale Zeitvergleiche ergeben keinen offiziellen Rang.
Fehlende oder fehlgeschlagene Messungen werden nicht als Null behandelt.

## Ausgangspunkt

`baseline/Submission.lean` ist die unveränderte Starterdatei. Das offizielle
ausgearbeitete Beispiel hat denselben Algorithmus: `impl := partitionSpec`,
mit reflexivem universellem Beweis. Der erste Build mit Lean 4.33.1 war erfolgreich.

## Geprüfter erster Zwischenstand

Die aufsteigende Tabellenlösung ist vollständig geprüft, SHA-256
`53f902a8b614265c70d14afbfd04e3cc40fce2d6948efa6790ecdb6be6af4149`.
Build, Comparator, Axiom-Audit, Korrektheits-Replay und alle sechs öffentlichen
Fälle bestanden. Die Summe der lokalen Kernel-Laufzeiten beträgt 2,280962626 s
gegenüber 26,256420206 s beim Starter. Details und Einzelwerte stehen in
`evidence/MULTIPLICITY_DP.md`; die geprüfte erste Variante bleibt unter
`algorithm/Submission.lean` erhalten. Dies ist kein offizieller Instruktionsvergleich.

## Reproduktion

Voraussetzungen: Git, Python 3.9+, elan, C/C++-Toolchain; auf macOS zusätzlich
GNU coreutils (`brew install coreutils`). Vom Wurzelverzeichnis dieses Repositorys:

```bash
bash partition-work/setup.sh
bash partition-work/reproduce.sh "$PWD/partition-work/baseline/Submission.lean" baseline
bash partition-work/reproduce.sh "$PWD/partition/Submission.lean" final
```

Die Aufrufe nacheinander auf demselben freien Host ausführen. `setup.sh` klont
den festgelegten offiziellen Stand und baut dessen unveränderte Prüfwerkzeuge.
`reproduce.sh` ruft den offiziellen lokalen Evaluator mit expliziten Werkzeugpfaden
und unverändertem Standardbudget auf. Die JSON-Dateien enthalten die tatsächlich
ausgeführten Befehle, Prüfsummen, Policy und Einzelresultate. Ein zusätzlicher
Build erfolgt in einer temporären Kopie des festen Teilnehmerpakets.

## Untersuchte Ansätze

1. Eine Liste je maximaler Teilegröße, deren Einträge exakt dieselbe
   Multiplizitätensumme wie `partAux` berechnen. Invariante: Eintrag `m` der
   Zeile `k` stimmt für `m ≤ N` mit `partAux k m` überein.
2. Die Münzwechsel-Rekurrenz mit Wiederverwendung innerhalb einer Zeile.
   Sie verlangt zusätzlich einen bewiesenen Übergang von der festen
   Multiplizitätensumme zur Zweiterm-Rekurrenz.

Eine Array-Repräsentation ist nicht automatisch schneller im Kernel: die
Core-Definitionen von `Array.getInternal` und `Array.push` reduzieren auf
Listenoperationen. Native Laufzeiten wären hierfür kein belastbarer Nachweis.

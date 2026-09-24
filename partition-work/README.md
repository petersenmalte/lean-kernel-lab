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

## Ausgewählte Lösung

Die endgültig gewählte Variante ist die Münzwechsel-DP in
[`../partition/Submission.lean`](../partition/Submission.lean), SHA-256
`0fe392094beb40ce1672defec11443d58a5466605ebc0e283b39cf7cd752f575`.
Ihr erster vollständiger Evaluatorlauf bestand alle Prüfungen und Fälle mit
einer lokalen Fallzeitsumme von 0,636535499 s. Algorithmus und universeller
Beweis sind in [`../partition/README.md`](../partition/README.md) erklärt.

Die abschließende Wiederholung prüfte genau die integrierte Datei:
Build, Comparator, Axiom-Audit, Korrektheits-Replay und alle sechs Fälle bestanden.
Die Fallzeitsumme betrug **0,600999291 s**; eine unmittelbar vorausgehende
Wiederholung des Starters ergab **30,913962707 s**. Beide Durchläufe liefen
seriell mit denselben Einstellungen auf demselben Host. Die früheren Ergebnisse
(Starter 26,256420206 s, Coin-DP 0,636535499 s) bleiben zur Einordnung der
Wall-Time-Schwankungen erhalten. Der Vergleich ist kein offizieller Score.

| n | Starter, Wiederholung (s) | Finale Datei (s) |
| ---: | ---: | ---: |
| 14 | 0,073596125 | 0,021870834 |
| 18 | 0,235924458 | 0,036789083 |
| 22 | 0,765234000 | 0,062124791 |
| 26 | 1,966541458 | 0,097244333 |
| 32 | 8,482210416 | 0,163193750 |
| 36 | 19,390456250 | 0,219776500 |
| Summe | 30,913962707 | 0,600999291 |

Rohdaten: `evidence/baseline-refresh-20260924T065119Z-19cf636245f1/` und
`evidence/final-20260924T065307Z-0fe392094beb/`. Insbesondere enthalten
`verdict.json` die Comparator-, Audit-, Policy- und Replay-Ergebnisse und
`metadata.json` die geprüften Datei- und Werkzeugidentitäten.

Die separate Abschlussprüfung in einem frischen Teilnehmerpaket bestätigt den
exakten Theoremtyp und die Axiome `[propext, Quot.sound]`. Die veröffentlichten
Beispiele `0, 1, 4, 5, 10` bestehen jeweils per `rfl`. Reproduktion dieses
Zusatzchecks (aktualisiert dessen Logs im Evidenzverzeichnis):

```bash
python3 partition-work/evidence/final-20260924T065307Z-0fe392094beb/smoke.py
```

Die absteigende Multiplizitätstabelle wurde nach einem vollständigen Vergleich
verworfen: 2,670715499 s gegenüber 2,280962626 s für die aufsteigende Variante.
Beide waren korrekt; der Versuch brachte keinen gemessenen Geschwindigkeitsvorteil.
Die Varianten werden nicht weiter ausgebaut. Der dokumentierte Versuchsrahmen
umfasste zwei Algorithmen und zwei Darstellungen der ersten Variante.

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

## Offene Einschränkungen

Es sind keine Compiler-, Korrektheits- oder Fallfehler in den abschließend
geprüften Dateien offen. Die absteigende Darstellung wurde aus Leistungsgründen
verworfen. Offizielle PMU-Instruktionsmessung, geheimer Testplan, drei offizielle
Wiederholungen und Prüfung unter erzwungener 4-GiB-Containergrenze bleiben
unverfügbar. Ein globales Geschwindigkeitsoptimum wird nicht behauptet.

Der vom Nutzer verlinkte Contributor-Network-Webauftritt war über das Web-Werkzeug
nicht abrufbar; Regeln, Spezifikation und Evaluator wurden aus dem angeforderten
offiziellen Git-Repository gelesen und am oben genannten Commit festgehalten.

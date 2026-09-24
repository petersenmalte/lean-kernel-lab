# Partition-Einreichung

`Submission.lean` ist die einzelne Einreichungsdatei. Sie enthält alle benötigten
Hilfsdefinitionen und Beweise in `namespace Submission`, importiert ausschließlich
die feste `Spec` und hat die vorgeschriebene Schnittstelle:

```lean
impl : Nat → Nat
impl_correct : ∀ n, impl n = partitionSpec n
```

Die Datei ist für den offiziellen Repository-Commit
`940f0a2ead23ef70ab1387edabb347e629111edd` und Lean `4.33.1` geprüft.
SHA-256: `0fe392094beb40ce1672defec11443d58a5466605ebc0e283b39cf7cd752f575`.

## Algorithmus

Eine Zeile enthält die Partitionszahlen für alle Argumente `0` bis `n`, bei
festgelegter maximaler Teilegröße. Die Basiszeile ist `1 :: replicate n 0`.
Für eine neue Teilegröße `d = k + 1` gilt die Münzwechsel-Rekurrenz:

```text
neu[m] = alt[m] + neu[m-d]    für d ≤ m
neu[m] = alt[m]              für m < d
```

`fill` liest die alte Zeile von links nach rechts und hält das bereits berechnete
Präfix der neuen Zeile in umgekehrter Reihenfolge. Der zweite Summand steht dann
am Listenindex `k`. Ein noch nicht vorhandener Eintrag liefert null. Am Ende
wird die neue Zeile umgekehrt. Nach `n` Zeilen ist Eintrag `n` das Ergebnis.

Alle Rekursionen laufen strukturell über eine natürliche Zahl oder eine Liste.
Die Implementierung ist total und enthält keine Abhängigkeit von Beweistermen.
Sie berechnet für die rechteckige Tabelle `n(n+1)` neue Zellen mit jeweils einer
Addition. Listen-Lookups sind linear; diese Additionszahl ist daher ausdrücklich
keine Aussage über asymptotische Kernel-Kosten oder Bitkomplexität.

## Beweis

Zuerst wird die feste Multiplizitätssumme bei Index null aufgeteilt. Die übrigen
Indizes werden um eins verschoben. Daraus folgt die Zweiterm-Rekurrenz; unterhalb
der neuen Teilegröße besteht die Summe nur aus dem Nullindex.

Die Präfixinvariante lautet: Eintrag `i` des umgekehrten Akkumulators ist
`partAux (k+1) (acc.length-1-i)`. `next_correct` beweist den nächsten Wert,
`prefix_cons` erhält die Invariante, und `fill_correct` beweist die gesamte
neue Zeile. Eine Induktion über die Zeilenzahl liefert `row_correct` für alle
Indizes bis `n`. Dessen Spezialisierung auf Zeile und Index `n` ist exakt
`impl_correct`. Auch `n = 0` ist eingeschlossen.

## Prüfung und Reproduktion

Siehe [Entwicklungs- und Reproduktionsbericht](../partition-work/README.md)
für Befehle, Prüfergebnisse, Vergleichsvarianten und Einschränkungen.
Die erste vollständig geprüfte Tabellenvariante bleibt separat erhalten.
Keine feste Spezifikation und keine Evaluatordatei wurde verändert;
es wurde nichts bei der Challenge eingereicht.

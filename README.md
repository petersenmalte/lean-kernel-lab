# lean-kernel-lab

Das Setup ist projektlokal. Es enthält Arbeitsregeln, vier Skills und drei Spezialisten. Eine Wettbewerbslösung und der offizielle Challenge-Checkout sind noch nicht angelegt.

## Start in Codex

1. Das Repository klonen und den Ordner `lean-kernel-lab` als Projekt in Codex öffnen.
2. Eine neue Aufgabe im Projekt starten. Falls Skills oder Rollen nicht erscheinen, Codex neu starten. Projektkonfiguration wird nur geladen, wenn Codex dem Projekt vertraut; eine entsprechende Vertrauensabfrage selbst prüfen.
3. Als Hauptmodell GPT-6 Astra mit `high` wählen. Die Projektdatei setzt diese Vorgabe; eine explizite Auswahl in der App kann sie überschreiben.
4. Einen der folgenden Startaufträge verwenden. Es ist kein eigener API-Schlüssel und kein zusätzlicher Agentenserver für dieses lokale Setup nötig.

### Nur recherchieren und planen

> Nutze $lean-challenge-coordinator. Untersuche die Aufgabe partition aus dem offiziellen SAIR-Repository. Setze lean_algorithm und lean_proof für zwei unabhängige Analysen ein. Prüfe Spezifikation, vorhandene Beispiele, Algorithmusoptionen und Beweisaufwand. Implementiere noch keine Lösung. Liefere einen gemeinsamen Vorschlag mit offenen Fragen und einem Messplan.

### Später mit der Umsetzung beginnen

> Nutze $lean-challenge-coordinator und arbeite an partition. Bereite einen auf einen Commit festgelegten Checkout des offiziellen Repositorys vor, prüfe die Toolchain und erfasse eine Ausgangsmessung. Delegiere unabhängige Arbeit an lean_algorithm und lean_proof mit getrennten Dateien. Verwende lean_evaluator für reproduzierbare Prüfungen. Implementiere und beweise zunächst eine Verbesserung, integriere alles in eine gültige Submission.lean und prüfe sie. Keine externe Einreichung.

## Rollen und Dateien

| Rolle | Vorgabe | Zuständigkeit |
| --- | --- | --- |
| Hauptagent | Astra / high | Planung, Integration, finale Datei |
| lean_algorithm | Astra / high | Algorithmen und Datenrepräsentation |
| lean_proof | Astra / xhigh | Invarianten und Korrektheitsbeweis |
| lean_evaluator | Sol / high | Evaluator, Regeln, Messprotokoll |

Die Modelle sind eine Startempfehlung für diese Aufgabe, kein belegtes Lean-Benchmark-Ranking. Die TOML-Dateien lassen sich später anpassen. Bis zu drei Subagenten sind konfiguriert; normalerweise reichen zwei. Bei fehlender Modellverfügbarkeit soll der Hauptagent den tatsächlichen Fallback offenlegen.

- `AGENTS.md`: gemeinsame Regeln, Grenzen und Koordination.
- `.codex/config.toml`: Hauptmodell und Parallelitätsgrenze.
- `.codex/agents/*.toml`: wiederverwendbare Spezialistenrollen.
- `.agents/skills/*/SKILL.md`: Koordination, Optimierung, Beweise, Evaluation.

Skills sind Arbeitsanweisungen, keine laufenden Agenten. Erst ein Arbeitsauftrag führt zur Delegation. Die Dateien gewähren keine zusätzlichen Systemrechte. Es werden keine globalen Einstellungen verändert.

## Voraussetzungen und Grenzen

Benötigt werden Git sowie `lean` und `lake` (über elan). Die vom Wettbewerb geforderte Toolchain und Abhängigkeiten müssen beim ersten Arbeitsauftrag geprüft und gegebenenfalls installiert werden. Der erste Arbeitsauftrag muss den offiziellen Checkout, dessen Regeln und Versionsbindung prüfen. Für belastbare offizielle Instruktionsmessungen ist die dokumentierte Linux/PMU-Umgebung zu prüfen; lokale macOS-Laufzeiten ersetzen sie nicht.

Die Dateiformate und Verknüpfungen können lokal geprüft werden. Ob die App neue Rollen geladen hat, zeigt erst eine neue Aufgabe. Falls Rollen noch nicht verfügbar sind, kann der Hauptagent normale Subagenten mit denselben Rollen- und Skill-Anweisungen verwenden.

## Quellen

Stand der Einrichtung: 23. September 2026.
- [Codex Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Codex Skills](https://learn.chatgpt.com/docs/build-skills)
- [AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Offizielles Challenge-Repository](https://github.com/SAIRcompetition/lean-kernel-challenge)

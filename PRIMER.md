# PRIMER — osm-benchmarks-static

Arbeitsplan für `n4o-rse/osm-benchmarks-static` (Repo-Name: Vorschlag 2026-11-01). Wird zu Beginn jedes Chats hochgeladen (Bundle, siehe A5) und am Ende zurückgeschrieben. Stand: 2026-11-01 (S0: Festlegungen; History-Probe an den 21 Benchmark-Nodes, Befunde 1 bis 13; S1: Skeleton, Befund 14).

Sprache: dieses Dokument ist deutsch, alles andere im Repo (Code, Kommentare, README) ist britisches Englisch.

---

## Teil A — Immer gültig

### A1 Ausgangslage

| Repo | Rolle | Stand |
|---|---|---|
| `Research-Squirrel-Engineers/osm2lod` | Prototyp: Overpass-Abfrage je Export-Typ, CSV, TTL und QuickStatements je Lauf, Import in die echte Wikibase osm2wiki | vorhanden, wird nicht umgebaut |
| `n4o-rse/wikibase-static` | Paket (0.19.0): CSV (vier Tabellen) → Wikibase-JSON → Seiten, RDF, SPARQL; CRM-Overlay `data/crm.csv`; Muster für Verben mit Netz (`import-wikidata`, `import-open-archaeo`) | vorhanden; dort ist S15 („Konverter OSM und FACEM → CSV“) offen |
| `n4o-rse/osm-benchmarks-static` | dieses Repo: Site-Repo mit den Benchmarks als statische Wikibase | neu, S0 und S1 erledigt |
| `n4o-rse/fuzzy-sl-static`, `n4o-rse/chublets-wikibase-demo` | Vorlagen für Site-Repos: dünnes `main.py` (setzt `WBS_ROOT`), `site.yaml`, `requirements.txt` mit `wikibase-static @ git+…`, `update.cmd`, `.github/workflows/site.yml` als Aufrufer | vorhanden |

Nicht neu zu bauen: die Overpass-Abfrage und die Auswahl der Elemente (kommen aus osm2lod), CSV-Format, Seiten, RDF, SPARQL-Seite, `check-crm` (kommen aus dem Paket).

**Befunde** (geprüft 2026-11-01, soweit nicht anders gesagt):

1. **osm2lod, Ist-Stand.** Je Export-Typ (`ci`, `drillcores`, `holywells`, `ogham`, `benchmarks`, `romansites`, `sisal`) eine Overpass-Abfrage mit `out meta geom`. Je Element kommt nur die **aktuelle** Version mit `version`, `timestamp`, `changeset`, `user`, `uid`. Jeder Lauf liegt in `dist/<datum>/` (CSV, TTL, QuickStatements, `metadata_*.json`); Läufe werden verglichen (Changelog, DIFF-QuickStatements mit CREATE und UPDATE). Die „Versionsgeschichte“ von osm2lod ist also eine Folge von Schnappschüssen, nicht die OSM-History der Elemente.
2. **osm2lod, RDF.** `osm2lod:node_<id> a osm2lod:Benchmark, osm2lod:OSMEntity, crm:E22_Human_Made_Object, dcat:Dataset`, dazu `foaf:primaryTopic <http://openstreetmap.org/node/<id>>`, GeoSPARQL-Geometrie und jeder Tag als `osmtag__<key>`. CRM ist nur Typisierung. Ways und Relations werden auf den Mittelwert ihrer Stützpunkte reduziert (`extract_point`), die Fläche geht verloren.
3. **Benchmark-Abfrage** (aus `metadata_benchmarks_2026-03-22_*.json`, unverändert zu übernehmen):

   ```
   [out:json][timeout:180];
   (
     area(3600062273)->.roi;
     area(3600156393)->.ni;
     area(3600058446)->.scotland;
   );
   (
     nwr(area.roi)["man_made"="survey_point"]["benchmark"="yes"]["wikimedia_commons"];
     nwr(area.ni)["man_made"="survey_point"]["benchmark"="yes"]["wikimedia_commons"];
     nwr(area.scotland)["man_made"="survey_point"]["benchmark"="yes"]["wikimedia_commons"];
   );
   out meta geom;
   ```

4. **Bestand.** Lauf 2026-03-22: 21 Elemente, alle Nodes; Versionsstände 2 bis 5. Der Lauf 2026-03-15 hatte 21 neue (CREATE).
5. **History-Probe** (bei Flo gelaufen, `GET /api/0.6/node/<id>/history.json`): 21 Elemente, **59 Versionen** (2 bis 6 je Element), keine Löschung, keine Redaction. 5 Benutzer, einer davon mit 51 von 59 Versionen. Zwei Elemente wurden nach dem Lauf vom 22.03. nochmals bearbeitet (23.03. und 10.04.).
6. **Eintritt in die Menge.** Bei allen 21 Elementen wurde `wikimedia_commons` erst in einer späteren Version ergänzt, v1 hatte es nie. Erste Version, in der die Tag-Bedingung der Abfrage (`man_made=survey_point`, `benchmark=yes`, `wikimedia_commons` vorhanden) gilt: v2 bei 13 Elementen, v3 bei 6, v4 bei 1, v5 bei 1. Kein Element hat die Menge wieder verlassen. Die Abfrage ist eine **Mitgliedschaftsregel**; „erste Version“ in OSM und „erste Version in der Menge“ sind verschiedene Dinge.
7. **Geometrie.** 12 Positionswechsel an 10 Elementen, Median etwa 1 m, Maximum 10,6 m, drei über 5 m (alle von v1 auf v2). Zählt man einen Eintrag je Geometrie-Änderung, ergeben sich 33 Einträge (21 erste Positionen und 12 Wechsel).
8. **Tags.** Von 38 Versionswechseln ändern 16 nur `wikimedia_commons`, 8 nur die Position (kein Tag), 14 weitere Tags (u. a. `inscription`, `survey:date`, `description`, `source`).
9. **Labels.** Kein `name` bei den 21 Elementen (aktuelle Version), `name:en` bei einem. Der Commons-Dateititel ist bei allen da (die Abfrage verlangt ihn), z. B. `File:Benchmark at Ardreigh Lock.jpg`.
10. **API-Antwort.** Der Kopf trägt Lizenz (ODbL 1.0) und Copyright; Elemente haben `type`, `id`, `version`, `timestamp`, `changeset`, `user`, `uid`, `lat`, `lon`, `tags`. `visible` fehlt bei sichtbaren Versionen; gelöschte Versionen wurden nicht beobachtet (keine vorhanden).
11. **Netz.** Die Sandbox der Chats erreicht `api.openstreetmap.org` nicht (HTTP 403 vom Proxy, 2026-11-01); Overpass wurde nicht geprüft. Der Harvest läuft bei Flo; `--from-dir` und `--offline` sind Pflicht, und die Tests laufen gegen die 21 gesicherten JSON-Dateien (100 KB) als Fixtures.
12. **Paket, CRM.** `crm.py` kennt `crm:E25_Human-Made_Feature` nicht und erlaubt je Klasse nur eine direkte Oberklasse (E25 hat zwei: E24 und E26). Erlaubte Familien: `crm`, `crmarchaeo`, `crmdig`, `crmgeo`, `crmsci`. Eine Ergänzung im Paket ist nötig (S3).
13. **Paket, Modell.** Der Kern ist Q1 bis Q3 und P1 bis P10; Klassen ab Q100 und Properties ab P100 kommen aus der CSV des Site-Repos (Muster `chublets-wikibase-demo`). Verben mit Netz holen und wandeln in einem Zug (`import-wikidata`), mit `--offline`, `--from-dir` und `--dry-run`.
14. **Paket ohne Daten (S1, geprüft 2026-11-01 mit `wikibase-static` 0.19.0).** `python main.py --strict` in einem Repo ohne `data/csv/` und ohne `data/raw/entities/` meldet bei jedem Schritt „nothing to do“, endet mit Exit-Code 0 und erzeugt keine Datei; `docs/` und `dist/` entstehen erst mit den ersten Daten (S4).

### A2 Zielbild

```
 data/seeds/overpass-benchmarks.overpassql     (die Abfrage aus Befund 3)
         │
         │ import-osm   (Verb mit Netz, nie im Standardlauf)
         ▼
 Overpass  ──►  data/raw/osm/overpass/<seed>.json        Elemente und aktuelle Versionen
 OSM API   ──►  data/raw/osm/history/<type>_<id>.json   volle Historie (nur bei Versionsabweichung)
         │                                                (unverändert, nur lesen)
         │ import-osm --offline  +  data/csv/mapping/osm-properties.csv  (Rolle → Property-ID)
         ▼
 data/csv/  entities.csv  statements.csv  qualifiers.csv  references.csv  idmap.csv
 data/crm.csv  (Benchmark → crm:E25)
         │ from-csv → load → build → search → rdf → sparql
         ▼
 docs/  (GitHub Pages: Seiten, Karte, Suche, SPARQL)      dist/*.ttl  (DCAT 3, GeoSPARQL, CIDOC CRM)
```

Eine QID je OSM-Element, wie OSM nur eine ID je Element kennt. Die Versionen hängen als Statements an dieser QID. Beispiel `node/6666122939` (Milestone Dublin 8 Howth 1), Werte aus der History-Probe:

| Statement (Arbeitsname) | Wert | Qualifier |
|---|---|---|
| OSM-Element | `https://www.openstreetmap.org/node/6666122939` | Typ `node`, ID |
| OSM-Version | `…/node/6666122939/history/1` | Version 1, 2019-07-31T15:26:39Z, Changeset 72862285, Benutzer VictorIE, uid 2008037 |
| OSM-Version | `…/history/2` | 2, 2019-08-18T21:03:36Z, 73473669, VictorIE, 2008037 |
| OSM-Version (Rang preferred) | `…/history/3` | 3, 2024-02-26T13:33:57Z, 147932304, b-unicycling, 1713634 |
| Kriterium erfüllt seit | `…/history/3` | Export-Typ `benchmarks`; „bis“ nur nach einem Austritt |
| Koordinate (aktuell) | 53.390985, -6.0906714 | für Karte und Suche |
| Geometrie-Verlauf (WKT) | `POINT(-6.0906724 53.3909747)` | Version 1, gültig am 2019-07-31T15:26:39Z |
| Geometrie-Verlauf (WKT) | `POINT(-6.0906714 53.390985)` | Version 3, gültig am 2024-02-26T13:33:57Z |
| Bild | `MilestoneDublin8Howth1.jpg` (Commons) | |
| OSM-Tag (aktuell) | `inscription=P.O Dublin 8 Howth 1` usw. | |

Die Ergebnisse müssen diese Eigenschaften haben, jede ist prüfbar:

1. Jedes Element hat genau eine QID; es gibt keine Versions-Items.
2. Zahl der OSM-Version-Statements je Element = Zahl der Versionen in der API-History (am Erstbestand 59 von 59).
3. Jede QID ist über `data/crm.csv` auf `crm:E25` verankert; `check-crm` meldet keinen Verstoß.
4. Das RDF enthält kein `owl:sameAs` auf OpenStreetMap; die Statement- und Wert-IRIs sind reine Bezeichner im eigenen Namensraum.
5. Zweimal laufen lassen ändert nichts (`git status` leer); ein zweiter Harvest ohne Änderung bei OSM stellt nur Versionsabfragen und keine History-Abfrage.

### A3 Querschnittsregeln

- Rohdaten liegen unter `data/raw/`, unverändert wie erhalten, nicht von Hand ändern. Was ein Skript daraus macht, geht nach `data/csv/`, `data/derived/`, `dist/` oder `docs/`.
- Wiederverwendung heißt kopieren, nicht referenzieren. Ausnahme: ein gemeinsames Vokabular, das per w3id-IRI importiert wird.
- Kopierter Code bringt seine Prüfungen mit.
- **Keine Uhr im Output.** Kein Generator ruft `datetime.now()` auf. Zeitangaben stammen aus den Quelldaten (Zeitstempel der OSM-Versionen) oder aus `RELEASE_DATE`.
- **Zeilenenden LF** (`.gitattributes`: `* text=auto eol=lf`).
- **Zweimal laufen lassen, `git status` bleibt sauber.**
- **Netzwerk nur im Verb `import-osm`** (Vorschlag 2026-11-01). Alles andere läuft offline gegen `data/raw/`. Das Verb gehört nie zum Standardlauf.
- **Höflicher Harvest.** Ehrlicher User-Agent mit Kontaktadresse, mindestens eine Sekunde Pause zwischen Requests an die OSM API, `Retry-After` beachten, Overpass nur mit einer Abfrage zur Zeit. Die OSM-Nutzungsregeln gelten (keine Massenabfragen).
- **Die Seiten zeigen, was die Quelle sagt.** Werte werden formatiert, nicht repariert.
- **Lizenz und Namensnennung.** Die Daten sind OpenStreetMap-Daten (ODbL 1.0, „© OpenStreetMap contributors“); der Hinweis steht auf jeder Seite und im RDF (A4).
- Befehle für Windows `cmd`, jeder in **einer** Zeile, zusammengehörige Befehle mit `&&` verkettet.
- Mermaid-Diagramme nutzen das feste Farbschema der Familie (Subject/Object grau, RealObject dunkelgrün, Class dunkelorange, Term dunkelviolett, OWL weiß, PropMeta amber).

### A4 Beschlusslage

| Frage | Beschluss | seit |
|---|---|---|
| Zweck | Statische Wikibase (GitHub Pages) für OSM-Elemente, zuerst am Beispiel der Benchmarks; Weiterentwicklung der Idee von osm2lod: Overpass liefert neue Elemente, die Versionsgeschichte des OSM-Elements wird mitgeführt, alles ist auf ein CIDOC-CRM-Element verankert | 2026-11-01 |
| Repo-Zuschnitt | Das Paket `wikibase-static` bekommt eine neue Quelle (Verb `import-osm`, dort S15a); dazu ein Demo-Repo für die Benchmarks | 2026-11-01 |
| Repo-Name und Ort | `n4o-rse/osm-benchmarks-static`, lokal `C:\git\osm-benchmarks-static` | Vorschlag 2026-11-01 |
| Identität | **Eine QID je OSM-Element** (Typ und ID), nicht je Version; die Versionen hängen als Statements an derselben QID | 2026-11-01 |
| Versionen | Je OSM-Version ein Statement `OSM-Version` mit der Versions-URL (`https://www.openstreetmap.org/<type>/<id>/history/<version>`) als Wert; Qualifier: Version, Zeitstempel, Changeset, Benutzername **und** uid; aktuelle Version mit Rang „preferred“ | 2026-11-01 |
| Historie ab | Komplett ab v1, dazu der Eintrittsmarker „Kriterium erfüllt seit“ (Wert: Versions-URL der Eintrittsversion, optional „bis“ bei Austritt) | 2026-11-01 |
| Quelle der Historie | OSM API `/api/0.6/<type>/<id>/history.json`, ein Request je Element; Overpass dient nur dazu, Elemente zu finden und die aktuelle Versionsnummer zu lesen. `/history` wird nur gezogen, wenn die Versionsnummer von der gespeicherten abweicht | 2026-11-01 |
| Eintrittsregel | Die Tag-Bedingung der Abfrage (`man_made=survey_point`, `benchmark=yes`, `wikimedia_commons`) wird je Version an den Tags geprüft; das Gebiet (Irland, Nordirland, Schottland) wird nur zum Zeitpunkt des Harvests über Overpass geprüft | Vorschlag 2026-11-01 |
| CRM-Anker | Klasse „Benchmark“ → `crm:E25` (Human-Made Feature, fest verbaute Marker), über `data/crm.csv`; die Versions-URLs werden E73 Information Object mit `P70 documents` auf das Element | 2026-11-01 (E25); Rest Vorschlag |
| Geometrie, aktuell | Eine Koordinate je Element für Karte und Suche (bei Ways und Relations der Mittelpunkt der Geometrie) | Vorschlag 2026-11-01 |
| Geometrie, Verlauf | Eigene Property „Geometrie-Verlauf“ mit der Geometrie als **WKT** (Point, LineString, Polygon aus node, way, relation), verknüpft mit der Version; Qualifier „Version“ und „gültig am“, weil die Geometrie eines Ways an einem Zeitpunkt hängt und sich ändern kann, ohne dass der Way eine neue Version bekommt. Im RDF `geo:hasGeometry` und `geo:asWKT` (EPSG:4326) | 2026-11-01 |
| Geometrie, Eintragsfolge | Ein Eintrag je Geometrie-Änderung, nicht je Version (Erstbestand: 33 Einträge statt 59) | Vorschlag 2026-11-01 |
| Tags | Nur der aktuelle Stand; ältere Werte sind über die Versions-Links bei OSM erreichbar | 2026-11-01 |
| Benutzername und uid | Beide als Qualifier der Versions-Statements | 2026-11-01 |
| Lizenz | ODbL 1.0 mit „© OpenStreetMap contributors“ in `site.yaml` (`license`), nicht der CC0-Standard des Pakets; der Code des Repos steht unter MIT | Vorschlag 2026-11-01 |
| URIs | Eigener Namensraum im github.io-Raum des Repos (`rdf_base`), eigene Präfixfamilie (`rdf_prefix`); kein `owl:sameAs` und kein `skos:exactMatch` auf OSM, weil die OSM-URI den Datensatz bezeichnet und nicht das Ding | Vorschlag 2026-11-01 |
| Label | `name`, sonst `name:en`, sonst der Commons-Dateititel ohne `File:` und Endung, sonst `OSM node <id>` | Vorschlag 2026-11-01 |
| Seeds | Die Abfrage steht als Datei unter `data/seeds/` und wird unverändert aus osm2lod übernommen | 2026-11-01 |
| Verb | `python main.py import-osm` (Netz), mit `--offline`, `--from-dir DIR`, `--dry-run`, `--contact`; erscheint im Paket als Version 0.20.0 | Vorschlag 2026-11-01 |
| Skeleton | Dünnes `main.py` nach dem Muster von `fuzzy-sl-static` (setzt `WBS_ROOT`); Schritte `from-csv`, `load`, `build`, `search`, `rdf`, `sparql` im Standardlauf, `csv-fmt` und `check-crm` als Verben; `import-osm` kommt mit S3 dazu. Lizenz des Codes MIT, `CITATION.cff` Version 0.1.0, `rdf_prefix: obs` und `license` ODbL in `site.yaml` (vorerst ohne Logo) | 2026-11-01 (S1) |
| Startumfang | Die 21 Nodes des Laufs vom 2026-03-22, danach alle Elemente der Abfrage | 2026-11-01 |

### A5 Was in welchem Chat hochgeladen wird

Ein Bundle statt Einzeldateien. Mitnehmen: `PRIMER.md`, Quelltexte, kleine Daten (`data/raw/osm/history/` hat 100 KB). Nicht mitnehmen: `.git/`, `.venv/`, `config.local.*`, große erzeugte Dateien.

```cmd
robocopy . ..\osm-benchmarks-static-bundle /E /XD .git .venv __pycache__ build /XF config.local.ini config.local.json >nul & powershell -NoProfile -Command "Compress-Archive -Path ..\osm-benchmarks-static-bundle\* -DestinationPath ..\osm-benchmarks-static-bundle.zip -Force"
```

(robocopy meldet Erfolg mit Exit-Code unter 8, das ist normal.) Das Paket `wikibase-static` klont Claude selbst von GitHub; für S3 genügt das, ein Upload ist nicht nötig. Wird ein Chat im Paket-Repo gearbeitet (S3, S6), gilt dessen PRIMER und dessen Bundle.

### A6 IRI-Landkarte

Alles `geplant`, bis S1 die Basis festlegt. Vorschlag: `rdf_base` = `https://n4o-rse.github.io/osm-benchmarks-static`, `rdf_prefix` = `obs`.

| Pfad | Inhalt | Ziel des Redirects | Status |
|---|---|---|---|
| `<base>/entity/<ID>` | Konzept-URI eines Elements (Weiterleitungsseite) | – | geplant |
| `docs/ttl/<ID>.ttl`, `docs/json/<ID>.json` | ein Element als Turtle bzw. JSON | – | geplant |
| `docs/downloads/<host>.ttl` | RDF aller Entitäten, beschrieben mit DCAT 3 | – | geplant |
| `docs/sparql.html`, `docs/query.html` | Query-Seite und Editor | – | geplant |
| w3id-Präfix | offen, wie im Paket vorerst keines | offen | geplant |

---

## Teil B — Schrittübersicht

| ID | Schritt | Repo | hängt ab von | Status |
|---|---|---|---|---|
| S0 | Festlegungen und History-Probe an den 21 Nodes | osm-benchmarks-static | – | erledigt 2026-11-01 |
| S1 | Skeleton: Layout, `main.py`, `site.yaml`, `requirements.txt`, Lizenz, Citation, Workflow-Aufrufer, `update.cmd` | osm-benchmarks-static | S0 | erledigt 2026-11-01 (Patch-ZIP; Einspielen, Pages-Einstellung und erster Lauf der CI auf GitHub offen) |
| S2 | Modell: Klasse „Benchmark“, Properties (OSM-Element, OSM-Version, Kriterium erfüllt seit, Geometrie-Verlauf, …), `data/crm.csv`, Mapping-Datei der Rollen | osm-benchmarks-static | S1 | offen |
| S3 | Konverter `import-osm --offline`: History-JSON und Overpass-Antwort → CSV; Ergänzung von `crm:E25` im Paket (Paket-S15a) | wikibase-static | S2 | offen |
| S4 | Erstbestand: die 21 Nodes aus den gesicherten JSON-Dateien → Seiten, RDF, SPARQL, `check-crm` | osm-benchmarks-static | S3 | offen |
| S5 | Harvest mit Netz: Overpass, Versionsvergleich, `/history` nur bei Änderung, Eintritt und Austritt | wikibase-static, osm-benchmarks-static | S3 | offen |
| S6 | Geometrie als WKT: Verlauf auf der Seite (Karte) und im RDF (GeoSPARQL), Ways und Relations (Paket-S15b) | wikibase-static | S3 | offen |
| S7 | Standardabfragen und Feinschliff (Versionsverlauf, Eintrittsversion, Commons-Bilder, Namensnennung) | osm-benchmarks-static | S4 | offen |
| S8 | Pages-Workflow, ODbL-Hinweis, CI mit `--strict` zweimal | osm-benchmarks-static | S4 | offen |
| S9 | Weitere Export-Typen aus osm2lod (`holywells`, `ogham`, `ci`, `drillcores`, `romansites`, `sisal`) als eigene Site-Repos oder Seeds | neue Site-Repos | S5, S6 | offen |

S1 und S2 folgen aufeinander; danach sind S3 und die Vorarbeiten für S6 unabhängig. S4 braucht nur S3 und die gesicherten JSON-Dateien, kein Netz. S5 und S6 sind unabhängig voneinander und beide brauchen S3. Ein Chat im Paket-Repo (S3, S6) bekommt dessen PRIMER; der Auftrag an das Paket steht unten bei S3.

---

## Teil C — Die Schritte

### S0 — Festlegungen (kein Code)

**Ziel:** Modell, Quelle der Historie und Verankerung stehen fest, ehe Code entsteht.

**Erledigt 2026-11-01:** Beschlüsse in A4, Befunde 1 bis 13 in A1. Die History-Probe (`osm_history_probe.py`, lokal gelaufen) hat 21 Roh-JSON-Dateien geliefert; sie liegen unter `data/raw/osm/history/` (`node_<id>.json`, Inhalt unverändert, aber vom Probe-Skript mit `json.dumps(indent=2)` neu eingerückt, also nicht byte-genau die API-Antwort). Die Zusammenfassungen der Probe (`_summary.csv`, `_versions.csv`) sind Erzeugnisse und gehören nicht ins Repo.

### S1 — Skeleton

**Ziel:** Ein Site-Repo nach dem Muster von `fuzzy-sl-static`, das mit `python main.py` sauber durchläuft (ohne Daten).

**Uploads:** Standard-Bundle; Claude klont `fuzzy-sl-static` und `chublets-wikibase-demo` selbst.

Inhalt: `main.py` (dünner Wrapper um das Paket, mit dem zusätzlichen Verb `import-osm`, sobald es existiert), `requirements.txt` mit `wikibase-static @ git+https://github.com/n4o-rse/wikibase-static.git`, `site.yaml` (Titel, `pages_url`, `rdf_base`, `rdf_prefix`, Sprachen, `license` ODbL), `LICENSE` (MIT für den Code), `CITATION.cff`, `update.cmd`, `.github/workflows/site.yml` als Aufrufer (`examples/site-caller.yml` im Paket), Logo (falls vorhanden), README mit Namensnennung.

**Abnahme:** `python main.py --list` nennt die Schritte; `python main.py --strict` läuft ohne Daten durch und meldet für jeden Schritt „nichts zu tun“; zwei Läufe hintereinander, `git status --porcelain` leer.

### Erledigt 2026-11-01

Gebaut: `main.py`, `requirements.txt`, `site.yaml`, `LICENSE`, `CITATION.cff`, `update.cmd`, `.github/workflows/site.yml`, neues `README.md` (Befund 14, A4 „Skeleton“). Abnahme in einer frischen Kopie des Repos erfüllt: `--list` nennt acht Schritte (sechs im Standardlauf, zwei Verben), `--strict` zweimal hintereinander mit Exit-Code 0, sechsmal „nothing to do“, danach keine neue Datei außer den Quellen des Skeletons. Der Aufrufer `site.yml` steht auf `deploy: false`: der Job „check“ (zweimal `--strict`, Baum sauber) läuft von Anfang an, das Veröffentlichen kommt in S8, weil der Deploy-Job ohne `docs/` scheitern würde (`upload-pages-artifact` mit Pfad `docs`). Nicht geprüft: der Lauf des Workflows auf GitHub und `update.cmd` unter Windows. Der Befehl `import-osm` fehlt absichtlich in `main.py`.

### S2 — Modell

**Ziel:** Die Klasse und die Properties des OSM-Modells stehen in der CSV des Repos.

Inhalt: `data/csv/entities.csv` mit der Klasse „Benchmark“ (ab Q100) und den Properties ab P100 (Arbeitsnamen aus A2: OSM-Element, OSM-Version, Kriterium erfüllt seit, Geometrie-Verlauf, Koordinate, Bild, OSM-Tag; Qualifier: Version, Zeitstempel, Changeset, OSM-Benutzer, OSM-uid, gültig am), `data/crm.csv` (`class, crm_class, note`; Benchmark → `crm:E25`), `data/csv/mapping/osm-properties.csv` (Rolle → Property-ID, damit der Konverter in S3 allgemein bleibt). Zu klären als Formular im Chat: Datentypen (URL oder External-ID für Versions-URL und Changeset, Zeichenkette für WKT), Tags (eine Property `OSM-Tag` mit „key=value“ oder je Schlüssel eine Property), Property-Namen auf Deutsch und Englisch.

**Abnahme:** `from-csv` und `load` laufen ohne `WARN`; Validator und `check-crm` melden keinen Verstoß, wenn man die Mapping-Datei und `crm.csv` mit einem Probe-Item aus Hand füllt.

### S3 — Konverter `import-osm --offline`

**Ziel:** Das Paket macht aus den gesicherten JSON-Dateien die vier CSV-Tabellen des Modells (im Paket-PRIMER ist das S15a).

**Uploads:** Bundle von `wikibase-static`, `data/raw/osm/history/` und `data/csv/mapping/osm-properties.csv`; Claude klont das Paket sonst selbst.

Inhalt: `step_import_osm.py` (Eingabe `data/raw/osm/history/<type>_<id>.json` und optional `data/raw/osm/overpass/<seed>.json`; Ausgabe in `data/csv/`; kanonische Schreibweise wie bei den anderen Importern; Bericht mit Zahlen), Eintrittsregel je Version (A4), Etikett nach A4 „Label“, Wert-Codec für Zeit und Koordinate des Pakets, Ergänzung von `crm:E25_Human-Made_Feature` in `crm.py` (mit der zweiten Oberklasse E26 oder einem begründeten Verzicht), Tests mit den 21 JSON-Dateien als Fixtures.

**Auftrag für den PRIMER von `wikibase-static`** (im Chat von S3 dort einzutragen, nicht jetzt, damit kein neuer Stand überschrieben wird): in Teil B die Zeile S15 in S15a (Konverter OSM → CSV, Verb `import-osm`, Version 0.20.0) und S15b (WKT-Geometrie im Renderer und im RDF) aufteilen; in A4 die Zeilen „OSM, Identität“, „OSM, Versionen“, „OSM, Historie“, „OSM, Geometrie“ aus diesem Dokument übernehmen; in A3 die Regel „Netzwerk nur in `harvest` und `import-wikidata`“ um `import-osm` ergänzen; in Teil D den Punkt „E25 hat zwei Oberklassen“ eintragen.

**Abnahme:** `import-osm --offline --from-dir data/raw/osm/history` erzeugt aus den 21 Dateien **21 Items, 59 Versions-Statements, 21 Eintrittsmarker (Versionen v2: 13, v3: 6, v4: 1, v5: 1) und 33 Geometrie-Einträge**; ein zweiter Lauf ändert nichts; jede Fehlerzeile nennt `datei:zeile`; ein absichtlich beschädigtes JSON ergibt genau eine Meldung; die bestehenden Tests des Pakets bleiben grün.

### S4 — Erstbestand

**Ziel:** Die 21 Benchmarks sind als Seiten, Turtle und SPARQL-Seite da.

Inhalt: Lauf der Pipeline gegen `data/raw/osm/history/`, Sichtprobe von Karte, Commons-Bild und Versionsliste, Standardabfragen des Pakets.

**Abnahme:** 21 Entitäten; jede Seite listet alle ihre OSM-Versionen mit Link; `check-crm` ohne Verstöße; `python main.py --strict` zweimal hintereinander, `git status` leer; im RDF kein `owl:sameAs` auf OSM.

### S5 — Harvest mit Netz

**Ziel:** Neue Elemente und neue Versionen kommen nach, ohne alles neu zu ziehen.

Inhalt: Overpass-Abfrage aus `data/seeds/` (ohne `geom`, nur `out meta`), Vergleich der Versionsnummern mit dem gespeicherten Stand, `/history` nur für neue oder geänderte Elemente, Eintrittsmarker, Austritt (Element fehlt in der Antwort oder die Tag-Bedingung gilt nicht mehr), Meldung bei gelöschten Versionen (`visible=false`), höfliche Pausen, `--probe` (eine Anfrage, schreibt nichts); die Rohantwort wird byte-genau abgelegt (die Dateien der Probe sind neu eingerückt und werden dabei einmal ersetzt).

**Abnahme:** Erster Lauf bei Flo holt die 21 Elemente und stimmt mit den gesicherten Dateien überein; ein zweiter Lauf stellt nur die Overpass-Anfrage und keine `/history`-Anfrage; die Meldung nennt die Zahl der neuen Elemente und Versionen.

### S6 — Geometrie als WKT

**Ziel:** Ways und Relations behalten ihre Fläche; der Verlauf ist auf der Seite und im RDF zu sehen (Paket-S15b).

Inhalt: WKT-Erzeugung aus node, way und relation (Overpass-Stand zu einem Zeitpunkt über `[date:"…"]`, ein Request je Zeitpunkt; die API-History eines Ways liefert nur die Node-Referenzen), Anzeige des aktuellen WKT auf der Karte, `geo:hasGeometry` und `geo:asWKT` je Eintrag, Abfrage „Geometrie zu einem Zeitpunkt“.

**Abnahme:** Ein Way und ein Multipolygon aus einem anderen Export-Typ bauen als WKT-Fläche; die Benchmarks ändern sich nicht; das RDF liest rdflib identisch zurück.

### S7 — Standardabfragen und Feinschliff

**Ziel:** Fragen, die ohne den Versionsverlauf nicht zu beantworten waren, sind Standardabfragen.

Inhalt: „Elemente nach Eintrittsversion“, „Elemente, die seit Datum X geändert wurden“, „Benutzer mit den meisten Versionen“, „Elemente mit Positionswechsel über N m“, Commons-Bilder, Hinweis „© OpenStreetMap contributors“ auf jeder Seite.

**Abnahme:** Jede Abfrage liefert auf dem Erstbestand die Zeilenzahlen, die dieser PRIMER aus den JSON-Dateien nennt (Beispiel: Benutzer-Abfrage ergibt 5 Zeilen, 51 Versionen beim Spitzenreiter).

### S8 — Pages-Workflow und CI

**Ziel:** Die Seite ist veröffentlicht, jede Änderung wird geprüft.

Inhalt: `site.yml` als Aufrufer des Paket-Workflows (der Block `with: deploy: false` aus S1 fällt weg), Pages auf „GitHub Actions“, `--strict` zweimal mit leerem `git status`, Prüfung des Namensnennungs-Hinweises.

**Abnahme:** Lauf auf GitHub grün, Live-Seite erreichbar, `Q`-Seite und Turtle-Datei einer Entität abrufbar.

### S9 — Weitere Export-Typen

**Ziel:** Die übrigen Typen aus osm2lod (`holywells`, `ogham`, `ci`, `drillcores`, `romansites`, `sisal`) laufen über dieselbe Quelle.

Inhalt: Entscheidung, ob je Typ ein Repo oder ein Seed in diesem Repo; CRM-Klasse je Typ (Overlay), z. B. Holy Wells: E22 oder E26/E27 nach Prüfung.

**Abnahme:** Rundlauf Seed → Site → RDF behält die CRM-Klassen; `check-crm` ohne Verstöße.

---

## Teil D — Offene Punkte

- **Repo-Name und Organisation:** `osm-benchmarks-static` unter `n4o-rse` ist ein Vorschlag (Muster `fuzzy-sl-static`, `chublets-wikibase-demo`). Alternativen: `benchmarks-static`, `osm-static`; als Ort käme auch `Research-Squirrel-Engineers` in Frage, wo `osm2lod` liegt.
- **Tags:** eine Property `OSM-Tag` („key=value“) oder je Schlüssel eine Property (wie die `osmtag__*` in osm2lod)? Entscheidung in S2. Für die Abfragen ist die allgemeine Form bequemer, für die Seite die benannte Property.
- **Eintrittsregel und Gebiet:** Das Gebiet wird nur beim Harvest geprüft; ein Element, das früher in der Menge war und später die Grenze überschreitet (unwahrscheinlich bei Benchmarks), würde nicht als Austritt erkannt. Für S5 abwägen, ob das genügt.
- **Gelöschte Elemente:** In den 21 Dateien kommt keine gelöschte Version vor; Verhalten (Item behalten, Statement „in OSM gelöscht am …“) ist beschlossen als Idee, nicht erprobt (S5).
- **Way-Geometrie zu einem Zeitpunkt:** Overpass mit `[date:…]` ist hier ein Wissensstand, nicht geprüft; in S6 an einem echten Way zu messen, ebenso die Zahl der Requests.
- **uid und Benutzername im RDF:** Beide Werte sind in OSM öffentlich, stehen aber dauerhaft in den Daten; falls es Widerspruch gibt, wäre ein Schalter in `site.yaml` zu erwägen (beschlossen ist: beides).
- **Label-Vorschlag:** Der Commons-Titel als Rückfall ist nicht bestätigt (A4 „Label“).
- **Netz bei Flo:** `import-osm` ist bei Flo noch nicht gelaufen (S5); beim ersten Lauf `--contact` setzen und die Pause prüfen.
- **Pages einschalten (S1):** Einmal in den Einstellungen des Repos: Settings → Pages → Source „GitHub Actions“. Der Aufrufer `site.yml` steht seit S1 auf `deploy: false` und prüft nur; die Einstellung wird mit S8 gebraucht, wenn das Veröffentlichen eingeschaltet wird.
- **Logo (S1):** `site.yaml` hat kein `logo`; falls eines gewünscht ist, die Datei nach `assets/` und die Zeile `logo: assets/<datei>` ergänzen.
- **`rdf_prefix` und `data_as_of` (S1):** `obs` ist ein Vorschlag; `data_as_of` fehlt in `site.yaml` und wird mit den ersten Daten (S4) gesetzt, weil die CSV keine eigene Änderungszeit trägt (so macht es `chublets-wikibase-demo`).
- **Probe-Skript:** `osm_history_probe.py` (lokal in `C:\tmp\pytemp`) wird mit S5 durch `import-osm` ersetzt; bis dahin nicht ins Repo, weil es nach `data/raw/osm_history` schreibt und nicht nach `data/raw/osm/history`.

# PRIMER — osm-benchmarks-static

Arbeitsplan für `n4o-rse/osm-benchmarks-static` (Repo-Name: Vorschlag 2026-11-01). Wird zu Beginn jedes Chats hochgeladen (Bundle, siehe A5) und am Ende zurückgeschrieben. Stand: 2026-11-01 (S0: Festlegungen; History-Probe an den 21 Benchmark-Nodes, Befunde 1 bis 13; S1: Skeleton, Befund 14; S2: Modell, Befund 15; S3: `import-osm` im Paket 0.20.0, Befund 16; S4: Erstbestand, Befund 17; S5: Harvest mit Netz im Paket 0.21.0, Befund 18; echter Lauf, Befund 19; S6: Ways und Relations als WKT im Paket 0.22.0, Befund 20; S7: Standardabfragen, Befund 21; S8: Veröffentlichung, Befund 22; Live, Befund 23).

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
12. **Paket, CRM.** `crm:E25_Human-Made_Feature` ist als Anker zulässig (S2 geprüft: `data/crm.csv` mit `Q100,crm:E25` lädt, `check-crm` meldet 0 Verstöße). Es fehlt nur die Oberklassenkette im Paket: E25 hat zwei direkte Oberklassen (E24 Physical Human-Made Thing und E26 Physical Feature), `crm.py` kennt je Klasse nur eine. Erlaubte Familien: `crm`, `crmarchaeo`, `crmdig`, `crmgeo`, `crmsci`. Erledigt in S3: `crm.CLASSES` kennt E25 mit der Oberklasse E24; E26 fehlt (Befund 16, Paket-PRIMER Befund 87).
13. **Paket, Modell.** Der Kern ist Q1 bis Q3 und P1 bis P10; Klassen ab Q100 und Properties ab P100 kommen aus der CSV des Site-Repos (Muster `chublets-wikibase-demo`). Verben mit Netz holen und wandeln in einem Zug (`import-wikidata`), mit `--offline`, `--from-dir` und `--dry-run`.
14. **Paket ohne Daten (S1, geprüft 2026-11-01 mit `wikibase-static` 0.19.0).** `python main.py --strict` in einem Repo ohne `data/csv/` und ohne `data/raw/entities/` meldet bei jedem Schritt „nothing to do“, endet mit Exit-Code 0 und erzeugt keine Datei; `docs/` und `dist/` entstehen erst mit den ersten Daten (S4).
15. **Paket, Zeitwerte (S2, geprüft 2026-11-01 mit `wikibase-static` 0.19.0).** Der Wert-Codec für `time` kennt nur Datum (Genauigkeit 9 bis 11: Jahr, Monat, Tag); eine Uhrzeit wie `+2019-07-31T15:26:39Z/14` wird von `from-csv` mit `WARN` abgewiesen. Der OSM-Zeitstempel (sekundengenau) steht deshalb vorerst als Zeichenkette (ISO 8601, UTC). Ein Zeitwert mit Uhrzeit im Paket wäre Sache von S15b; die Property bekommt dann den Datentyp `time`.
16. **Paket, `import-osm` (S3, geprüft 2026-11-01 mit `wikibase-static` 0.20.0).** Mit den 21 Dateien aus `data/raw/osm/history/`, dem Modell aus S2 (ohne das Beispiel-Item) und `data/seeds/benchmarks.csv` erzeugt `import-osm --offline` **21 Items, 59 Versions-Statements, 21 Eintrittsmarker (v2: 13, v3: 6, v4: 1, v5: 1), 33 Geometrie-Einträge, 21 Bilder und 102 Tag-Statements (der Tag `wikimedia_commons` ist das Bild und kein Tag-Statement)**; `--strict` zweimal ohne `WARN`, `check-crm` 0 Verstöße, ein zweiter Import schreibt nichts. Kein Austritt in den 21 Dateien (0 Qualifier „bis“). Alle 21 Etiketten kommen aus `name` oder dem Commons-Titel, keines aus dem Rückfall `OSM node <id>`. Nur Nodes werden importiert; Ways und Relations meldet der Importer und lässt sie aus (S6).
17. **Erstbestand (S4, geprüft 2026-11-01).** Nach dem Entfernen von Q1000 und `import-osm --offline` bauen die 21 Items (Q101 bis Q121, 49 Entitäten, 359 Statements, 5 776 Tripel) mit `--strict` zweimal ohne `WARN` und ohne toten Link (2 445 Links der Seiten, 55 der SPARQL-Seite); die Karte zeigt 21 Koordinaten auf 21 Seiten, `check-crm` meldet 0 Verstöße, im RDF gibt es kein `owl:sameAs`, der zweite Import schreibt keine Datei. Jede Seite verlinkt alle ihre OSM-Versionen (21 von 21 Seiten, gegen die Zahl der Versionen in der Rohdatei geprüft). **Etiketten:** 20 von 21 stammen aus dem Titel der Commons-Datei, eines aus `name:en`, keines aus `name` und keines aus dem Rückfall; die Etiketten hängen damit an den Dateinamen auf Commons (z. B. `MilestoneDublin8Howth1`). **Anzeige:** Die Karte bekommt im Browser ohne Netz keine Kacheln (grauer Grund, Marker sichtbar); das Commons-Bild lädt nur mit Netz. Die Koordinate wird auf der Seite gerundet angezeigt (`53.390985° N, 6.090671° W`), der Wert in der CSV hat sieben Stellen.
18. **Harvest mit Netz (S5, gebaut 2026-11-01, gegen Attrappe geprüft, nicht gegen die echten Server).** `python main.py import-osm` (Paket 0.21.0) sendet `data/seeds/overpass-benchmarks.overpassql` (die Abfrage aus Befund 3 mit `out meta;` statt `out meta geom;`) einmal, legt die Antwort byte-genau unter `data/raw/osm/overpass/benchmarks.json` ab (nur wenn sich die Liste der Elemente und Versionen ändert) und holt `/history.json` nur für neue Elemente und für Elemente mit höherer Version. In einer Kopie von `0a133ef` mit einem Attrappen-Server, der die 21 gesicherten Dateien ausliefert: Erstlauf = 1 Overpass- und 21 History-Anfragen, die abgelegten Dateien stimmen byte-genau mit den Eingabedateien überein, `data/csv/` ändert sich nicht; Zweitlauf = 1 Overpass-Anfrage und 0 History-Anfragen, nichts ändert sich. Austritt: ein gespeichertes Element, das in der Overpass-Antwort fehlt, bekommt am letzten Eintragslauf den Qualifier „in der Auswahl bis“ (P108); verliert eine neue Version die Tag-Bedingung, entsteht er aus den Versionen. Die Probe-Dateien sind eingerückt und LF; `--refresh` ersetzt sie einmal durch die Bytes der API und meldet, ob die gespeicherten Versionen mit denen der API übereinstimmen.
19. **Echter Harvest (S5, 2026-11-01, bei Flo gegen Overpass und API).** `--probe` sendete eine Overpass-Anfrage und schrieb nichts; Overpass (0.7.62.11, Stand der Daten 2026-11-01T18:33:21Z) antwortete mit **23 Nodes** in 10 965 Bytes, die byte-genau unter `data/raw/osm/overpass/benchmarks.json` liegen. Gegenüber den 21 gesicherten Dateien sind **2 Nodes neu** (`node/14257817434`, 1 Version, Q122; `node/7709937682`, 5 Versionen, davon v4 mit verschobener Koordinate, Q123): das Gebiet hat seit der Probe zwei Benchmarks dazubekommen, kein Fehler. `--refresh` verglich die gespeicherten Versionen mit den Antworten der API: **21 von 21 stimmen überein, 0 weichen ab**; die Dateien sind seither Bytes der API (nicht mehr eingerückt). Der Bestand hat jetzt **23 Items, 65 Versions-Statements, 36 Geometrie-Einträge, 23 Eintrittsmarker und 0 Austritte**. Der Zweitlauf stellt nur die Overpass-Anfrage (0 History-Anfragen) und schreibt keine Datei in `data/csv/`; Overpass antwortete dabei zweimal mit 502, der Client wartete und kam beim dritten Versuch durch (`host busy`-Meldung wie vorgesehen). `--strict` und `git status` danach sauber. **CI:** Commit `a3237ea` ist rot, weil er die Docs zu Q122 und Q123 schon vor den Daten enthielt (Stufe 6 lief vor dem Einchecken); `b9eba9e` ist grün. **Kosmetik, offen für die nächste Paketversion:** die Zeile `[import-osm] Overpass: … (1 request)` zählt Wiederholungen nicht mit (im Zweitlauf waren es 3 Anfragen).
20. **Ways und Relations als WKT (S6, gebaut 2026-11-01, nur mit synthetischen Daten geprüft).** Paket 0.22.0 (`wkt.py`, `osm_geom.py`). Ein Way hat nur Node-Referenzen; die Form zu einem Zeitpunkt entsteht aus der Version des Ways und den Versionen seiner Nodes zu diesem Zeitpunkt. Statt Overpass `[date:…]` (Befund 3, nicht nötig) holt `import-osm` die History jedes Mitglieds (`/api/0.6/node/<id>/history.json`, byte-genau unter `data/raw/osm/members/`; Relationen in zwei Runden: Ways, dann deren Nodes). Ein Eintrag „Geometrie-Verlauf“ je Änderung der Form (Statement-IDs `g1`, `g2` …; Qualifier Version des Elements und Zeitpunkt der Änderung); geschlossener Way = `POLYGON`, außer Linienmerkmale (`highway`, `barrier`, `waterway`, `railway`, `power`, `route`, `pipeline`) ohne `area=yes`; `multipolygon` und `boundary` = `POLYGON` oder `MULTIPOLYGON` mit Löchern; andere Relationen = `MULTILINESTRING`, `MULTIPOINT` oder `GEOMETRYCOLLECTION`. Die Koordinate eines Ways ist die Mitte des Begrenzungsrahmens der letzten Form. **Benchmarks unverändert:** `import-osm --offline` schreibt 0 Dateien, `--strict` zweimal sauber, im RDF 154 Tripel mehr (`geo:Feature` je Item, `geo:hasGeometry`, `geo:hasDefaultGeometry`, `geo:Geometry` und `geo:asWKT` je Eintrag; 23 Items, 36 Einträge), die Seiten ändern sich nur in der Version der Fußzeile. `site.yaml` bekommt `wkt_property: P111`. **Grenze:** Eine verschobene Node erhöht die Version ihres Ways nicht; Overpass sieht das nicht, nur `--refresh` holt die Mitglieder neu. Verschachtelte Relationen werden nicht verfolgt.
21. **Standardabfragen (S7, 2026-11-01).** `queries.yaml` im Repo ersetzt die Standardabfragen des Pakets (kein Erweitern; die 13 allgemeinen stehen unverändert dahinter, 19 insgesamt) und beginnt mit sechs Abfragen über den Versionsverlauf: `osm-versions` (23 Zeilen), `osm-entry-version` (23), `osm-changed-since` (19 seit 2025-01-01), `osm-top-users` (5 Zeilen, Spitzenreiter `b-unicycling` mit 57 von 65 Versionen an 23 Elementen), `osm-moved` (6 Positionswechsel über 1 m: 11, 6, 5, 2, 1, 1 m) und `osm-geometry-at` (5 Elemente mit Position am 2023-01-01, Kartenansicht). **Gegen die Rohdateien nachgezählt** (Python über `data/raw/osm/history/*.json`, unabhängig von SPARQL): Versionen je Element, geänderte, Benutzer, Eintrittsversionen (v1: 1, v2: 13, v3: 6, v4: 1, v5: 2) und Positionswechsel stimmen überein. Die Zeit ist Text (P103), Vergleiche laufen als Zeichenkette; die Entfernung ist grob (111 320 m je Grad, 0,6 für die Länge eines Längengrads bei etwa 53 N, der größere Anteil statt Wurzel, weil SPARQL 1.1 weder `SQRT` noch `COS` kennt). Commons-Bilder (`images`, 23) und der Hinweis „© OpenStreetMap contributors“ (Fußzeile jeder Seite und der Abfrage-Seite) waren schon da.
22. **Veröffentlichung (S8, 2026-11-01).** `site.yml` ruft den Workflow des Pakets ohne `deploy: false` auf: Prüfung (`python main.py --strict && python check_attribution.py` zweimal, danach leerer `git status`), dann Veröffentlichung von `docs/` auf GitHub Pages (nur auf `main`). `check_attribution.py` prüft, dass „OpenStreetMap contributors“ in jeder Seite von `docs/` (die Weiterleitungen unter `docs/entity/` ausgenommen), in jeder Turtle-Datei unter `docs/ttl/`, im Export unter `dist/` und in `site.yaml` steht (110 Dateien; ein Test mit entferntem Text ergab Exit-Code 1 und die Dateiliste); es steht in der Prüfung, damit eine fehlende Namensnennung die Veröffentlichung verhindert. Die Datei `docs/downloads/wikibase-ontology.ttl` gehört dem Paket und trägt den Text nicht (sie enthält keine OSM-Daten). Live-Adresse: `https://n4o-rse.github.io/osm-benchmarks-static/`.
23. **Live (S8, 2026-11-01).** `https://n4o-rse.github.io/osm-benchmarks-static/` ist erreichbar. Die Seite `Q101.html` zeigt Karte, fünf Versionen (die letzte mit Rang „preferred“), „in selection since“, Koordinate, drei Einträge im Geometrie-Verlauf, das Commons-Bild, die Tags und den Statement-Graphen; `ttl/Q101.ttl` trägt die Namensnennung im Kopf und `geo:Feature`, `geo:hasGeometry`, `geo:hasDefaultGeometry`. Auf der Abfrage-Seite lief „Versions per element“ in Pyodide (31,8 s beim ersten Lauf, 23 Zeilen, 6 278 Tripel). **Stolperstein:** Stand die Pages-Quelle auf „Deploy from a branch“ (`main`, `/docs`), veröffentlichte GitHub über den eigenen Lauf „pages build and deployment“, und der Deploy-Job von `site.yml` scheiterte in `configure-pages` mit „Get Pages site failed … Not Found“, obwohl der Job „check“ grün war. Abhilfe: Settings → Pages → Source „GitHub Actions“, dann „Re-run all jobs“. Sichtbar auf der Seite: das deutsche Etikett fehlt („No label defined“, die Etiketten sind nur englisch); die Zeit im Qualifier steht mit Leerzeichen statt Bindestrichen (nur im Bildschirmfoto, im Turtle ist sie ISO 8601). Warnung im CI: Node 20 der Aktionen `configure-pages`, `deploy-pages`, `upload-pages-artifact` ist veraltet (GitHub zwingt Node 24); die Aktionen gehören dem Workflow des Pakets.

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
| Tags | Nur der aktuelle Stand; ältere Werte sind über die Versions-Links bei OSM erreichbar. Form: **eine** Property `OSM-Tag` (P113), je Tag ein Statement `key=value` | 2026-11-01 (S2) |
| Datentypen | Element und Version: `url` (Version = Versions-URL); Changeset: `external-id` mit Link `https://www.openstreetmap.org/changeset/$1` (P5); Benutzername: `string`; uid: `external-id` ohne Link; Zeitstempel: `string`, ISO 8601 in UTC (Befund 15); Koordinate `globe-coordinate`; Geometrie-Verlauf `string` (WKT); Bild `commonsMedia` | 2026-11-01 (S2) |
| Modell, IDs | Klasse „Benchmark“ = Q100; Properties P100 OSM-Element, P101 OSM-Version, P102 Versionsnummer, P103 Zeitstempel, P104 Changeset, P105 Benutzername, P106 uid, P107 in der Auswahl seit, P108 in der Auswahl bis, P109 Auswahl, P110 Koordinate, P111 Geometrie-Verlauf, P112 Bild, P113 OSM-Tag; der Konverter liest die Zuordnung Rolle → ID aus `data/csv/mapping/osm-properties.csv`. „Kriterium erfüllt seit“ heißt im Modell „in der Auswahl seit“ (en: in selection since), Qualifier „bis“ (P108) und „Auswahl“ (P109, Export-Typ) | 2026-11-01 (S2) |
| Beispiel-Item | `Q1000` (`node/6666122939`, von Hand) diente in S2 und S3 dazu, das Modell zu zeigen; in S4 entfernt, `node/6666122939` ist jetzt Q118 aus dem Import | 2026-11-01 (S4) |
| Benutzername und uid | Beide als Qualifier der Versions-Statements | 2026-11-01 |
| Lizenz | ODbL 1.0 mit „© OpenStreetMap contributors“ in `site.yaml` (`license`), nicht der CC0-Standard des Pakets; der Code des Repos steht unter MIT | Vorschlag 2026-11-01 |
| URIs | Eigener Namensraum im github.io-Raum des Repos (`rdf_base`), eigene Präfixfamilie (`rdf_prefix`); kein `owl:sameAs` und kein `skos:exactMatch` auf OSM, weil die OSM-URI den Datensatz bezeichnet und nicht das Ding | Vorschlag 2026-11-01 |
| Label | `name`, sonst `name:en`, sonst der Commons-Dateititel ohne `File:` und Endung, sonst `OSM node <id>` | Vorschlag 2026-11-01 |
| Seeds | Die Abfrage steht als Datei unter `data/seeds/` und wird unverändert aus osm2lod übernommen | 2026-11-01 |
| Verb | `python main.py import-osm`: ohne Flags Overpass fragen, Neues und Geändertes holen, importieren; `--probe` (eine Overpass-Anfrage, schreibt nichts), `--refresh` (alle Historien neu holen und vergleichen), `--limit N` (History-Anfragen je Lauf, 100), `--delay` (1 s), `--contact`, `--offline` (nur Dateien), `--from-dir`, `--dry-run`, `--selection`, `--seeds`, `--mapping`; Paket-Version 0.21.0 | 2026-11-01 (S3, S5) |
| Austritt | Ein Element, das gespeichert ist, aber in der Overpass-Antwort fehlt (Gebiet verlassen oder gelöscht), bekommt am letzten Eintragslauf den Qualifier „in der Auswahl bis“ mit seiner letzten Version; kommt es zurück, verschwindet die Marke (sie wird bei jedem Import aus der gespeicherten Antwort abgeleitet) | Vorschlag 2026-11-01 (S5) |
| Auswahl | Die Tag-Bedingung steht als `data/seeds/<name>.csv` (`selection, key, value`; leerer Wert = Schlüssel muss nur da sein); `benchmarks`: `man_made=survey_point`, `benchmark=yes`, `wikimedia_commons` | 2026-11-01 (S3) |
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
| S1 | Skeleton: Layout, `main.py`, `site.yaml`, `requirements.txt`, Lizenz, Citation, Workflow-Aufrufer, `update.cmd` | osm-benchmarks-static | S0 | erledigt 2026-11-01 (eingespielt als 028fb2a, CI grün, Python 3.10 geprüft; Pages-Einstellung erst mit S8 nötig) |
| S2 | Modell: Klasse „Benchmark“, Properties (OSM-Element, OSM-Version, Kriterium erfüllt seit, Geometrie-Verlauf, …), `data/crm.csv`, Mapping-Datei der Rollen | osm-benchmarks-static | S1 | erledigt 2026-11-01 (Patch-ZIP; Einspielen offen) |
| S3 | Konverter `import-osm --offline`: History-JSON und Overpass-Antwort → CSV; Ergänzung von `crm:E25` im Paket (Paket-S15a) | wikibase-static | S2 | erledigt 2026-11-01 (Paket 0.20.0, Befund 16; Patch-ZIPs; Einspielen offen) |
| S4 | Erstbestand: die 21 Nodes aus den gesicherten JSON-Dateien → Seiten, RDF, SPARQL, `check-crm` | osm-benchmarks-static | S3 | erledigt 2026-11-01 (Befund 17; Einspielen offen) |
| S5 | Harvest mit Netz: Overpass, Versionsvergleich, `/history` nur bei Änderung, Eintritt und Austritt | wikibase-static, osm-benchmarks-static | S3 | **erledigt 2026-11-01** (Paket 0.21.0, Befunde 18 und 19; echter Lauf bei Flo geprüft) |
| S6 | Geometrie als WKT: Verlauf auf der Seite (Karte) und im RDF (GeoSPARQL), Ways und Relations (Paket-S15b) | wikibase-static | S3 | gebaut 2026-11-01 (Paket 0.22.0, Befund 20; synthetisch geprüft; **echter Test zurückgestellt: die Benchmarks haben nur Nodes; er kommt mit dem ersten Export-Typ mit Ways (S9)**) |
| S7 | Standardabfragen und Feinschliff (Versionsverlauf, Eintrittsversion, Commons-Bilder, Namensnennung) | osm-benchmarks-static | S4 | gebaut 2026-11-01 (Befund 21; Zahlen gegen die Rohdateien geprüft; Abfrage-Seite im Browser nicht gesehen) |
| S8 | Pages-Workflow, ODbL-Hinweis, CI mit `--strict` zweimal | osm-benchmarks-static | S4 | **erledigt 2026-11-01** (Befund 22 und 23) |
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

### Erledigt 2026-11-01 (S2)

Gebaut: `data/csv/entities.csv` (Klasse Q100, Properties P100 bis P113, Beispiel-Item Q1000), `statements.csv` (Q100 ⊂ Q3, Formatter-URL für P104, Definitionsbereich Q100, Wikidata-Entsprechungen P625 und P18), `qualifiers.csv`, `data/crm.csv`, `data/csv/mapping/osm-properties.csv` (A4 „Modell, IDs“). Abnahme in einer frischen Kopie von `028fb2a`: `--strict` zweimal mit Exit-Code 0 und ohne `WARN`, `check-crm` 0 Verstöße, nach Einchecken der erzeugten Dateien (`data/derived/`, `dist/`, `docs/`) und einem weiteren Lauf ist `git status` leer; die Ausgabe nennt 29 Entitäten (4 Klassen: Q1 bis Q3 und Q100; 1 Item: Q1000; 24 Properties), 80 Statements. Die Formularentscheidungen (Tags, Datentypen) stehen in A4. Nicht geprüft: der Lauf der CI auf GitHub; die Karte und die Abfragen mit dem Beispiel-Item wurden nur als Zeilenzahlen gesehen (`coordinates` 1 Zeile, `qualifiers` 5 Zeilen), nicht im Browser.

### S3 — Konverter `import-osm --offline`

**Ziel:** Das Paket macht aus den gesicherten JSON-Dateien die vier CSV-Tabellen des Modells (im Paket-PRIMER ist das S15a).

**Uploads:** Bundle von `wikibase-static`, `data/raw/osm/history/` und `data/csv/mapping/osm-properties.csv`; Claude klont das Paket sonst selbst.

Inhalt: `step_import_osm.py` (Eingabe `data/raw/osm/history/<type>_<id>.json` und optional `data/raw/osm/overpass/<seed>.json`; Ausgabe in `data/csv/`; kanonische Schreibweise wie bei den anderen Importern; Bericht mit Zahlen), Eintrittsregel je Version (A4), Etikett nach A4 „Label“, Wert-Codec für Zeit und Koordinate des Pakets, Ergänzung der Oberklassenkette von `crm:E25_Human-Made_Feature` in `crm.py` (E24 und E26; E25 selbst wird schon akzeptiert, Befund 12), Tests mit den 21 JSON-Dateien als Fixtures.

**Auftrag für den PRIMER von `wikibase-static`** (in S3 dort eingetragen, 2026-11-01): in Teil B die Zeile S15 in S15a (Konverter OSM → CSV, Verb `import-osm`, Version 0.20.0) und S15b (WKT-Geometrie im Renderer und im RDF) aufteilen; in A4 die Zeilen „OSM, Identität“, „OSM, Versionen“, „OSM, Historie“, „OSM, Geometrie“ aus diesem Dokument übernehmen; in A3 die Regel „Netzwerk nur in `harvest` und `import-wikidata`“ um `import-osm` ergänzen; in Teil D den Punkt „E25 hat zwei Oberklassen“ und den Punkt „Zeitwert mit Uhrzeit“ (Befund 15) eintragen.

**Abnahme:** `import-osm --offline --from-dir data/raw/osm/history` erzeugt aus den 21 Dateien **21 Items, 59 Versions-Statements, 21 Eintrittsmarker (Versionen v2: 13, v3: 6, v4: 1, v5: 1) und 33 Geometrie-Einträge**; ein zweiter Lauf ändert nichts; jede Fehlerzeile nennt `datei:zeile`; ein absichtlich beschädigtes JSON ergibt genau eine Meldung; die bestehenden Tests des Pakets bleiben grün.

### Erledigt 2026-11-01 (S3)

Gebaut im Paket: `step_import_osm.py` (Verb `import-osm`), `crm:E25` in `crm.CLASSES` (Oberklasse E24; E26 fehlt, weil `CLASSES` je Klasse nur eine kennt), 24 Tests mit den 21 Dateien als Fixtures, Version 0.20.0, Paket-PRIMER S15a und Befund 87. Gebaut hier: `main.py` mit dem Verb `import-osm`, `data/seeds/benchmarks.csv`, Befund 16, A4-Zeilen „Verb“ und „Auswahl“. Abnahme: die Zahlen aus Befund 16; die Fehlerzeile nennt `datei:zeile` (ein beschädigtes JSON ergibt genau eine Meldung); alle 609 Tests des Pakets laufen durch. **Das Beispiel-Item Q1000 (A4 „Beispiel-Item“) bleibt bis S4 stehen**; ein Import neben ihm meldet `WARN` (das Element ist von Hand beschrieben) und würde ein zweites Item für `node/6666122939` anlegen. In S4: die Zeilen mit `origin=model-example` aus `entities.csv`, `statements.csv` und `qualifiers.csv` entfernen, dann importieren. Nicht geprüft: Ways und Relations, ein gelöschtes Element, Python 3.10 und Windows.

### S4 — Erstbestand

**Ziel:** Die 21 Benchmarks sind als Seiten, Turtle und SPARQL-Seite da.

Inhalt: Lauf der Pipeline gegen `data/raw/osm/history/`, Sichtprobe von Karte, Commons-Bild und Versionsliste, Standardabfragen des Pakets.

**Abnahme:** 21 Entitäten; jede Seite listet alle ihre OSM-Versionen mit Link; `check-crm` ohne Verstöße; `python main.py --strict` zweimal hintereinander, `git status` leer; im RDF kein `owl:sameAs` auf OSM.

### Erledigt 2026-11-01 (S4)

Gebaut: Q1000 aus den drei Tabellen entfernt, `import-osm --offline` gelaufen (21 Items, 59 Versions-Statements, 33 Geometrie-Einträge, 21 Eintrittsmarker; `data/csv/idmap.csv` mit 21 Zeilen), `data_as_of: 2026-11-01` in `site.yaml` (das Datum, an dem die History-Dateien von der API gelesen wurden), neues `README.md`-Stück „State“. Abnahme erfüllt, Zahlen in Befund 17: 21 Entitäten mit Link auf jede ihrer Versionen, `check-crm` 0 Verstöße, `--strict` zweimal, nach dem Einchecken ist `git status` leer, kein `owl:sameAs`. Sichtprobe im Browser an Q118 (Meilenstein): Karte mit Marker, Versionsliste mit Rang `preferred`, Eintrittsmarker, Geometrie-Verlauf mit zwei WKT-Einträgen, 9 Tag-Statements, Statement-Graph. Nicht geprüft: das Commons-Bild und die Kacheln (kein Netz), die Seiten auf GitHub Pages (S8), Python 3.10.

### S5 — Harvest mit Netz

**Ziel:** Neue Elemente und neue Versionen kommen nach, ohne alles neu zu ziehen.

Inhalt: Overpass-Abfrage aus `data/seeds/` (ohne `geom`, nur `out meta`), Vergleich der Versionsnummern mit dem gespeicherten Stand, `/history` nur für neue oder geänderte Elemente, Eintrittsmarker, Austritt (Element fehlt in der Antwort oder die Tag-Bedingung gilt nicht mehr), Meldung bei gelöschten Versionen (`visible=false`), höfliche Pausen, `--probe` (eine Anfrage, schreibt nichts); die Rohantwort wird byte-genau abgelegt (die Dateien der Probe sind neu eingerückt und werden dabei einmal ersetzt).

**Abnahme:** Erster Lauf bei Flo holt die 21 Elemente und stimmt mit den gesicherten Dateien überein; ein zweiter Lauf stellt nur die Overpass-Anfrage und keine `/history`-Anfrage; die Meldung nennt die Zahl der neuen Elemente und Versionen.

### Erledigt 2026-11-01 (S5, Code gegen Attrappe)

Gebaut im Paket 0.21.0: `osm_net.py`, Netzteil von `step_import_osm.py`, 18 neue Tests (davon einer über einen lokalen HTTP-Server mit dem echten `urllib`-Transport), README und PRIMER des Pakets (Befund 88). Gebaut hier: `data/seeds/overpass-benchmarks.overpassql`, `main.py`-Text, `requirements.txt`, Befund 18, A4-Zeilen „Verb“ und „Austritt“. **Offen bleibt der echte Lauf bei Flo:** `import-osm --probe`, dann `import-osm --refresh`, dann `--strict` und Einchecken, später ein zweiter Lauf, der nur die Overpass-Anfrage stellen darf (Abnahme S5). Erst danach ist S5 erledigt. Nicht geprüft: Antwortzeit und Größe von Overpass, Ratenbegrenzung der API, Windows.

### Erledigt 2026-11-01 (S5, echter Lauf)

Abnahme erfüllt, Zahlen in Befund 19: `--probe` (eine Anfrage, nichts geschrieben), `--refresh` (21 von 21 stimmen mit der API überein, 0 Abweichungen), `--strict` und Einchecken (`b9eba9e`), Zweitlauf nur mit der Overpass-Anfrage und ohne neue Datei. Der Bestand wuchs von 21 auf 23 Items (65 Versions-Statements). Die Wiederholung bei 502 ist am echten Server erprobt. Nicht geprüft: Austritt und gelöschte Versionen am echten Server (kam nicht vor), Ratenbegrenzung der API bei mehr als 100 History-Anfragen, Windows-Besonderheiten außer dem Lauf selbst.

### S6 — Geometrie als WKT

**Ziel:** Ways und Relations behalten ihre Fläche; der Verlauf ist auf der Seite und im RDF zu sehen (Paket-S15b).

Inhalt: WKT-Erzeugung aus node, way und relation (Overpass-Stand zu einem Zeitpunkt über `[date:"…"]`, ein Request je Zeitpunkt; die API-History eines Ways liefert nur die Node-Referenzen), Anzeige des aktuellen WKT auf der Karte, `geo:hasGeometry` und `geo:asWKT` je Eintrag, Abfrage „Geometrie zu einem Zeitpunkt“.

**Abnahme:** Ein Way und ein Multipolygon aus einem anderen Export-Typ bauen als WKT-Fläche; die Benchmarks ändern sich nicht; das RDF liest rdflib identisch zurück.

### Erledigt 2026-11-01 (S6, Code gegen synthetische Daten)

Gebaut im Paket 0.22.0: `wkt.py`, `osm_geom.py`, Importer für Ways und Relationen, Mitglieder-Historien (`--members-dir`, `--member-limit`, `--element`), `wkt_property` in `site.yaml`, Karte mit Fläche, GeoSPARQL im RDF, 22 neue Tests (649). Hier: `site.yaml` (`wkt_property: P111`), `requirements.txt` (0.22.0), Befund 20. **Offen bleibt der echte Lauf bei Flo:** `import-osm --element way/<id>` und `--element relation/<id>` (ein Gebäude, ein See) in einer Wegwerfkopie, Sichtprobe der Seite (Fläche auf der Karte, Verlauf) und `git checkout -- . && git clean -fd data` zum Verwerfen; erst danach ist S6 erledigt. Nicht geprüft: echte Daten, Zahl der Anfragen bei großen Ways, Relationen mit Relationen als Mitglied, die Karte der SPARQL-Seite für Flächen (nur `Point`).

### S7 — Standardabfragen und Feinschliff

**Ziel:** Fragen, die ohne den Versionsverlauf nicht zu beantworten waren, sind Standardabfragen.

Inhalt: „Elemente nach Eintrittsversion“, „Elemente, die seit Datum X geändert wurden“, „Benutzer mit den meisten Versionen“, „Elemente mit Positionswechsel über N m“, Commons-Bilder, Hinweis „© OpenStreetMap contributors“ auf jeder Seite.

**Abnahme:** Jede Abfrage liefert auf dem Erstbestand die Zeilenzahlen, die dieser PRIMER aus den JSON-Dateien nennt (Beispiel: Benutzer-Abfrage ergibt 5 Zeilen, 51 Versionen beim Spitzenreiter).

### Erledigt 2026-11-01 (S7)

Gebaut: `queries.yaml` (sechs OSM-Abfragen vor den 13 allgemeinen), sechs `.rq`-Dateien unter `docs/downloads/queries/`. Abnahme: jede Abfrage liefert Zeilen (der Build bricht sonst ab) und die Zahlen stimmen mit einer unabhängigen Zählung über die Rohdateien überein (Befund 21). `--strict` zweimal ohne `WARN`. Nicht geprüft: die Abfrage-Seite im Browser (Pyodide, Kartenansicht von `osm-geometry-at`), die Seiten auf GitHub Pages (S8). **S6 bleibt gebaut:** der Test mit echtem Way und Multipolygon ist zurückgestellt, bis ein Export-Typ mit Ways dran ist (S9, z. B. `holywells`).

### S8 — Pages-Workflow und CI

**Ziel:** Die Seite ist veröffentlicht, jede Änderung wird geprüft.

Inhalt: `site.yml` als Aufrufer des Paket-Workflows (der Block `with: deploy: false` aus S1 fällt weg), Pages auf „GitHub Actions“, `--strict` zweimal mit leerem `git status`, Prüfung des Namensnennungs-Hinweises.

**Abnahme:** Lauf auf GitHub grün, Live-Seite erreichbar, `Q`-Seite und Turtle-Datei einer Entität abrufbar.

### Erledigt 2026-11-01 (S8)

Gebaut: `site.yml` ohne `deploy: false` und mit `command: python main.py --strict && python check_attribution.py`, `check_attribution.py` (Befund 22). Abnahme bei Flo erfüllt (Befund 23): Lauf „Site #10“ nach dem Umstellen der Pages-Quelle grün (Jobs „check“ und „deploy to GitHub Pages“), Live-Seite, `Q101.html`, `ttl/Q101.ttl` und die Abfrage-Seite erreichbar. Nicht geprüft: ein Lauf, in dem `check_attribution.py` im CI rot wird (lokal getestet).

### S9 — Weitere Export-Typen

**Ziel:** Die übrigen Typen aus osm2lod (`holywells`, `ogham`, `ci`, `drillcores`, `romansites`, `sisal`) laufen über dieselbe Quelle.

Inhalt: Entscheidung, ob je Typ ein Repo oder ein Seed in diesem Repo; CRM-Klasse je Typ (Overlay), z. B. Holy Wells: E22 oder E26/E27 nach Prüfung.

**Abnahme:** Rundlauf Seed → Site → RDF behält die CRM-Klassen; `check-crm` ohne Verstöße.

---

## Teil D — Offene Punkte

- **Repo-Name und Organisation:** `osm-benchmarks-static` unter `n4o-rse` ist ein Vorschlag (Muster `fuzzy-sl-static`, `chublets-wikibase-demo`). Alternativen: `benchmarks-static`, `osm-static`; als Ort käme auch `Research-Squirrel-Engineers` in Frage, wo `osm2lod` liegt.
- **Tags, Kehrseite (S2):** Mit einer Property `OSM-Tag` zeigt die Seite die Tags als Liste `key=value`; eine benannte Property je wichtigem Schlüssel (`inscription`, `material`, `direction`) wäre für die Seite schöner und kann später zusätzlich kommen, ohne das Modell zu ändern.
- **Eintrittsregel und Gebiet (S5: ein Element, das in der Overpass-Antwort fehlt, wird als Austritt gesetzt, siehe A4 „Austritt“):** Das Gebiet wird nur beim Harvest geprüft; ein Element, das früher in der Menge war und später die Grenze überschreitet (unwahrscheinlich bei Benchmarks), würde nicht als Austritt erkannt. Für S5 abwägen, ob das genügt.
- **Gelöschte Elemente:** In den 21 Dateien kommt keine gelöschte Version vor; Verhalten (Item behalten, Statement „in OSM gelöscht am …“) ist beschlossen als Idee, nicht erprobt (S5).
- **Way-Geometrie zu einem Zeitpunkt:** Overpass mit `[date:…]` ist hier ein Wissensstand, nicht geprüft; in S6 an einem echten Way zu messen, ebenso die Zahl der Requests.
- **uid und Benutzername im RDF:** Beide Werte sind in OSM öffentlich, stehen aber dauerhaft in den Daten; falls es Widerspruch gibt, wäre ein Schalter in `site.yaml` zu erwägen (beschlossen ist: beides).
- **Label-Vorschlag:** Der Commons-Titel als Rückfall ist nicht bestätigt (A4 „Label“).
- **Netz (S5, erledigt):** Der echte Lauf ist in Befund 19 beschrieben: Overpass antwortete in einer Anfrage (10 965 Bytes) und bei 502 nach Wiederholung. Beim nächsten Harvest `data_as_of` neu setzen. Offen: die Zählung der Wiederholungen in der Meldung `(1 request)` (nächste Paketversion, mit S6).
- **Pages einschalten (S1, S8, erledigt):** Settings → Pages → Source „GitHub Actions“ (einmal); ohne sie scheitert der Deploy-Job (Befund 23).
- **Aktionen mit Node 20 (S8):** Das Paket (`wikibase-static`, `.github/workflows/site.yml`) sollte die Versionen von `actions/configure-pages`, `upload-pages-artifact` und `deploy-pages` anheben, sobald es Node-24-Versionen gibt; sonst nichts zu tun.
- **Deutsche Etiketten (S8):** Die Seiten haben nur `label_en`; im Deutschen steht „No label defined“. Mit der Entscheidung zu den Etiketten (Commons-Dateinamen, siehe oben) zu klären, etwa deutsche Beschreibung „OpenStreetMap-Node 12600848879“.
- **Logo (S1):** `site.yaml` hat kein `logo`; falls eines gewünscht ist, die Datei nach `assets/` und die Zeile `logo: assets/<datei>` ergänzen.
- **`rdf_prefix` und `data_as_of` (S1, S4):** `obs` ist ein Vorschlag. `data_as_of: 2026-11-01` steht seit S4 in `site.yaml`; bei jedem Harvest (S5) neu zu setzen, weil die CSV keine eigene Änderungszeit trägt.
- **Fläche auf der SPARQL-Seite (S6):** Die Kartenansicht der Abfrage-Seite zeichnet nur `Point(...)`; Flächen bräuchten einen WKT-Leser im Browser. Mit S7 zu klären.
- **Zeit und Form eines Ways (S6):** Overpass erkennt keine Änderung an einer Node eines Ways; Abhilfe `--refresh` (holt auch die Mitglieder neu) in größeren Abständen, oder eine Abfrage mit `[date:…]`.
- **`queries.yaml` ersetzt statt zu erweitern (S7):** Die 13 allgemeinen Abfragen sind eine Kopie der Standardabfragen des Pakets und folgen deren Änderungen nicht. Besser wäre ein Schlüssel `extends: default` im Paket; erst nötig, wenn die Standardabfragen sich ändern.
- **Probe-Skript:** `osm_history_probe.py` (lokal in `C:\tmp\pytemp`) wird mit S5 durch `import-osm` ersetzt; bis dahin nicht ins Repo, weil es nach `data/raw/osm_history` schreibt und nicht nach `data/raw/osm/history`.
- **P103 als Zeichenkette (S2):** Sortieren und Filtern nach Zeit geht in SPARQL nur über den Text (ISO 8601 ist lexikalisch sortierbar). Sobald das Paket Zeitwerte mit Uhrzeit kann (Befund 15), Datentyp auf `time` stellen.
- **Etiketten aus Commons-Dateinamen (S4):** 20 von 21 Etiketten sind Dateititel (`MilestoneDublin8Howth1`, ohne Leerzeichen und mit Sonderzeichen). Möglich: das Etikett ergänzen um die Inschrift (`inscription`) oder `ref`, oder die Camel-Case-Titel trennen. Entscheidung offen (A4 „Label“ ist ein Vorschlag).
- **Austritt und Zeit (S5):** Overpass kann hinter der API zurückliegen; ein Element fehlt dann kurz in der Antwort, und die Marke „bis“ verschwindet im nächsten Lauf wieder. Ein Austritt, der als Ereignis mit Datum bleiben soll, bräuchte eine eigene Tabelle; nicht gebaut.

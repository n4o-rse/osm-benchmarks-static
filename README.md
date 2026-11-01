# osm-benchmarks-static

A static, read-only Wikibase (GitHub Pages) for OpenStreetMap elements, starting with the benchmarks
(`man_made=survey_point`, `benchmark=yes`, with a Wikimedia Commons image) of Ireland, Northern Ireland
and Scotland.

Each OSM element becomes one item with one QID, as OSM itself knows only one ID per element. The
element's version history is tracked as statements on that item, and every item is anchored on a
CIDOC CRM class (`crm:E25 Human-Made Feature`). The geometry of each version is kept as WKT, so
the model also carries ways and relations.

Status: planning. The work plan, the decisions made so far and the steps ahead are in
[`PRIMER.md`](PRIMER.md) (German). The first data is in `data/raw/osm/history/`: the OSM API history of the
21 benchmark nodes of the osm2lod run of 2026-03-22.

## Related repositories

- [`Research-Squirrel-Engineers/osm2lod`](https://github.com/Research-Squirrel-Engineers/osm2lod): the prototype that exports OSM data via Overpass into RDF and a Wikibase.
- [`n4o-rse/wikibase-static`](https://github.com/n4o-rse/wikibase-static): the package that turns CSV tables into the static Wikibase pages, RDF and SPARQL page.

## Data and licence

The data are derived from OpenStreetMap: © OpenStreetMap contributors, available under the
[Open Database Licence (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/).
The licence of the code is added with the skeleton (step S1 of the plan).

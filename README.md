# osm-benchmarks-static

A static, read-only Wikibase (GitHub Pages) for OpenStreetMap elements, starting with the benchmarks
(`man_made=survey_point`, `benchmark=yes`, with a Wikimedia Commons image) of Ireland, Northern Ireland
and Scotland. It is built with [wikibase-static](https://github.com/n4o-rse/wikibase-static).

Each OSM element becomes one item with one QID, as OSM itself knows only one ID per element. The
element's version history is tracked as statements on that item, and every item is anchored on a
CIDOC CRM class (`crm:E25 Human-Made Feature`). The geometry of each version is kept as WKT, so
the model also carries ways and relations.

**State (S4):** the first stock. The history of 21 benchmark nodes (59 versions, in `data/raw/osm/history/`) is turned into
21 items by `python main.py import-osm --offline`; the pages, the RDF and the SPARQL page are built from them. Harvest from the
network, ways and relations, and publishing on GitHub Pages are the steps that follow. The work plan, the decisions made so far
and the steps ahead are in [`PRIMER.md`](PRIMER.md) (German).

## Build

Needs Python 3.10 or later. In a Windows `cmd` window, in this folder:

    pip install -r requirements.txt && python main.py --strict

`python main.py --list` shows the steps. `python main.py import-osm --offline` turns the files in `data/raw/osm/history/` into rows of `data/csv/`; the default run builds the site from them.
`update.cmd` installs the current `wikibase-static` again, builds with `--strict`, and commits and pushes
only if something changed.

## Related repositories

- [`Research-Squirrel-Engineers/osm2lod`](https://github.com/Research-Squirrel-Engineers/osm2lod): the prototype that exports OSM data via Overpass into RDF and a Wikibase.
- [`n4o-rse/wikibase-static`](https://github.com/n4o-rse/wikibase-static): the package that turns CSV tables into the static Wikibase pages, RDF and SPARQL page.
- [`n4o-rse/fuzzy-sl-static`](https://github.com/n4o-rse/fuzzy-sl-static) and [`n4o-rse/chublets-wikibase-demo`](https://github.com/n4o-rse/chublets-wikibase-demo): sibling site repositories.

## Licence and attribution

The code of this repository is under the [MIT licence](LICENSE).

The data are derived from OpenStreetMap: © OpenStreetMap contributors, available under the
[Open Database Licence (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/).
Every page of the site carries that notice (`license` in `site.yaml`).

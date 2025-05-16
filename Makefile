SHELL := /bin/bash

SPARQL_ENDPOINT = https://qlever.cs.uni-freiburg.de/api/wikidata
P1 = <http://www.wikidata.org/prop/direct/P106>
P2 = <http://www.wikidata.org/prop/direct/P735>
get-data:
	curl -s $(SPARQL_ENDPOINT) -H "Accept: text/turtle" -H "Content-type: application/sparql-query" --data "CONSTRUCT { ?s <p1> ?o } WHERE { ?s $(P1) ?o }" | sed 1d > p1.ttl
	curl -s $(SPARQL_ENDPOINT) -H "Accept: text/turtle" -H "Content-type: application/sparql-query" --data "CONSTRUCT { ?s <p2> ?o } WHERE { ?s $(P2) ?o }" | sed 1d > p2.ttl
	cut -d" " -f1,3 p1.ttl | sed 's/ /\t/' > p1.tsv
	cut -d" " -f1,3 p2.ttl | sed 's/ /\t/' > p2.tsv

sqlite-load:
	rm -f perf.db
	time sqlite3 perf.db < load.sql

qlever-load:
	time qlever index --overwrite-existing > perf.index-log.txt 2>&1

sqlite-query-1:
	time sqlite3 perf.db "SELECT COUNT(*) AS count FROM p1, p2 WHERE p1.subject = p2.subject;"

qlever-query-1:
	qlever start --kill-existing-with-same-port > perf.server-log.txt 2>&1
	time qlever query --log-level NO_LOG "SELECT (COUNT(*) AS ?count) { ?s <p1> ?o1 . ?s <p2> ?o2 }"

sqlite-query-2:
	time sqlite3 perf.db "SELECT p1.subject, p1.object, p2.object FROM p1, p2 WHERE p1.subject = p2.subject;" | wc -l

qlever-query-2:
	qlever start --kill-existing-with-same-port > /dev/null 2>&1
	time qlever query --log-level NO_LOG "SELECT ?s ?o1 ?o2 { ?s <p1> ?o1 . ?s <p2> ?o2 }" | sed 1d | wc -l

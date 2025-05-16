# SQLite vs. QLever

Download the two predicates `P106` and `P735` from Wikidata (each with around
10 million triples) and create analogous inputs for SQLite and QLever. The
input for SQLite is two TSV files with two columns each (subject and object of
the respective predicate). The input for QLever is two TTL files with the
subject, predicate and object of the respective predicate. These files can be
created with

```bash
make get-data
```

# Loading time

The triples can be loaded into SQLite and QLever with the following commands.

```bash
make sqlite-load
make qlever-load

```

# Querying

There are two query pairs, where each pair consists of a query for SQLite and
the analogous query for QLever. The first pair counts the result of the join of
the two predicates. The second pair materializes the join. The queries can be
exuted as follows:

```bash
make sqlite-query-1 qlever-query-1
make sqlite-query-2 qlever-query-2
```

# Performance comparison

The commands above were run on an AMD Ryzen 9 9950X with 16 cores, 192 GB of RAM,
and 4 x 8 TB NVMe SSDs configured as a RAID 0. These are generous resources,
given the small data. We expect the results on a smaller machine to be very similar.

Loading the data takes around 17s for both SQLite and QLever.

The database file created by SQLite has a size of 3.9 GB, while the index files
created by QLever have a total size of only 448 MB, which is a factor of 8.8
times smaller.

The first query (counting the result of the join) takes 2.1s for SQLite, and
around 0.28s for QLever, which is 7.4 times faster.

The second query (materializing the result of the join) takes 3.5s for SQLite,
and 8.1s for QLever, which is 2.3 times slower.

# Explanation

QLever's precomputation is significantly more involved. It builds similar indices
to those precomputed by SQLite, and many more.

QLever computen an ID for each unique string and computes with these IDs
internally. The join operation can therefore be implemented as a merge join
operating on fixed-size IDs. When the result is materialized, the internal IDs
are converted back to the original strings. The data is stored column-based.

In constrast, SQLite implements the join operation as a nested loop join, which
directly compares the strings. Therefore, no translation process is needed when
producing the result. The data is stored row-based.

This explains the much faster query time for QLever when counting the number of
results of the join, as well as the somewhat slower time when materializing the result.

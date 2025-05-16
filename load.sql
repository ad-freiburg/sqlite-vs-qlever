PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;

CREATE TABLE p1(subject TEXT, object TEXT);
CREATE TABLE p2(subject TEXT, object TEXT);

.separator "\t"
.import p1.tsv p1
.import p2.tsv p2

CREATE INDEX idx_p1_subject ON p1(subject);
CREATE INDEX idx_p1_object ON p1(object);
CREATE INDEX idx_p2_subject ON p2(subject);
CREATE INDEX idx_p2_object ON p2(object);

(import "./rqlite")

(printf "%m" (rqlite/execute ["create table foo (id integer not null primary key, name text)"] :flags [:x]))
(printf "%m" (rqlite/query ["select * from foo"] :flags [:a]))

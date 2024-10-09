(import ../src :prefix "rqlite/")

(printf "%m" (rqlite/execute ["create table if not exists foo (id integer not null primary key, name text)"] :flags [:x]))
(printf "%m" (rqlite/query ["select * from foo"] :flags [:a]))

(import ../src :prefix "rqlite/")

(rqlite/execute ["create table if not exists schema_version (version integer not null default 0)"])

(def row-count (get-in (rqlite/query ["select count(*) as row_count from schema_version"] :flags [:a]) [:data "results" 0 "rows" 0 "row_count"]))

(if (= row-count 0) (rqlite/execute ["insert into schema_version (version) values (0)"]))

(def migrations @["create table users (id integer primary key, name text not null, age integer not null)"
                  "create table items (sku integer primary key, name text not null, price integer not null)"
                  "create table orders (id integer primary key, user_id integer not null, item_id integer not null, quantity integer not null default 1)"])

(def migration-count (length migrations))

(array/push migrations ["update schema_version set version = ?" migration-count])

(def schema-version (get-in (rqlite/query ["select version from schema_version"] :flags [:a]) [:data "results" 0 "rows" 0 "version"]))

(print "starting from schema version " schema-version)

(def migration-result (rqlite/execute (array/slice migrations schema-version) :flags [:x]))

(def err (get-in migration-result [:data "results" 0 "error"]))

(if err (error (string "there was an error - " err)))

(def new-schema-version (get-in (rqlite/query ["select version from schema_version"] :flags [:a]) [:data "results" 0 "rows" 0 "version"]))

(print "new schema version is " new-schema-version)

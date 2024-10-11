(import ../src :prefix "rqlite/")

(def- credentials {:username "hello"
                   :password "world"})

(rqlite/execute ["create table if not exists schema_version (version integer not null default 0)"] ;(kvs credentials))

# Prepare the schema_version table if it was just created.
(if (= (get-in
         (rqlite/query ["select count(*) as row_count from schema_version"] :flags [:a] ;(kvs credentials))
         [:data "results" 0 "rows" 0 "row_count"]) 0)
  (rqlite/execute ["insert into schema_version (version) values (0)"] ;(kvs credentials)))

# These are the schema migrations for the database. Never remove migrations or add them
# in the middle. Add them to the end of the list.
(def migrations @["create table users (id integer primary key, name text not null, age integer not null)"
                  "create table items (sku integer primary key, name text not null, price integer not null)"
                  "create table orders (id integer primary key, user_id integer not null, item_id integer not null, quantity integer not null default 1)"])

# Squeeze in a version update. Each query increments the version by 1.
(array/push migrations ["update schema_version set version = ?" (length migrations)])

# Execute the migrations, skipping over the already used ones.
(let [schema-version (get-in (rqlite/query ["select version from schema_version"] :flags [:a] ;(kvs credentials)) [:data "results" 0 "rows" 0 "version"])] (print "starting from schema version " schema-version)
  (let [migration-result (rqlite/execute (array/slice migrations schema-version) :flags [:x] ;(kvs credentials))
        err (get migration-result :error)] (if err (error (string "there was an error - " err)))))

(print "new schema version is "
       (get-in (rqlite/query ["select version from schema_version"] :flags [:a] ;(kvs credentials)) [:data "results" 0 "rows" 0 "version"]))

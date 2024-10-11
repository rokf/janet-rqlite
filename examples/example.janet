(import ../src :prefix "rqlite/")

(def- credentials {:username "hello"
                   :password "world"})

(printf "%m" (rqlite/query ["select * from foo"] :flags [] ;(kvs credentials)))

(import spork/http)
(import spork/json)

(def- default-host
  "The default host for a local rqlite instance."
  "http://localhost:4001")

(def- flag-to-string {:x "transaction"
                      :t "timings"
                      :a "associative"
                      :b "blob_array"
                      :q "queue"
                      :w "wait"
                      :n "norwrandom"
                      :s "freshness_strict"
                      :r "redirect"})

(defn- not-nil? [x]
  (not (nil? x)))

(defn- query-format [flags &keys {:timeout timeout :db-timeout db-timeout :level level :freshness freshness}]
  (let [query-params (string/join (filter not-nil? [(if db-timeout (string/format "db_timeout=%s" db-timeout))
                                                    (if timeout (string/format "timeout=%s" timeout))
                                                    (if level (string/format "level=%s" level))
                                                    (if freshness (string/format "freshness=%s" freshness))
                                                    ;(map (fn [x] (get flag-to-string x)) flags)]) "&")] (if (= query-params "") "" (string "?" query-params))))

(defn- rqlite-request [path queries &keys {:host host
                                           :flags flags
                                           :timeout timeout
                                           :db-timeout db-timeout
                                           :level level
                                           :freshness freshness}]
  (default host default-host)
  (default flags @[])
  (default timeout nil)
  (default db-timeout nil)
  (default level nil)
  (default freshness nil)
  (let [response (http/request :POST
                               (string/format
                                 "%s%s%s"
                                 host
                                 path
                                 (query-format flags :db-timeout db-timeout :timeout timeout :level level :freshness freshness))
                               :headers {:content-type "application/json"}
                               :body (json/encode queries))]
    {:data (json/decode (get response :body))
     :status (get response :status)
     :message (get response :message)
     :headers (get response :headers)}))


(defn execute [queries &keys {:host host :flags flags :timeout timeout :db-timeout db-timeout :level level :freshness freshness}]
  (rqlite-request "/db/execute" queries :host host :flags flags :timeout timeout :db-timeout db-timeout :level level :freshness freshness))

(defn query [queries &keys {:host host :flags flags :timeout timeout :db-timeout db-timeout :level level :freshness freshness}]
  (rqlite-request "/db/query" queries :host host :flags flags :timeout timeout :db-timeout db-timeout :level level :freshness freshness))

(defn request [queries &keys {:host host :flags flags :timeout timeout :db-timeout db-timeout :level level :freshness freshness}]
  (rqlite-request "/db/request" queries :host host :flags flags :timeout timeout :db-timeout db-timeout :level level :freshness freshness))

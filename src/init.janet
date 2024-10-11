(import spork/http)
(import spork/json)
(import spork/base64)

(def- default-host
  "The default host for a local rqlite instance."
  "localhost:4001")

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
                                           :freshness freshness
                                           :username username
                                           :password password}]
  (default host default-host)
  (default flags @[])
  (default timeout nil)
  (default db-timeout nil)
  (default level nil)
  (default freshness nil)
  (default username nil)
  (default password nil)
  (def headers @{:content-type "application/json"})
  (if (and (not-nil? username) (not-nil? password)) (put headers :authorization (string/format "Basic %s" (base64/encode (string username ":" password)))))

  (let [http-query (string
                     "http://" # spork/http doesn't yet support HTTPS for some reason
                     host
                     path
                     (query-format flags :db-timeout db-timeout :timeout timeout :level level :freshness freshness))
        response (http/request :POST
                               http-query
                               :headers headers
                               :body (json/encode queries))
        data (json/decode (get response :body))
        extract-error (fn [results]
                        # @TODO optimize this
                        (let [result-with-error (find (fn [result]
                                                        (not-nil? (get result "error"))) results nil)]
                          (if (not-nil? result-with-error) (get result-with-error "error") nil)))]

    {:data data
     :status (get response :status)
     :message (get response :message)
     :headers (get response :headers)
     :error (extract-error (get data "results"))}))


(defn execute
  "Makes a POST requests towards rqlite's execute API endpoint."
  [queries &keys options]
  (rqlite-request "/db/execute" queries ;(kvs options)))

(defn query
  "Makes a POST requests towards rqlite's query API endpoint."
  [queries &keys options]
  (rqlite-request "/db/query" queries ;(kvs options)))

(defn request
  "Makes a POST requests towards rqlite's request API endpoint."
  [queries &keys options]
  (rqlite-request "/db/request" queries ;(kvs options)))

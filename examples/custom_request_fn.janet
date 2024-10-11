(import ../src :prefix "rqlite/")
(import spork/http)
(import spork/json)

(def- credentials {:username "hello"
                   :password "world"})

# This is an example of how to define a custom request function, replacing spork's http/request function but reusing its API.
(printf "%m" (rqlite/query
               ["select * from foo"]
               :flags []
               ;(kvs credentials)
               :request-fn (fn [method url &keys {:headers headers :body body}]
                             {:headers {}
                              :status 200
                              :message "OK"
                              :body (string (json/encode {:results [{:method method
                                                                     :url url
                                                                     :headers headers
                                                                     :body body}]}))})))

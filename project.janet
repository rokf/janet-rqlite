(declare-project
  :name "janet-rqlite"
  :author "Rok Fajfar <hi@rokf.dev>"
  :description "A rqlite API client library for Janet"
  :license "MIT"
  :version "0.0.1"
  :url "https://github.com/rokf/janet-rqlite"
  :repo "git+https://github.com/rokf/janet-rqlite"
  :dependencies ["spork"])

(declare-source
  :prefix "rqlite"
  :source ["src/init.janet"])

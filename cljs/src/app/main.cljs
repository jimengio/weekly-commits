
(ns app.main
  (:require ["fs" :as fs]
            ["path" :as path]
            [favored-edn.core :refer [write-edn]]
            [medley.core :refer [map-vals map-kv]]
            [clojure.string :as string]
            ["luxon" :refer [DateTime]]))

(defonce projects-commits
  (js->clj
   (js/JSON.parse
    (fs/readFileSync (path/join js/__dirname "../../data/commits.json") "utf8"))
   :keywordize-keys
   true))

(defn daily-commits! []
  (let [result (->> projects-commits
                    (map
                     (fn [[repo records]]
                       [repo (->> records (map (fn [record] (assoc record :repo repo))))]))
                    (mapcat last)
                    (map
                     (fn [record]
                       {:author (let [author (get-in record [:commit :author :name])]
                          (case author "yuan jia" "yuanjiaCN" "Mihu Seen" "MihuSeen" author)),
                        :date (let [time (.fromISO
                                          DateTime
                                          (get-in record [:commit :author :date]))]
                          (.toFormat time "yyyy-MM-dd")),
                        :repo (:repo record),
                        :add (get-in record [:stats :additions]),
                        :delete (get-in record [:stats :deletions])}))
                    (group-by :date)
                    (map-vals
                     (fn [records]
                       (->> records
                            (group-by :author)
                            (map-vals
                             (fn [records]
                               (->> records
                                    (map (fn [record] (dissoc record :date :author)))
                                    (vec)
                                    (count)))))))
                    (map
                     (fn [[date info]]
                       [date
                        (let [time (.fromISO DateTime date)] (.toFormat time "ccc"))
                        info]))
                    (sort-by first)
                    (vec))]
    (println (write-edn result))))

(defn display-number [n char]
  (let [x (js/Math.ceil (/ n 200))] (str (string/join "" (repeat x char)) " " n)))

(defn format-records [info]
  (->> info
       (mapcat
        (fn [[author work-info]]
          (concat
           ["\n" author]
           (->> work-info
                (mapcat
                 (fn [[project changes]]
                   ["\n"
                    "  "
                    project
                    "\n"
                    "    "
                    (display-number (:add changes) "+")
                    "\n"
                    "    "
                    (display-number (:delete changes) "-")]))))))))

(defn display-graph! []
  (let [result (->> projects-commits
                    (map
                     (fn [[repo records]]
                       [repo (->> records (map (fn [record] (assoc record :repo repo))))]))
                    (mapcat last)
                    (group-by
                     (fn [info]
                       (let [author (get-in info [:commit :author :name])]
                         (case author
                           "yuan jia" "yuanjiaCN"
                           "Mihu Seen" "MihuSeen"
                           "Dave" "wangcch"
                           "yuelei" "YueLei"
                           author))))
                    (map-vals
                     (fn [v]
                       (->> v
                            (map
                             (fn [info]
                               {:repo (:repo info),
                                :add (get-in info [:stats :additions]),
                                :delete (get-in info [:stats :deletions]),
                                :message (get-in info [:commit :message])}))
                            (group-by :repo)
                            (map-vals
                             (fn [records]
                               (->> records
                                    (map (fn [record] (dissoc record :repo :message)))
                                    (reduce
                                     (fn [acc record]
                                       (if (or (> (:add record) 5000)
                                               (> (- (:delete record) (:add record)) 500))
                                         (do
                                          (println "skip large changes" (pr-str record))
                                          acc)
                                         (-> acc
                                             (update :add (fn [x0] (+ x0 (:add record))))
                                             (update
                                              :delete
                                              (fn [x0] (+ x0 (:delete record)))))))
                                     {:add 0, :delete 0}))))))))]
    (fs/writeFileSync (path/join js/__dirname "result.edn") (write-edn result))
    (println "Wrote to file result.edn .")
    (println (string/join "" (format-records result)))))

(defn write-info! []
  (let [result (->> projects-commits
                    (map
                     (fn [[repo records]]
                       [repo (->> records (map (fn [record] (assoc record :repo repo))))]))
                    (mapcat last)
                    (group-by
                     (fn [info]
                       (let [author (get-in info [:commit :author :name])]
                         (case author "yuan jia" "yuanjiaCN" "Mihu Seen" "MihuSeen" author))))
                    (map-vals
                     (fn [v]
                       (->> v
                            (map
                             (fn [info]
                               {:repo (:repo info),
                                :add (get-in info [:stats :additions]),
                                :delete (get-in info [:stats :deletions]),
                                :message (get-in info [:commit :message])}))
                            (group-by :repo)
                            (map-vals
                             (fn [records]
                               (->> records
                                    (map (fn [record] (dissoc record :repo :message)))
                                    (vec))))))))]
    (fs/writeFileSync (path/join js/__dirname "result.edn") (write-edn result))))

(defn analyze! [] (display-graph!) (comment write-info!) (comment daily-commits!))

(defn main! [] (println "Started.") (analyze!))

(defn reload! [] (.clear js/console) (println "Reloaded.") (analyze!))

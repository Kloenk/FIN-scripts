;; (macro checkValue [v body ?optional ?msg]
;;   `(if (= v nil)
;;    ,(if (not ?optional)
;;      `(computer.panic ,(or ?msg "Value missing"))
;;     )
;;    ,body
;;    )
;; )

(fn dec-require []
  [
	  `(global ,(sym :package) {:preload {}})
		`(set-forcibly! ,(sym :require)
		  (fn [name#]
        (let [lib# (. (. package :preload) name#)]
				  (match (type lib#)
					  nil nil
						:function (lib#)
						v# (_G.computer.panic (.. "Cannot require type: " v#))
          )
				)
		))
	]
)

(fn dec-component [vname nick ?options]
  `(local ,vname (get-component ,nick ,?options)))

(fn dec-module [vname panel x y ?options]
  `(local ,vname (get-module ,panel ,x ,y ,?options)))

{: dec-require : dec-component : dec-module}


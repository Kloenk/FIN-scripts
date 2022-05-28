; vim: syntax=lips

(import-macros {: dec-component : dec-module} :macro)

;; helpers
(fn get-default-options [options]
  "Transform to option struct"
  (if (= options nil) {}
      (= (type options) :boolean) {:listen options}
      options))

(macro checkValue [v body ?optional ?msg]
  `(if (= ,v nil)
	 ,(if (not ?optional)
	   `(_G.computer.panic ,(or ?msg "Value missing"))
    )
	 ,body
	 )
)

(fn get-component [name options]
  "Get one Component proxy by name"
	(let [options (get-default-options options)
	  id (. (_G.component.findComponent name) 1)]
		 (if (= id nil)
  	  (if (or (. options :required) (= (. options :required) nil))
		    (_G.computer.panic (.. "Cannot find: " name))
		  )
			(let [c (_G.component.proxy id)]
			  (if (. options :listen)
				  (_G.event.listen c)
				)
				c
  		)
		)
	)
)

(fn get-module [panel x y options]
  "Get Module from Panel at xy position"
	(let [options (get-default-options options)]
  	(checkValue panel
  	  (let [module (panel:getModule x y)]
			  (checkValue module
				  (if (. options :listen)
					  (do 
						  (_G.event.listen module)
							module
						)
						module
					)
				)
			)
  	)
	)
)
;;
;;
;;(macro dec-component [vname nick ?options]
;;  `(local ,vname (get-component ,nick ,?options))
;;)
;;
;;(macro dec-module [vname panel x y ?options]
;;  `(local ,vname (get-module ,panel ,x ,y ,?options))
;;)

;; variables
(dec-component CSimple1 "Container Simple 1")
(dec-component CSimple2 "Container Simple 2")
(dec-component CSimpleS12 "Splitter Simple 12" true)
(dec-component CSimpleS1234 "Splitter Simple 1234" true)
(local CSimple1Items ["Iron Rod" "Iron Plate" "Concrete" "Cable" "Wire"])
(local CSimple2Items ["Screw" "Quickwire" "Quartz Crystal" "Silica" "Color Cartridge"])

(dec-component panel "Panel")

(dec-module PReset panel 0 0 true)
(dec-module PStop panel 1 1 true)
(dec-module POnOff panel 0 2 true)
(dec-module PStatus panel 1 2)
(dec-module PTraffic panel 2 2)
(var working true)
(var stop false)

;; Function cache
;;;; Indecator
(local find-set-color PTraffic.setColor)

;;;; Splitter
(local fsp-get-input CSimpleS12.getInput)
(local fsp-tranfsfer-item CSimpleS12.transferItem)

;;;; Container
(local fct-get-inventories CSimple1.getInventories)

;;;; Inventories
(local finv-get-stack (. (. (fct-get-inventories CSimple1 1) 1) :getStack))


(fn contains [list entry]
  (each [_ v (ipairs list)]
	  (if (= v entry)
		  (lua "return true")
		)
	)
	false
)

(fn check-container-space [container]
  (let [inv  (. (fct-get-inventories container 1) 1)
	      size inv.size]
	  (= (. (finv-get-stack inv (- size 1)) :count) 0)
	)
)

(fn move-to-container [splitter container idx]
  (if (check-container-space container)
	  (fsp-tranfsfer-item splitter idx)
		(fsp-tranfsfer-item splitter 1)
	)
)

;; splitter loops
(fn run-simple-12 []
  (let [name (. (or (. (fsp-get-input CSimpleS12) :type) {}) :name)]
	  (if (= name nil)
		  nil
	    (if (contains CSimple1Items name)
		    (move-to-container CSimpleS12 CSimple1 0)
		  	(contains CSimple2Items name)
		  	(move-to-container CSimpleS12 CSimple2 2)
		  	(do
		  	  (_G.computer.beep 10)
		  		(print "Cannot route" name)
          (fsp-tranfsfer-item CSimpleS12 1)
		  	)
		  )
		)
	)
)

(fn run-simple-1234 []
  (let [item (. (or (. (fsp-get-input CSimpleS1234) :type) {}) :name)]
	  (if (= name nil)
		  nil
			(if (or (contains CSimple1Items name) (contains CSimple2Items name))
			  (fsp-tranfsfer-item CSimpleS1234 0)
				;; TODO: splitter 5678
				(fsp-tranfsfer-item CSimpleS1234 1)
			)
		)
	)
)

(fn run-all []
	(run-simple-12)
	(run-simple-1234)
)

(fn event-item-request [sender]
	(if (not working)
		(lua "return")
	)

	(match sender
	  CSimpleS12 (run-simple-12)
		CSimpleS1234 (run-simple-1234)
	)
)


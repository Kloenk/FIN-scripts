; vim: syntax=lisp

;; Config

(local *nicks* {:panel :panel})

(local *panel-config* {:truck_belts [[0 1] true]})

;; 
(import-macros {: dec-component : dec-module : dec-require} :macro)

(dec-require)

(let [routers (include :trucks_routers)]
  (routers.run)
)

(local lib (include :lib))
(local network (include :network))
(local panel (include :trucks_panel))

(network.init)
(network.open 1)
(panel.init (. *nicks* :panel))
(panel.config *panel-config*)

(fn loop []
  (while true
	  (match (_G.event.pull)
		  nil nil
		  v (print v)
		)
	)
)

(fn main []
  (loop)
)

(main)

;(local panel-pos
;  {:screen [0 10]
;	 :stop [10 10]
;	 :reset [10 8]
;	 :restart [10 0]
;	}
;)
;
;(local sci-color
;  {
;	:stand [0.949 0.149 0.168 0.75]
;	:empty [0.949 0.854 0.149 0.5]
;	:ok [0.149 0.949 0.196 0.5]
;	}
;)
;
;(print (. panel-pos :screen))
;
;(import-macros {: dec-component : dec-module : dec-require} :macro)
;
;(dec-require)
;
;(local lib (include :lib))
;(local network (include :network))
;(local panel (include :trucks_panel))
;
;(network.init)
;(network.open 1)
;
;(dec-component scanner-in "scanner in" true)
;(dec-component scanner-out "scanner out" true)
;(dec-component panel :panel)
;(global num-stations 4)
;
;;; function cache
;;;;; scanner
;(local fs-get-last-vehicle scanner-in.getLastVehicle)
;(local fs-set-color scanner-in.setColor)
;
;(var *current-vehicles* 0)
;(var *enable-self-driving* 0)
;(var *working* true)
;
;(fn get-panel-module [name ?listen]
;  (let [pos (. panel-pos name)
;	      module (panel:getModule (table.unpack pos))]
;		(if (= module nil)
;		  nil
;			(do
;			  (if ?listen
;				  (event.listen module)
;				)
;			)
;		)
;		(values module)
;	)
;)
;
;(macro dec-panel-module [name# ?listen#]
;  `(local ,(sym (.. :panel_ name#)) (get-panel-module ,name# ,?listen#))
;)
;
;(dec-panel-module :screen)
;(dec-panel-module :stop true)
;(dec-panel-module :reset true)
;(dec-panel-module :restart true)
;
;(fn vehicle-enter-in [vehicle]
;  (if (or (not *working*) (> *current-vehicles* num-stations))
;	  (do
;	    (set *enable-self-driving* (. vehicle :is_self_driving))
;  		(tset vehicle :is_self_driving false)
;		)
;		(set *current-vehicles* (+ *current-vehicles* 1))
;	)
;)
;
;(fn vehicle-enter-out []
;  (if (> *current-vehicles*  0)
;	  (set *current-vehicles* (- *current-vehicles* 1))
;	)
;	(let [in-vehicle (fs-get-last-vehicle scanner-in)]
;    (tset in-vehicle :is_self_driving *enable-self-driving*)
;	)
;)
;
;(fn update-colors []
;	(if (or (not *working*) (> *current-vehicles* num-stations)) (do
;	    (fs-set-color scanner-in (table.unpack (. sci-color :stand)))
;	  )
;		(= *current-vehicles* 0) (do
;		  (fs-set-color scanner-in (table.unpack (. sci-color :empty)))
;		)
;		(do
;		  (fs-set-color scanner-in (table.unpack (. sci-color :ok)))
;		)
;	)
;)
;
;(fn panel-update []
;  (if *working*
;	  (do
;	    (tset panel_screen :text *current-vehicles*)
;		  (tset panel_screen :size 100)
;		)
;		(do
;		  (tset panel_screen :text :Stopped)
;      (tset panel_screen :size 90)
;		)
;	)
;)
;
;(fn update []
;  (panel-update)
;	(update-colors)
;)
;
;(fn main []
;  (fs-set-color scanner-out 0.058 0.462 0.901 0.5)
;	(update)
;	(while true
;	  (match (event.pull)
;		  nil nil
;			("OnVehicleEnter" scanner_in v) (vehicle-enter-in v)
;			("OnVehicleEnter" scanner_out v) (vehicle-enter-out v)
;			e (print e)
;		)
;	)
;)
;
;(main)

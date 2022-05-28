; vim: syntax=lips

(import-macros {: dec-component : dec-module : dec-require} :macro)

(dec-require)

(local lib (include :lib))
(local network (include :network))

(network.init)
(network.open 1)

;; variables
(dec-component CSimple1 "Container Simple 1")
(dec-component CSimple2 "Container Simple 2")
(dec-component CSimpleS12 "Splitter Simple 12" true)
(dec-component CSimpleS1234 "Splitter Simple 1234" true)
(local CSimple1Items ["Iron Rod" "Iron Plate" :Concrete :Cable :Wire])
(local CSimple2Items [:Screw
                      :Quickwire
                      "Quartz Crystal"
                      :Silica
                      "Color Cartridge"])

(dec-component panel :Panel)

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
(local fsp-transfer-item-raw CSimpleS12.transferItem)
(fn fsp-transfer-item [...]
  (find-set-color PTraffic 0.909 0.819 0.066 0.75)
  (fsp-transfer-item-raw ...))

;;(local fsp-transfer-item CSimpleS12.transferItem)

;;;; Container
(local fct-get-inventories CSimple1.getInventories)

;;;; Inventories
(local finv-get-stack (. (. (fct-get-inventories CSimple1 1) 1) :getStack))

(fn contains [list entry]
  (each [_ v (ipairs list)]
    (if (= v entry)
        (lua "return true")))
  false)

(fn check-container-space [container]
  (let [inv (. (fct-get-inventories container 1) 1)
        size inv.size]
    (= (. (finv-get-stack inv (- size 1)) :count) 0)))

(fn move-to-container [splitter container idx]
  (if (check-container-space container)
      (fsp-transfer-item splitter idx)
      (fsp-transfer-item splitter 1)))

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
              (fsp-transfer-item CSimpleS12 1))))))

(fn run-simple-1234 []
  (let [name (. (or (. (fsp-get-input CSimpleS1234) :type) {}) :name)]
    (if (= name nil)
        nil
        (if (or (contains CSimple1Items name) (contains CSimple2Items name))
            (fsp-transfer-item CSimpleS1234 0)
            ;; TODO: splitter 5678
            (fsp-transfer-item CSimpleS1234 1)))))

(fn run-all []
  (run-simple-12)
  (run-simple-1234))

(fn event-item-request [sender]
  (if (not working)
      (lua :return))
  (match sender
    CSimpleS12 (run-simple-12)
    CSimpleS1234 (run-simple-1234)))

;; Panel
(fn buttons-update []
  (if (and working (not stop))
      (do
        (POnOff:setColor 0 1 0 1)
        (find-set-color PStatus 0 1 0 1)
        (PReset:setColor 0 0 0 0))
      stop
      (do
        (POnOff:setColor 0 0 0 0)
        (find-set-color PStatus 1 0 0 1)
        (PReset:setColor 1 0 0 1))
      (do
        (POnOff:setColor 1 0 0 1)
        (find-set-color PStatus 0 0 0 0)
        (PReset:setColor 0 0 0 0))))

(fn buttons-init []
  (find-set-color PTraffic 0.909 0.819 0.066 0)
  (set working (. POnOff :state))
  (buttons-update))

(fn emergency-stop []
  (_G.computer.beep 10)
  (set working false)
  (set stop true)
	(network.broadcast 1 true nil)
)

(fn event-trigger [sender]
  (match sender
    PReset (do
             (_G.computer.beep 10)
             (_G.event.pull 0)
             (_G.computer.reset))
    PStop (if (not stop)
              (emergency-stop)))
  (buttons-update))

(fn event-change-state [sender value]
  (if (and (= sender POnOff) (not stop))
      (do
        (set working value)
        (if value
            (run-all))))
	(network.broadcast 1 false value)
  (buttons-update))

(fn loop [timeout]
  (match (_G.event.pull timeout)
    nil (run-all)
    (:ItemRequest s) (event-item-request s)
    :ItemOutputted (find-set-color PTraffic 0.909 0.819 0.066 0)
    (:Trigger s) (event-trigger s)
    (:ChangeState s v) (event-change-state s v)))

(fn main []
  (buttons-init)
  (run-all)
  (while true
    (loop 20)))

(main)

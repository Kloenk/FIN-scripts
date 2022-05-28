
;;(local card (_G.computer.getPCIDevices findClass("NetworkCard"))[1])
;;(local card (. (computer.getPCIDevices (findClass :NetworkCard)) 1))
(global card nil)

(fn init [?n]
  (global card (. (computer.getPCIDevices (findClass :NetworCard)) (or ?n 1)))
	(if (~= card nil)
  	(event.listen card)
	)
)

(fn open [port]
  "Open port on network card"
	(if (~= card nil)
	  (card:open port)
	)
)

(fn close [port]
  "Close port on card"
	(if (~= card nil)
	  (card:close port)
	)
)

(fn broadcast [port ...]
  "Broadcast message"
	(if (~= card nil)
	  (card:broadcast port ...)
	)
)

(fn deinit []
  "Close all ports and remove card"
  (if (~= card nil)
	  (card:closeAll)
	)
	(global card nil)
)

{: card
 : init
 : open
 : close
 : broadcast
 : deinit
}

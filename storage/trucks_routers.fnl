
(fn run-all-1 []
  (let [ids (_G.component.findComponent :router)]
	  (each [_ router (ipairs ids)]
		  (let [c (_G.component.proxy router)]
			  (print (table.unpack (c:getPortList)))
			)
		)
	)
)

(fn run [config]
  (run-all-1)
)

{: run}

;; helpers
(fn get-default-options [options]
  "Transform to option struct"
  (if (= options nil) {}
      (= (type options) :boolean) {:listen options}
      options))

(macro checkValue [v body ?optional ?msg]
  `(if (= ,v nil)
       ,(if (not ?optional)
            `(_G.computer.panic ,(or ?msg "Value missing")))
       ,body))

(fn get-component [name options]
  "Get one Component proxy by name"
  (let [options (get-default-options options)
        id (. (_G.component.findComponent name) 1)]
    (if (= id nil)
        (if (or (. options :required) (= (. options :required) nil))
            (_G.computer.panic (.. "Cannot find: " name)))
        (let [c (_G.component.proxy id)]
          (if (. options :listen)
              (_G.event.listen c))
          c))))

(fn get-module [panel x y options]
  "Get Module from Panel at xy position"
  (let [options (get-default-options options)]
    (checkValue panel (let [module (panel:getModule x y)]
                        (checkValue module
                                    (if (. options :listen)
                                        (do
                                          (_G.event.listen module)
                                          module)
                                        module))))))

{: get-default-options : get-component : get-module}

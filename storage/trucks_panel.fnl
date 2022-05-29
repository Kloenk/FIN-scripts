; vim: syntax=lisp

(var *panel* nil)
(var *modules* {})

(fn init [name]
  (set *panel* (_G.component.proxy (. (_G.component.findComponent name) 1))))

(fn get-module [pos]
  (*panel*:getModule (table.unpack pos)))

(fn config [config]
  (print config)
  (each [i v (pairs config)]
    (let [(pos listen) (table.unpack v)
          module (get-module pos)]
      (if (= module nil)
          nil
          (do
            (tset *modules* i module)
            (if listen
                (_G.event.listen module)))))))

(fn set-color [module r g b a]
  (let [mod (. *modules* module)]
    (mod:setColor r g b a)))

{: init : config : set-color}

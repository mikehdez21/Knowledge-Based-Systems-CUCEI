;; CUSTOMER BEHAVIOR


;; Cliente inactivo como estatus inicial
(defrule init-customer-behavior
   (customer (customer-id ?id))
   (not (customer-behavior (customer-id ?id)))
   =>
   (assert (customer-behavior 
		(customer-id ?id) 
		(status inactive)
		(total-spent 0.0)
		(total-items 0)
		(preferred-categories))))


;; Gasto total e items por cliente
(defrule compute-spending
  (declare (salience 100))
  ?cb <- (customer-behavior 
            (customer-id ?id) 
            (total-spent ?ts&:(numberp ?ts))
            (total-items ?ti&:(integerp ?ti))
            (status ?status)
            (preferred-categories $?cats))
  (line-item (order-number ?order) (part-number ?pn) (customer-id ?id) (quantity ?q&:(integerp ?q)))
  (product (part-number ?pn) (price ?p&:(numberp ?p)) (category ?cat))
  (not (processed-line-item ?order ?pn))
  =>
  (retract ?cb)
  (bind ?new-ts (+ ?ts (* ?q ?p)))
  (bind ?new-ti (+ ?ti ?q))
  (bind ?new-cats (if (member$ ?cat $?cats) then $?cats else (create$ ?cat $?cats)))
  (assert (customer-behavior 
            (customer-id ?id)
            (total-spent ?new-ts)
            (total-items ?new-ti)
            (status ?status)
            (preferred-categories ?new-cats)))
  (assert (processed-line-item ?order ?pn)))


;; Clasificar comportamiento de consumo
(defrule classify-behavior
  (declare (salience 50))
  ?cb <- (customer-behavior 
            (customer-id ?id) 
            (status ?status)
            (total-spent ?ts)
	    (total-items ?ti)
            (preferred-categories $?cats))
  =>
  (if (< ?ti 1) then
    (bind ?new-status inactive)
  else
    (if (< ?ti 5) then
      (bind ?new-status occasional)
    else
      (if (< ?ti 20) then
        (bind ?new-status frequent)
      else
        (bind ?new-status bulk))))

  ;; Solo actualiza si el status cambió
  (if (neq ?status ?new-status) then
    (retract ?cb)
    (assert (customer-behavior 
              (customer-id ?id)
              (status ?new-status)
	      (total-spent ?ts)
              (total-items ?ti)
              (preferred-categories $?cats)))))


;; Detectar clientes inactivos - Ofrecer descuentos
(defrule reactivation-offer
  (declare (salience 10))
  (customer (customer-id ?id) (name ?name) (phone ?phone))
  (customer-behavior (customer-id ?id) (status inactive))
  (not (recommendation (customer-id ?id) (type reactivation)))
  =>
  (bind ?msg (str-cat ?name " (tel: " ?phone "), ¡te extrañamos! Ten 25% OFF en tu próxima compra."))
  (assert (recommendation (customer-id ?id) (type occasional) (message ?msg)))
  (printout t "🎯 Recomendación: " ?msg crlf))



;; Detectar clientes ocasionales / frecuentes - agredecer cliente
(defrule regrats-buyer
  (customer (customer-id ?id) (name ?name) (phone ?phone))
  (customer-behavior (customer-id ?id) (status occasional))
  (not (recommendation (customer-id ?id) (type occasional)))
  =>
  (bind ?msg (str-cat ?name " (tel: " ?phone "), ¡Muchas gracias por tus compras!"))
  (assert (recommendation (customer-id ?id) (type occasional) (message ?msg)))
  (printout t "🎯 Recomendación: " ?msg crlf))



;; Detectar compradores bulk → upsell
(defrule bulk-buyer-upsell
  (customer (customer-id ?id) (name ?name) (phone ?phone))
  (customer-behavior (customer-id ?id) (status bulk))
  (not (recommendation (customer-id ?id) (type upsell)))
  =>
  (bind ?msg (str-cat ?name " (tel: " ?phone "), ¡Por comprar en volumen, te ofrecemos envío gratis y soporte premium!"))
  (assert (recommendation (customer-id ?id) (type occasional) (message ?msg)))
  (printout t "🎯 Recomendación: " ?msg crlf))


;; Detectar customers que no han comprado
(defrule cust-not-buying
     (customer (customer-id ?id) (name ?name) (phone ?phone))
     (not (order (order-number ?order) (customer-id ?id)))
   =>
   (bind ?msg (str-cat ?name " (tel: " ?phone "), No has realizado ninguna compra aún!"))
  (assert (recommendation (customer-id ?id) (type occasional) (message ?msg)))
  (printout t "🎯 Hola!: " ?msg crlf))






;; REGLAS PREDEFINIDAS




;;Define a rule for finding which products have been bought
(defrule prods-bought
   (order (order-number ?order))
   (line-item (order-number ?order) (part-number ?part))
   (product (part-number ?part) (name ?pn))
   =>
   (printout t ?pn " was bought " crlf))




;;Define a rule for finding which products have been bought AND their quantity
(defrule prods-qty-bgt
   (order (order-number ?order))
   (line-item (order-number ?order) (part-number ?part) (quantity ?q))
   (product (part-number ?part) (name ?p) )
   =>
   (printout t ?q " " ?p " was/were bought " crlf))



;;Define a rule for finding customers and their shopping info
(defrule customer-shopping
   (customer (customer-id ?id) (name ?cn))
   (order (order-number ?order) (customer-id ?id))
   (line-item (order-number ?order) (part-number ?part))
   (product (part-number ?part) (name ?pn))
   =>
   (printout t ?cn " bought  " ?pn crlf))



;;Define a rule for finding those customers who bought more than 5 products
(defrule cust-5-prods
   (customer (customer-id ?id) (name ?cn))
   (order (order-number ?order) (customer-id ?id))
   (line-item (order-number ?order) (part-number ?part) (quantity ?q&:(> ?q 5)))
   (product (part-number ?part) (name ?pn))
   =>
   (printout t ?cn " bought more than 5 products (" ?pn ")" crlf))



;; Define a rule for texting custormers who have not bought ...
(defrule text-cust (customer (customer-id ?cid) (name ?name) (phone ?phone))
                   (not (order (order-number ?order) (customer-id ?cid)))
=>
(assert (text-customer ?name ?phone "tienes 25% desc prox compra"))
(printout t ?name " 3313073905 tienes 25% desc prox compra" crlf))










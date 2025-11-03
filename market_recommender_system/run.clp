;; 1st  type the following function in Jess command prompt for loading data templates  

;; (load load-templates.clp)

;; 2nd  type the following function in Jess command prompt for loading facts into Jess Working Memory  

;; (load load-facts.clp)

;; 3rd  type the following function in Jess command prompt for loading rules ...   

;; (load load-rules.clp)

;; 4th  type the following function in Jess command prompt for displaying current stored facts 
;; in Jess working mem...  

;;CLIPS> (load run.clp)
;;CLIPS> (reset)
;;CLIPS> (run)





;; Cargar sistema
(batch* "templates.clp")
(batch* "facts.clp")
(batch* "rules.clp")

;; Reiniciar y ejecutar
(reset)
(run)

;; Opcional: Mostrar resultados
(defrule show-recommendations
  (declare (salience -10))
  (recommendation (customer-id ?id) (type ?t) (message ?m))
  =>
  (printout t "📩 [RECOMENDACIÓN - " ?t "] " ?m crlf))

(run)


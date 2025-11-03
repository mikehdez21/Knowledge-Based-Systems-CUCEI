;; R1: Regla para Caminar
;; El mono se mueve de PosA a PosB en el suelo, sin la caja.

(defrule caminar-en-suelo
    (declare (salience 20)) ; SALIENCIA BAJA
    ?f <- (estado 
        (mono-posicion ?posA) 
        (mono-altura suelo) 
        (caja-posicion ?cajaPos)
        (tiene-banana no)
    )

    ;; Se asegura de que el mono NO esté donde está la caja.
    (test (neq ?posA ?cajaPos)) 
    
    ;; Nueva posición de destino: debe ser una ubicación conocida.
    (ubicacion (nombre ?posB))
 
    ;; Se asegura de que la posición de destino sea diferente a la actual.
    (test (neq ?posA ?posB))
    
    =>

    (retract ?f)

    ;; Genera el nuevo estado
    (assert (estado 
        (mono-posicion ?posB) 
        (caja-posicion ?cajaPos)
        (mono-altura suelo)
        (tiene-banana no)
    ))

    (printout t "ACCION: El mono camina de " ?posA " a " ?posB crlf)
)


;; R2: Regla para Empujar la Caja (GENERAL)
(defrule empujar-caja
    (declare (salience 40)) ; Reducida, actúa solo si no hay mejores opciones.
    ?f <- (estado 
        (mono-posicion ?posA) 
        (caja-posicion ?posA) 
        (mono-altura suelo) 
        (tiene-banana no)
    )
    (ubicacion (nombre ?posB)) 
    (test (neq ?posA ?posB)) 
    =>
    (retract ?f)
    (assert (estado 
        (mono-posicion ?posB) 
        (caja-posicion ?posB) 
        (mono-altura suelo)
        (tiene-banana no)
    ))
    (printout t "ACCION: El mono empuja la caja de " ?posA " a " ?posB crlf)
)

;; R2.1: Regla de Planificación: EMPUJAR HACIA LA BANANA
(defrule empujar-a-centro-prioritario
    (declare (salience 90)) ; Máxima prioridad de movimiento para llevar la caja a la meta.
    ?f <- (estado 
        (mono-posicion ?posA) 
        (caja-posicion ?posA) ; Mono junto a la caja
        (mono-altura suelo) 
        (tiene-banana no)
    )
    ;; Condición clave: Solo se activa si la caja NO está en el centro.
    (test (neq ?posA centro)) 
    
    =>
    (retract ?f)
    ;; El destino está forzado a ser 'centro'
    (assert (estado 
        (mono-posicion centro) 
        (caja-posicion centro) 
        (mono-altura suelo)
        (tiene-banana no)
    ))
    (printout t "ACCION: El mono PLANIFICA y empuja la caja de " ?posA " a centro" crlf)
)




;; R3: Regla para Subir a la Caja
;; El mono está en la misma posición que la caja y sube a ella.

(defrule subir-a-caja
    (declare (salience 70)) ; SALIENCIA ALTA: Prioridad para subir después de empujar.
    ?f <- (estado 
        (mono-posicion ?cajaPos) 
        (caja-posicion ?cajaPos) 
        (mono-altura suelo)
        (tiene-banana no)
    )

    =>

    (retract ?f)

    ;; Genera el nuevo estado (el mono sube)
    (assert (estado 
        (mono-posicion ?cajaPos) 
        (caja-posicion ?cajaPos) 
        (mono-altura encima)
        (tiene-banana no)
    ))

    (printout t "ACCION: El mono sube a la caja en " ?cajaPos crlf)
)




;; R4: Regla para Agarrar la Banana (META)
;; El mono está encima de la caja y la caja está bajo la banana (en el centro).

(defrule agarrar-banana
    (declare (salience 100)) ; SALIENCIA MÁXIMA: La meta.
    ?f-est <- (estado 
        (mono-posicion centro) 
        (caja-posicion centro) 
        (mono-altura encima)
        (tiene-banana no) ; Debe no tenerla aún
    )

    ?f-obj <- (objetivo (logrado no)) ; Objetivo aún no alcanzado
        
    =>
    
    (retract ?f-est)
    (retract ?f-obj)

    ;; Genera el estado final (¡mono tiene la banana!)
    (assert (estado 
        (mono-posicion centro) 
        (caja-posicion centro) 
        (mono-altura encima)
        (tiene-banana si)
    ))

    (assert (objetivo (logrado si)))
    (printout t "ACCION: ¡El mono AGARRA la BANANA!" crlf)
    (printout t "¡OBJETIVO ALCANZADO!" crlf)
)




;; R5: Regla para Bajar de la Caja
(defrule bajar-de-caja
    (declare (salience 60)) ; SALIENCIA MEDIA: Regla de corrección.
    ?f <- (estado 
        (mono-posicion ?cajaPos) 
        (caja-posicion ?cajaPos) 
        (mono-altura encima)
        (tiene-banana no)
    )
    ;; La condición clave: Bajar si NO está debajo de la banana.
    (test (neq ?cajaPos centro)) 
    
    =>
    
    (retract ?f)
    
    (assert (estado 
        (mono-posicion ?cajaPos) 
        (caja-posicion ?cajaPos) 
        (mono-altura suelo)
        (tiene-banana no)
    ))
    
    (printout t "ACCION: El mono BAJA de la caja para reposicionarla." crlf)
)
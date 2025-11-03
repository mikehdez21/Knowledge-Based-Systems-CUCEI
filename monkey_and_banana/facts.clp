(deffacts estado-inicial
    ; Hecho que define el estado de inicio:
    ; Mono en la puerta, caja en la ventana, mono en el suelo, sin banana.
    (estado 
        (mono-posicion puerta)
        (caja-posicion ventana)
        (mono-altura suelo)
        (tiene-banana no)
    )

    ; Definición de ubicaciones posibles para usar en las reglas:
    (ubicacion (nombre puerta))
    (ubicacion (nombre ventana))
    (ubicacion (nombre centro))
    
    ; La banana está colgada en el centro.
    (posicion-banana centro)
    
    ; Objetivo del sistema.
    (objetivo (logrado no))
)
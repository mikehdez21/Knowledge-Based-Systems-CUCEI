(deftemplate estado
   (slot mono-posicion (default puerta))
   (slot caja-posicion (default ventana))
   (slot mono-altura (default suelo)) ; suelo o encima
   (slot tiene-banana (default no))   ; si o no
)

(deftemplate objetivo
    (slot logrado (default no)) ; si o no
)

(deftemplate ubicacion
    (slot nombre)
)
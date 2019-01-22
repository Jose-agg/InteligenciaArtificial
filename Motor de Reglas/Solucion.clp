(deftemplate puerta
	(slot origen)
	(slot destino)
)

(deftemplate objeto
	(slot nombre)
	(slot sala)
	(slot altura)
	(slot lugar)
)

(deftemplate mono
	(slot sala)
	(slot encima-de)
	(slot sostiene)
	(slot hambre)
	(slot ultima)
)

(deffacts base-hechos
	(puerta (origen comienzo) (destino sala1))
	(puerta (origen sala1) (destino sala2))
	(puerta (origen sala2) (destino sala3))
	(puerta (origen sala3) (destino sala4))

	(mono (sala comienzo) (encima-de suelo) (sostiene nada) (hambre si) (ultima nada))
	(objeto (nombre mesa) (sala sala4) (lugar centro))
	(objeto (nombre banana) (sala sala4) (lugar fondo) (altura techo))
)

; Crear puertas simetricas en función de las que ya hay
(defrule puertas-simetricas
	(declare (salience 10))
	(puerta (origen ?o) (destino ?d))
	=>
	(assert (puerta (destino ?o) (origen ?d)))
)

; Mover al mono por las salas
(defrule ir-de-a
	(declare (salience -5))
	?lm <- (mono (sala ?origen) (encima-de suelo) (sostiene ?x) (hambre si) (ultima  ?anterior))
	(puerta (origen ?origen) (destino ?destino))
	(test (neq ?anterior ?destino))
	=> 

	(assert (mono (sala ?destino) (encima-de suelo) (sostiene ?x) (hambre si) (ultima ?origen)))
   	(retract ?lm)
   	(printout t "Mover de " ?origen " a " ?destino crlf)
)

; Mover la mesa debajo de las bananas
(defrule moverMesa 
	(mono (sala ?sala) (encima-de suelo) (sostiene nada))
	?lc <- (objeto (nombre mesa) (sala ?sala) (lugar ?x))
	(objeto (nombre banana) (sala ?sala) (lugar ?y) (altura techo))
	(test (neq ?x ?y))
	=> 

	(assert (objeto (nombre mesa) (sala ?sala) (lugar ?y)))
	(retract ?lc)
	(printout t "Mueve mesa en " ?sala " de " ?x " a " ?y crlf)
)

; Subir el mono a la mesa
(defrule subir-mesa
	?lm <- (mono (sala ?sala) (encima-de suelo) (sostiene nada) (hambre si))
	(objeto (nombre mesa) (sala ?sala) (lugar ?x))
	(objeto (nombre banana) (sala ?sala) (lugar ?x) (altura techo))
	=> 
	
	(assert (mono (sala ?sala) (encima-de mesa) (sostiene nada) (hambre si)))
	(retract ?lm)
	(printout t "En " ?sala " sube a la mesa que esta en el " ?x crlf)
)

; Bajar el mono de la mesa
(defrule bajar-mesa
	?lm <- (mono (sala ?sala) (encima-de mesa) (sostiene banana) (hambre si))
	(objeto (nombre mesa) (sala ?sala))
	=> 
	
	(assert (mono (sala ?sala) (encima-de suelo) (sostiene banana) (hambre si) (ultima nada)))
	(retract ?lm)
	(printout t "En " ?sala " baja de la mesa" crlf)
)

; Mandar al mono coger las bananas del techo
(defrule coger-banana-techo
	?lm <- (mono (sala ?sala) (encima-de mesa) (sostiene nada) (hambre si))
	(objeto (nombre banana) (sala ?sala) (altura techo))
	=> 

	(assert (mono (sala ?sala) (encima-de mesa) (sostiene banana) (hambre si)))
	(retract ?lm)
	(printout t "En " ?sala " coge la banana" crlf)
)

; Comer banana
(defrule comer-banana
	?lm <- (mono (sala comienzo) (encima-de suelo) (sostiene banana) (hambre si))
	=> 
	
	(assert (mono (sala comienzo) (encima-de suelo) (sostiene nada) (hambre no)))
	(retract ?lm)
	(printout t "Come la banana en comienzo" crlf)
)

; salience 10 para la prioridad a la hora de crear puertas_simetricas
; usar logical para desmarcar las salas una vez se coja la banana

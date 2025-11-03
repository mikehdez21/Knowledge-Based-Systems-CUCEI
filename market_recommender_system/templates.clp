

(deftemplate customer
  (slot customer-id)
  (multislot name)
  (multislot address)
  (slot phone)
)

(deftemplate product
  (slot part-number)
  (slot name)
  (slot category)
  (slot price)
)

(deftemplate order
  (slot order-number)
  (slot customer-id)
)

(deftemplate line-item
  (slot order-number)
  (slot part-number)
  (slot customer-id)
  (slot quantity (type INTEGER) (default 1))
)

;; Hechos para razonamiento

(deftemplate customer-behavior
   (slot customer-id (type INTEGER))
   (slot status (default inactive))
   (slot total-spent (type FLOAT) (default 0.0))
   (slot total-items (type INTEGER) (default 0))
   (multislot preferred-categories)
)

(deftemplate recommendation
   (slot customer-id)
   (slot type)
   (slot message)
)



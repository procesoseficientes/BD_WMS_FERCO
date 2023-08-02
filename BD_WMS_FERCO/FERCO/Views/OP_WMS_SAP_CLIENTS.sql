
-- Modificacion 14-Jul-17 @ TeamOmikron Nexus@AgeOfEmpires
-- eder.chamale
-- Tunning, el campo CardCode es por defecto NOT NULL, al quitar la validación de
-- distinto de NULL, el optimizador utiliza un INDEX SEEK automáticamentel. Dado que este campo
-- siempre tiene un valor true, entonces la otra condición se anulaba automáticamente.

CREATE VIEW FERCO.OP_WMS_SAP_CLIENTS
AS
SELECT
  '' CardCode
 ,'' CardName
 ,'' CardType

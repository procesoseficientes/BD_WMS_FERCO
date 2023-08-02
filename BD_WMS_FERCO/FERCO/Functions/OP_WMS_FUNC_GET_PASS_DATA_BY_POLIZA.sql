﻿


CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_PASS_DATA_BY_POLIZA]
(	
	@pPASS_ID VARCHAR(25)
)
RETURNS TABLE 
AS
RETURN 
(
	select 
		MAX(GETDATE())		FECHA, 
		a.CARRIER			AS TRANSPORTISTA, 
		a.CLIENT_NAME		EMPRESA,
		a.PASS_ID			RETIRO,
		a.VEHICLE_DRIVER	CONDUCTOR,
		a.VEHICLE_ID		TIPO_VEHICULO,
		a.VEHICLE_PLATE		PLACAS,
		a.DRIVER_ID			LICENCIA,
		a.HANDLER			ENTREGADO_POR, 
		max(a.TXT)			OBSERVACIONES, 
		0 CARGA
	from 
		FERCO.OP_WMS3PL_PASSES a
			LEFT OUTER JOIN
		FERCO.OP_WMS3PL_POLIZA_X_PASS	b
	ON
		a.PASS_ID = b.PASS_ID 
	where 
		a.pass_id = @pPASS_ID
	group by 
		a.CARRIER, 
		a.CLIENT_NAME,
		a.PASS_ID,
		a.VEHICLE_DRIVER,
		a.VEHICLE_ID,
		a.VEHICLE_PLATE,
		a.DRIVER_ID, 
		a.CARRIER, 
		a.HANDLER, 
		a.AUTORIZED_BY
)









-- =============================================
-- Autor:				Elder Lucas
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que actualiza las respuesta de error de SAP en los picking

/*
-- Ejemplo de Ejecucion:
	
	

*/
-- =============================================  
CREATE PROCEDURE [FERCO].[OP_WMS_SP_MARK_PICKING_WHIT_ERROR]
(
    @DOC_ENTRY INT,
	@SAP_ERROR VARCHAR(MAX),
	@LOGIN_ID VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;
    --
    BEGIN TRY
	DECLARE	 @RESULT INT
			,@MESSAGE VARCHAR(50)
	-----------------------------------------------------------------------------

        IF EXISTS (SELECT TOP 1 1 FROM FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER WHERE DOC_ENTRY = @DOC_ENTRY AND POSTED_ERP IS NULL)
		BEGIN
			UPDATE FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER SET
				POSTED_RESPONSE = 'No se ha podido cerrar la nota preliminar de entrega: ' + @SAP_ERROR,
				LAST_UPDATE = GETDATE(),
				LAST_UPDATE_BY = @LOGIN_ID
			WHERE DOC_ENTRY = @DOC_ENTRY
				
			SELECT	 @RESULT =1
					,@MESSAGE = 'Proceso Exitoso'
		END
		ELSE
		BEGIN
			SELECT @RESULT = -1
					,@MESSAGE = 'No se ha encontrado la Ola de picking o ya ha sido enviada al ERP'
		END

		SELECT
            @RESULT AS [Resultado]
           ,@MESSAGE AS [Mensaje]
           ,0 [Codigo]
           ,'0' [DbData];

    END TRY
    BEGIN CATCH
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@ERROR [Codigo];
    END CATCH;

END;

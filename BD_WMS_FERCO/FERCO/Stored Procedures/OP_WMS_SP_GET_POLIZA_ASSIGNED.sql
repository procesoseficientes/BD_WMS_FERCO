
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_POLIZA_ASSIGNED @Operador VARCHAR(25),
@PolizaOpcion VARCHAR(25),
@REGIMEN VARCHAR(20),
@pResult VARCHAR(250) OUTPUT

AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Documento NUMERIC(18, 0);
  DECLARE @CODIGOPOLIZA VARCHAR(20);

  BEGIN TRAN
  BEGIN

    IF @REGIMEN = ''
    BEGIN
      SELECT
        @Documento = ISNULL(MAX(DOC_ID), 0)
      FROM [FERCO].OP_WMS_POLIZA_HEADER
      --WHERE POLIZA_ASSIGNEDTO = @Operador				
      WHERE TIPO = @PolizaOpcion
    END
    ELSE
    BEGIN
      SELECT
        @Documento = ISNULL(MAX(DOC_ID), 0)
      FROM [FERCO].OP_WMS_POLIZA_HEADER
      WHERE POLIZA_ASSIGNEDTO = @Operador
      AND WAREHOUSE_REGIMEN = @REGIMEN
      AND TIPO = @PolizaOpcion
    END

    SELECT
      @CODIGOPOLIZA = CODIGO_POLIZA
    FROM [FERCO].OP_WMS_POLIZA_HEADER
    WHERE DOC_ID = @Documento

    --SELECT @Regimen = WAREHOUSE_REGIMEN
    --FROM [FERCO].OP_WMS_POLIZA_HEADER
    --WHERE DOC_ID = @Documento

    --SELECT @TIPO = TIPO
    --FROM [FERCO].OP_WMS_POLIZA_HEADER
    --WHERE DOC_ID = @Documento

    --IF @Documento <> 0 BEGIN				
    --	if @PolizaOpcion = 'MMI_AUDIT_DISPATCH_FISCAL' BEGIN
    --		if (select COUNT(*)
    --			from [FERCO].OP_WMS_TASK_LIST
    --				where CODIGO_POLIZA_TARGET = @Documento
    --				AND IS_COMPLETED = 0) <> 0 BEGIN
    --				SELECT @Documento = 0
    --			END
    --		END
    --END
    SELECT
      @Documento
     ,@CODIGOPOLIZA
  END
  IF @@error = 0
  BEGIN
    SELECT
      @pResult = 'OK'
    COMMIT TRAN
  END
  ELSE
  BEGIN
    ROLLBACK TRAN
    SELECT
      @pResult = ERROR_MESSAGE()
  END

END

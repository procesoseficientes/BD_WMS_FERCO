
/****** 
exec [FERCO].[OP_WMS_SP_INSERT_OP_WMS_POLIZA_DETAIL]
	     @SKU_DESCRIPTION ='Uno'
		,@CUSTOMER ='1'
		,@CUSTOMER_NAME ='Uno'
		,@USER ='Uno'
		,@QTY= '1'
		,@UNIT_MEASURE= 'Uno'
		,@TOTAL = '1'
		,@HEADER = '1' 
 ******/
CREATE PROCEDURE FERCO.OP_WMS_SP_INSERT_OP_WMS_POLIZA_DETAIL @SKU_DESCRIPTION VARCHAR(50)
, @CUSTOMER VARCHAR(MAX)
, @CUSTOMER_NAME VARCHAR(MAX)
, @USER VARCHAR(50)
, @QTY INT
, @UNIT_MEASURE VARCHAR(50) = ''
, @TOTAL FLOAT = 0
, @UNIT_PRICE FLOAT = 0
, @HEADER INT
, @LINE INT
, @fecha DATE


AS
  DECLARE @NumeroPoliza VARCHAR(20)
  --,@fecha date= getdate() 

  SET @NumeroPoliza = (SELECT
      FORMAT(@fecha, 'ddMMyyyy') AS NumeroPoliza);

  DECLARE @Valor_Actual AS NUMERIC(18, 2) = 0
         ,@Valor_Nuevo AS NUMERIC(18, 2) = 0
         ,@Valor_PROMEDIO AS NUMERIC(18, 2) = 0
  SELECT TOP 1
    @Valor_Actual = CUSTOMS_AMOUNT
  FROM [FERCO].[OP_WMS_POLIZA_DETAIL]
  WHERE SKU_DESCRIPTION = @SKU_DESCRIPTION

  IF (@TOTAL < @UNIT_PRICE)
  BEGIN
    SET @Valor_Nuevo = @TOTAL
  END
  ELSE
    SET @Valor_Nuevo = @UNIT_PRICE


  IF (@Valor_Actual > 0)
  BEGIN
    SET @Valor_PROMEDIO = (@Valor_Actual + @Valor_Nuevo) / 2
  END
  ELSE
    SET @Valor_PROMEDIO = @Valor_Nuevo


  BEGIN TRY

    INSERT INTO [FERCO].[OP_WMS_POLIZA_DETAIL] ([DOC_ID]
    , [LINE_NUMBER]
    , [SKU_DESCRIPTION]
    , [SAC_CODE]
    , [BULTOS]
    , [CLASE]
    , [NET_WEIGTH]
    , [WEIGTH_UNIT]
    , [QTY]
    , [CUSTOMS_AMOUNT]
    , [QTY_UNIT]
    , [VOLUME]
    , [VOLUME_UNIT]
    , [LAST_UPDATED_BY]
    , [LAST_UPDATED]
    , [ORIGIN_DOC_ID]
    , [CODIGO_POLIZA_ORIGEN]
    , [CLIENT_CODE]
    , [ORIGIN_LINE_NUMBER]
    , [PICKING_STATUS]
    , [DAI]
    , [IVA]
    , [MISC_TAXES])
      VALUES (@HEADER, @LINE, @SKU_DESCRIPTION, '0', @QTY, '10', '0', NULL, @QTY, @Valor_PROMEDIO, @UNIT_MEASURE, '0', '0', @USER, GETDATE(), @NumeroPoliza, @NumeroPoliza, @CUSTOMER, '1', 'COMPLETED', '0', '0', '0');

    IF @@error = 0
    BEGIN
      SELECT
        1 AS Resultado
       ,'Proceso Exitoso' Mensaje --,  0 Codigo, '0' DbData
    END
    ELSE
    BEGIN

      SELECT
        -1 AS Resultado
       ,ERROR_MESSAGE() Mensaje
       ,@@ERROR Codigo
    END

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH

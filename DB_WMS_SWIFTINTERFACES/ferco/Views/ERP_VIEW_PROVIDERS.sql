﻿
CREATE VIEW ferco.ERP_VIEW_PROVIDERS
AS
SELECT
  PROVIDER
 ,CODE_PROVIDER
 ,NAME_PROVIDER
 ,CLASSIFICATION_PROVIDER
 ,CONTACT_PROVIDER
 ,FROM_ERP
 ,NAME_CLASSIFICATION
FROM ferco.SWIFT_ERP_PROVIDERS

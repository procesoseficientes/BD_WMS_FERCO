﻿
CREATE VIEW FERCO.OP_BASC_VIEW_FORMS_FILLED
AS
SELECT
  A.FORM_CODE
 ,A.FORM_NAME
 ,A.QUESTION_GROUP
 ,A.QUESTION_ID
 ,A.QUESTION_PROMPT
 ,B.DOC_ID
 ,B.QUESTION_RESPONSE
 ,B.INPUTED_TIMESTAMP
 ,B.INPUTED_BY
FROM FERCO.OP_BASC_FORMS AS A
INNER JOIN FERCO.OP_BASC_DOCS AS B
  ON A.FORM_CODE = B.FORM_CODE
    AND A.QUESTION_ID = B.QUESTION_ID
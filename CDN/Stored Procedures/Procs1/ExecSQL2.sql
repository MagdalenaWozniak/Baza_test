Create Procedure CDN.ExecSQL2
@Z0 NVARCHAR(255) = '',
@Z1 NVARCHAR(255) = '',
@Z2 NVARCHAR(255) = '',
@Z3 NVARCHAR(255) = '',
@Z4 NVARCHAR(255) = '',
@Z5 NVARCHAR(255) = '',
@Z6 NVARCHAR(255) = '',
@Z7 NVARCHAR(255) = '',
@Z8 NVARCHAR(255) = '',
@Z9 NVARCHAR(255) = ''
As
Declare @stmt NVarChar(2550)
Set @stmt = IsNull(@Z0,'') + IsNull(@Z1,'') + IsNull(@Z2,'') + IsNull(@Z3,'') + IsNull(@Z4,'') + IsNull(@Z5,'') + IsNull(@Z6,'') + IsNull(@Z7,'') + IsNull(@Z8,'') + IsNull(@Z9,'')
Execute dbo.sp_executesql @stmt

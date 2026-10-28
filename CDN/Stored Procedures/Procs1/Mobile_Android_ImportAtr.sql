CREATE PROCEDURE [CDN].[Mobile_Android_ImportAtr]
           @StanDetalID int ,
           @DAtr_DSAtrId int,
           @DAtr_objectType int,
           @DAtr_objectId int,
           @DAtr_classId int,
           @DAtr_valueId int,
           @DAtr_value nvarchar(max),
           @DAtr_format nvarchar(10),
           @DAtr_valueType int
AS
  SET NOCOUNT ON
if not exists (select* from cdn.DetalAtrybuty where DAtr_DSAtrId = @DAtr_DSAtrId and DAtr_StanDetalID =@StanDetalID )
INSERT INTO CDN.DetalAtrybuty
           (DAtr_OptimaId
           ,DAtr_StanDetalID
           ,DAtr_DSAtrId
           ,DAtr_objectType
           ,DAtr_objectId
           ,DAtr_classId
           ,DAtr_valueId
           ,DAtr_value
           ,DAtr_format
           ,DAtr_valueType)
     VALUES
           (0,
           @StanDetalID,
           @DAtr_DSAtrId,
           @DAtr_objectType,
           @DAtr_objectId,
           @DAtr_classId,
           @DAtr_valueId,
           @DAtr_value,
           @DAtr_format,
           @DAtr_valueType)
  SET NOCOUNT OFF
DECLARE
 @Knt_KntId int
set @Knt_KntId = 0
select  @Knt_KntId = DKnt_OptimaId from cdn.DetalKontrahenci where DKnt_DSKntId =  @DAtr_objectId and DKnt_StanDetalID = @StanDetalID and @DAtr_objectType = 2
if @Knt_KntId > 0
    -- dodajemy nowego
  INSERT INTO CDN.KntAtrybuty
           (KnA_DeAId
           ,KnA_PodmiotTyp
           ,KnA_PodmiotId
           ,KnA_WartoscTxt
           ,KnA_CzyKopiowac
           ,KnA_CzyKod
           ,KnA_CzyPrzenosic
           ,KnA_CzyDrukowac
           ,KnA_CzyKopiowacDoVAT)
     select
           @DAtr_classId
           ,1
           ,@Knt_KntId
           ,@DAtr_value
           ,DeA_CzyKopiowacFA
           ,DeA_CzyKod
           ,DeA_CzyPrzenosic
           ,DeA_CzyDrukowac
           ,DeA_CzyKopiowacDoVAT
           from cdn.DefAtrybuty where DeA_DeAId = @DAtr_classId

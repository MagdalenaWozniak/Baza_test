create  PROCEDURE [CDN].[Mobile_EksportDok]
@ID INT
AS
BEGIN
Declare
 @DateTSSynchr DATETIME,
 @DStaMagId INT,
 @TrN_GIDNumer INT,
 @TrN_DDfId INT,
 @TrN_NumerString NVARCHAR(31),
 @TrN_TrNSeria NVARCHAR(5),
 @TrN_TrNMiesiac tinyint,
 @Seria NVARCHAR(5),
 @Data  Datetime
DECLARE @MM TABLE
        ( TrN_TrNNumer int , TrN_TrNSeria NVARCHAR(5), TrN_GIDTyp smallint, TrN_GIDNumer int , TrN_TrNMiesiac tinyint , TrN_Data datetime ,TrN_Bufor int,TrN_DDfId int,TrN_NumerString NVARCHAR(31))
        UPDATE CDN.DetalStanowiska SET Dsta_TS_Synchro = GetDate() WHERE DSta_DStaID=@ID
 select @Seria = DSta_Seria,@DateTSSynchr = DSta_TS_Synchropotw,@DStaMagId = DSta_MagId FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
insert into @MM
select TrN_NumerNr, '' as TrN_TrNSeria, 1604 as TrN_GIDTyp, trn_trnid as TrN_GIDNumer, '' as TrN_TrNMiesiac, TrN_DataDok as TrN_Data,TrN_Bufor,TrN_DDfId,TrN_NumerString
from cdn.tranag
where trn_magdocid = @DStaMagId and ISNULL(trn_GIDNumer,0) = 0 and TrN_TypDokumentu = 312 and TrN_Bufor = 0/*ostatnia synchronizacja*/
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT TrN_GIDNumer,TrN_DDfId,TrN_NumerString,TrN_Data from @MM
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @TrN_GIDNumer
         ,@TrN_DDfId
         ,@TrN_NumerString
         ,@Data
   IF @@FETCH_STATUS <> 0 BREAK
  select top 1 @TrN_TrNSeria= Seria,@TrN_TrNMiesiac=Miesiac from CDN.RozbijNumer (@TrN_DDfId,@TrN_NumerString)
  if (@TrN_TrNMiesiac = 0)
        set @TrN_TrNMiesiac = MONTH(@Data)
        --update @MM set TrN_TrNSeria = 'mob', TrN_TrNMiesiac = @TrN_TrNMiesiac where TrN_GIDNumer = @TrN_GIDNumer
        update @MM set TrN_TrNSeria = @Seria, TrN_TrNMiesiac = @TrN_TrNMiesiac where TrN_GIDNumer = @TrN_GIDNumer
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
select TrN_TrNNumer, TrN_TrNSeria, TrN_GIDTyp, TrN_GIDNumer, TrN_TrNMiesiac, TrN_Data, TrN_Bufor from @MM
select
 TrE_TrNId as TrE_GIDNumer, TrE_Lp as TrE_GIDLp,TrE_TwrId as TrE_TwrNumer, TrE_WartoscZakupu as TrE_KosztKsiegowy ,tre_ilosc as TrE_Ilosc from @MM
 join cdn.traelem on TrN_GIDNumer = TrE_TrNId
select
 TrE_TrNId as TrS_GIDNumer, TrE_Lp as TrS_GIDLp,trs_ilosc as Trs_Ilosc,@DStaMagId as TrS_MagNumer,TrS_TrSIdDost as TrS_DstNumer, TrS_Wartosc as TrS_KosztKsiegowy from @MM
 join cdn.traelem on TrN_GIDNumer = TrE_TrNId
 join cdn.traselem on TrE_TrEId = TrS_TrEId
 where TrS_Ilosc > 0
END

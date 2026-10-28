CREATE PROCEDURE [CDN].[Mobile_EksportNumeryDok]
@ID INT
AS
BEGIN
DECLARE
          @IDDok INT
         ,@DDfId INT
         ,@NumerString NVARCHAR(31)
         ,@Seria NVARCHAR(5)
         ,@Miesiac NVARCHAR(2)
         ,@Rok   NVARCHAR(4)
declare @numery table (ID INT IDENTITY(1,1),TrN_TrNNumer int, TrN_TrNTyp int, TrN_TrNRok int, TrN_TrNMiesiac int, TrN_TrNSeria int, NumerString NVARCHAR(31),DDfId int)
insert into @numery
select max(DTrN_NumerNR),
max(case when DTrN_TypDokumentu = 308 then 9472 else case when DTrN_TypDokumentu = 302 then 2033 else case when DTrN_TypDokumentu = 312 then 1603 else case when DTrN_TypDokumentu = 305 then 2034 else  0  end end  end end) ,
 '',  '', 1 ,DTrN_NumerString,
max(case when DTrN_TypDokumentu = 308 then DSta_DDfIdRO else case when DTrN_TypDokumentu = 302 then DSta_DDfIdFS else case when DTrN_TypDokumentu = 312 then DSta_DDfIdMM else case when DTrN_TypDokumentu = 305 then DSta_DDfIdPA else 0 end end  end end)
from cdn.detaltranag
join cdn.detalstanowiska on DTrn_StanDetalID = DSta_DStaId
where Dtrn_typdokumentu  in (302,305,308,312) and DSta_Typ = 2 and DSta_DStaId = @ID
group by DTrN_NumerString
union all
select max(DZKB_NumerNR),
max(case when DZKB_TypDokumentu = 1 then 7841 else case when DZKB_TypDokumentu = 2 then 7842 else  0  end  end ) ,
 '',  '', -1 ,DZKB_NumerString ,
max(case when DZKB_TypDokumentu = 1 then DSta_DDfIdKP else case when DZKB_TypDokumentu = 2 then DSta_DDfIdKW else  0  end  end )
from cdn.detalZapisyKB
join cdn.detalstanowiska on DZKB_StanDetalID = DSta_DStaId
where DSta_Typ = 2 and DSta_DStaId = @ID
group by DZKB_NumerString
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT ID,DDfId,NumerString from @numery
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @IDDok
         ,@DDfId
         ,@NumerString
   IF @@FETCH_STATUS <> 0 BREAK
  select top 1 @Miesiac=Miesiac, @Rok = Rok from CDN.RozbijNumer (@DDfId,@NumerString)
        update @numery set TrN_TrNMiesiac = @Miesiac, TrN_TrNRok = @Rok where ID  = @IDDok
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
select TrN_TrNNumer +1 as TrN_TrNNumer,TrN_TrNTyp,  TrN_TrNRok,  TrN_TrNMiesiac, TrN_TrNSeria from @numery
END

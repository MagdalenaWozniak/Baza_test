--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[UstawCentrum] @_PRZELOZONYID int, @_CREATECENTRUM tinyint, @_ADRESWEZLA varchar(128), @_POZIOM int
as
set nocount on
 declare @PRPID int, @PRZELOZONYID int
 declare SUBCENTRA cursor local fast_forward for
  select prp_prcid from cdn.EP_PracownicyPrzelozeni
   where prp_przelozonyid = @_PRZELOZONYID
  open SUBCENTRA
   declare @POZIOM int, @LP int
   set @POZIOM = @_POZIOM
   set @LP = 1
   while (1=1)
   begin
    fetch next from SUBCENTRA into @PRPID
    if @@fetch_status <> 0 break
    declare @PRAKOD varchar(128), @ADRESWEZLA varchar(128), @LISC int, /*@POZIOM int, */@PARENTID int
    --sprawdzenie czy podwładny nie jest już niczyim przełożonym
    if (select isnull(count(prp_prcid),0) from cdn.EP_PracownicyPrzelozeni where prp_przelozonyid = @PRPID) > 0
    begin
     select @PRAKOD = PRA_Kod from cdn.PracKod where PRA_PraId = @PRPID
     set @ADRESWEZLA = CDN.UtworzAdresWezla(@_ADRESWEZLA, @LP)
     set @LISC = right(rtrim(@ADRESWEZLA), 3)
     select @LP = @LISC + 1 --ustawienie @LP odpowiedzialnego za kolejne rekordy na tym samym poziomie
     select @LP, @POZIOM
     select @PARENTID = CNT_CntId, @POZIOM = CNT_Poziom from cdn.Centra join cdn.CentraKierownicy on CNT_CntId = CNK_CntId where CNK_PraId = @_PRZELOZONYID
     execute cdn.DodajCentrum @PRPID, @ADRESWEZLA, @POZIOM, @LISC, @PARENTID
     execute cdn.UstawCentrum @PRPID, 1, @ADRESWEZLA, @POZIOM
    end
    else --ostatni w hierarchii nie tworzy centrum, tylko jest przyporządkowywany do centrum swojego bezpośredniego przełożonego
    begin
     select @PARENTID = CNT_CntId, @ADRESWEZLA = CNT_AdresWezla from cdn.Centra join cdn.CentraKierownicy on CNT_CntId = CNK_CntId where CNK_PraId = @_PRZELOZONYID
     update cdn.PracEtaty set PRE_CntId = @PARENTID, PRE_AdresCentrum = @ADRESWEZLA where PRE_PraId = @PRPID
     update cdn.Pracidx set PRI_CntId = @PARENTID, PRI_AdresCentrum = @ADRESWEZLA where PRI_PraId = @PRPID
    end
   end
  close SUBCENTRA
 deallocate SUBCENTRA
set nocount off
--go

--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[PrzepiszStrukturePodleglosciowa]
as
set nocount on
 declare @PPLID int, @PRZELOZONYID int
 declare CENTRA cursor local fast_forward for
  select MAX(ppl_prcid) from cdn.EP_PracownicyPrzelozeniLinki
   where ppl_prcid > 0 and
    not exists (select PrP_PrcId from cdn.EP_PracownicyPrzelozeni where PrP_PrcId = PPL_PrcId)
   group by ppl_prcid having MAX(ppl_przelozonyid) is null
   /*select MAX(ppl_prcid) from cdn.EP_PracownicyPrzelozeniLinki
   where ppl_prcid > 0 and
    not exists (select PrP_PrcId from cdn.EP_PracownicyPrzelozeni where PrP_PrcId = PPL_PrcId)
   group by ppl_prcid having MAX(ppl_przelozonyid) is null      */
  --kursor po nadrzędnych kierownikach (nie będących niczyimi podwładnymi)
  open CENTRA
   declare @PRAKOD varchar(128), @ADRESWEZLA varchar(128), @LISC int, @POZIOM int, @LP int, @ADRESWEZLAFIRMA varchar(128)
   --inicjalizacja pierwszego rekordu na podstawie FIRMA
   select @ADRESWEZLA = CNT_AdresWezla, @ADRESWEZLAFIRMA = CNT_AdresWezla, @LISC = CNT_Lisc, @POZIOM = CNT_Poziom from cdn.Centra where CNT_CntId = 3
   set @LP = 1
   while (1=1)
   begin
    fetch next from CENTRA into @PPLID
    if @@fetch_status <> 0 break
    set @ADRESWEZLA = CDN.UtworzAdresWezla(@ADRESWEZLAFIRMA, @LP) --ustalam nowy adres węzła zawsze o poziom niżej niż FIRMA
    set @LISC = right(rtrim(@ADRESWEZLA), 3) --ustawienie liścia na podstawie nowego adresu węzła
    select @LP = @LISC + 1 --ustawienie @LP odpowiedzialnego za kolejne rekordy na tym samym poziomie
    set @POZIOM = 1
    execute cdn.DodajCentrum @PPLID, @ADRESWEZLA, @POZIOM, @LISC, 3 --dodawanie rekordu do tabel
    set @POZIOM = @POZIOM + 1
    execute cdn.UstawCentrum @PPLID, 1, @ADRESWEZLA, @POZIOM --przejście na niższe poziomy struktury
   end
  close CENTRA
 deallocate CENTRA
set nocount off

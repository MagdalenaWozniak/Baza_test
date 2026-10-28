CREATE   PROCEDURE CDN.KRo_KasujRozliczenie
@KRoID  int,
@OObId  int,
@UsuwanieRoznicKursowych int
AS
  SET NOCOUNT ON
 declare @BufferKRoID   int
 declare @BufferRozliczenieID int
 declare @DeEID     int
 declare @BOEID     int
 declare @DscDeEID    int
 declare @DscBOEID    int
 declare @Strona     int
 declare @rozliczenieID         int
    declare @Kwota                  decimal(15,2)
    declare @KwotaWal               decimal(15,2)
 select         @DeEID   = KRo_DeEID,
     @BOEID   = KRo_BOEID,
     @Strona   = KRo_Strona,
     @rozliczenieID = KRo_RozliczenieID,
                    @Kwota          = KRo_Kwota,
                    @KwotaWal       = KRo_KwotaWal
 from CDN.KsiRozrachunki
 where KRo_KRoID = @KRoID
    if exists   (
                 select * from CDN.KsiRozrachunki
                 where
                 (KRo_KRoID=@KRoID or KRo_RozliczenieID=@KRoID)
                 and  exists( select * from CDN.KsiDokElem join CDN.KsiDokNag on (KDE_KDNID = KDN_KDNID)
                                    where
            KDN_Bufor <> -1 and KDN_Typ = 113 and KDE_KRoID = KRo_KRoID
                                    or
                                    KDN_Typ in (-1,-1) and (KDE_DeEID = KRo_DeEID or KDE_BoEID = KRo_BoEID)
           )
                )
    begin
        exec CDN.RiseOptimaException 32525
  if @@TranCount<>0 ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
    end
 set @BufferKRoID   = @KRoID
 set @BufferRozliczenieID = @rozliczenieID
  declare @zmiana int = 0;
 BEGIN TRANSACTION
 --SELECT * FROM cdn.ksirozrachunki WITH (UPDLOCK)
 exec CDN.KRo_LockKsiRozrachunkiByKRoId @KRoID
 if @DeEID is not NULL
 begin
  if exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is NULL) and KRo_DeEID = @DeEID and KRo_Strona = @Strona )
  and exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is not NULL) and KRo_DeEID = @DeEID and KRo_Strona = @Strona )
  begin
   delete from CDN.KsiRozrachunki where KRo_KRoID = @KRoID
   exec CDN.KRo_RejestrOperacjiDodaj @DeEID, 1, 125, 0;
  end
  else
  begin
   set @zmiana = 0;
   if not exists(select * from cdn.KsiRozrachunki where KRo_RozliczenieID is NULL and KRo_KRoID = @KRoID)
    set @zmiana = 1;
   update CDN.KsiRozrachunki set   KRo_Kwota = 0,
                                            KRo_KwotaWal = 0,
                                            KRo_RozliczenieID = NULL,
                                            KRo_DataRozliczenia=NULL,
                                            KRo_DataRoz = NULL,
                                            KRo_BRKID = NULL
                                            where KRo_KRoID = @KRoID
  end
  if @zmiana<> 0
   exec CDN.KRo_RejestrOperacjiDodaj @DeEID, 1, 125, 0;
 end
 else
 if @BOEID is not NULL
 begin
  if  exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is NULL) and KRo_BOEID = @BOEID and KRo_Strona = @Strona )
  and exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is not NULL) and KRo_BOEID = @BOEID and KRo_Strona = @Strona )
  begin
   delete from CDN.KsiRozrachunki where KRo_KRoID = @KRoID
   exec CDN.KRo_RejestrOperacjiDodaj @BOEID, 2, 125, 0;
  end
  else
  begin
   set @zmiana = 0;
   if not exists(select * from cdn.KsiRozrachunki where KRo_RozliczenieID is NULL and KRo_KRoID = @KRoID)
    set @zmiana = 1;
   update CDN.KsiRozrachunki set   KRo_Kwota = 0,
           KRo_KwotaWal = 0,
           KRo_RozliczenieID = NULL,
           KRo_DataRozliczenia=NULL,
           KRo_DataRoz = NULL,
           KRo_BRKID = NULL
           where KRo_KRoID = @KRoID
   if @zmiana <> 0
    exec CDN.KRo_RejestrOperacjiDodaj @BOEID, 2, 125, 0;
  end
 end
    -- zmniejszenie sumy rozliczeń o wartość usuwanego rozliczenia cząstkowego
 if @DeEID is not NULL
    begin
        update CDN.KsiRozrachunki set       KRo_SumRozliczen    = KRo_SumRozliczen      - @Kwota,
                                            KRo_SumRozliczenWal = KRo_SumRozliczenWal   - @KwotaWal
        where KRo_DeEID = @DeEID and KRo_Strona = @Strona
    end
 if @BOEID is not NULL
    begin
        update CDN.KsiRozrachunki set       KRo_SumRozliczen    = KRo_SumRozliczen      - @Kwota,
                                            KRo_SumRozliczenWal = KRo_SumRozliczenWal   - @KwotaWal
        where KRo_BOEID = @BOEID and KRo_Strona = @Strona
    end
 if @rozliczenieID is not NULL and exists(select * from CDN.KsiRozrachunki where KRo_KRoID = @rozliczenieID)
 begin
                --update CDN.KsiRozrachunki set KRo_RozliczenieID = NULL where KRo_KRoID = @rozliczenieID
    set @KRoID = @rozliczenieID
    select         @DeEID   = KRo_DeEID,
        @BOEID   = KRo_BOEID,
        @Strona   = KRo_Strona,
        @rozliczenieID = KRo_RozliczenieID,
                                @Kwota          = KRo_Kwota,
                                @KwotaWal       = KRo_KwotaWal
    from CDN.KsiRozrachunki
    where KRo_KRoID = @KRoID
    set @DscDeEID = @DeEID
    set @DscBOEID = @BOEID
    if @DeEID is not NULL
    begin
     if  exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is NULL) and KRo_DeEID = @DeEID and KRo_Strona = @Strona )
     and exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is not NULL) and KRo_DeEID = @DeEID and KRo_Strona = @Strona )
     begin
      delete from CDN.KsiRozrachunki where KRo_KRoID = @KRoID
      exec CDN.KRo_RejestrOperacjiDodaj @DeEID, 1, 125, 0;
     end
     else
     begin
      set @zmiana = 0;
      if not exists(select * from cdn.KsiRozrachunki where KRo_RozliczenieID is NULL and KRo_KRoID = @KRoID)
       set @zmiana = 1;
      update CDN.KsiRozrachunki set   KRo_Kwota = 0,
                                                        KRo_KwotaWal = 0,
                                                        KRo_RozliczenieID = NULL,
                                                        KRo_DataRozliczenia=NULL,
                                                        KRo_DataRoz = NULL,
              KRo_BRKID = NULL
                                                        where KRo_KRoID = @KRoID
      if @zmiana <> 0
       exec CDN.KRo_RejestrOperacjiDodaj @DeEID, 1, 125, 0;
     end
    end
    else
    if @BOEID is not NULL
    begin
     if exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is NULL) and KRo_BOEID = @BOEID and KRo_Strona = @Strona )
     and exists( select * from CDN.KsiRozrachunki where (KRo_RozliczenieID is not NULL) and KRo_BOEID = @BOEID and KRo_Strona = @Strona )
     begin
      delete from CDN.KsiRozrachunki where KRo_KRoID = @KRoID
      exec CDN.KRo_RejestrOperacjiDodaj @BOEID, 2, 125, 0;
     end
     else
     begin
      set @zmiana = 0;
      if not exists(select * from cdn.KsiRozrachunki where KRo_RozliczenieID is NULL and KRo_KRoID = @KRoID)
       set @zmiana = 1;
      update CDN.KsiRozrachunki set   KRo_Kwota = 0,
                                                        KRo_KwotaWal = 0,
                                                        KRo_RozliczenieID = NULL,
                                                        KRo_DataRozliczenia=NULL,
                                                        KRo_DataRoz = NULL,
              KRo_BRKID = NULL
                                                        where KRo_KRoID = @KRoID
      if @zmiana <> 0
       exec CDN.KRo_RejestrOperacjiDodaj @BOEID, 2, 125, 0;
     end
    end
                -- zmniejszenie sumy rozliczeń o wartość usuwanego rozliczenia cząstkowego
             if @DeEID is not NULL
                begin
                    update CDN.KsiRozrachunki set   KRo_SumRozliczen    = KRo_SumRozliczen      - @Kwota,
                                                    KRo_SumRozliczenWal = KRo_SumRozliczenWal   - @KwotaWal
                    where KRo_DeEID = @DeEID and KRo_Strona = @Strona
                end
             if @BOEID is not NULL
                begin
                    update CDN.KsiRozrachunki set   KRo_SumRozliczen    = KRo_SumRozliczen      - @Kwota,
                                                    KRo_SumRozliczenWal = KRo_SumRozliczenWal   - @KwotaWal
                    where KRo_BOEID = @BOEID and KRo_Strona = @Strona
                end
 end
 if exists(select * from cdn.DekretyElem where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferKRoID)
  update cdn.DekretyElem set DeE_DokumentId = null where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferKRoID
 if exists(select * from cdn.DekretyElem where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferRozliczenieID)
  update cdn.DekretyElem set DeE_DokumentId = null where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferRozliczenieID
 if exists(select * from cdn.BnkRozKwoty where BRK_KRoID = @BufferKRoID)
  update cdn.BnkRozKwoty set BRK_KRoID = null where BRK_KRoID = @BufferKRoID
 if exists(select * from cdn.BnkRozKwoty where BRK_KRoID = @BufferRozliczenieID)
  update cdn.BnkRozKwoty set BRK_KRoID = null where BRK_KRoID = @BufferRozliczenieID
 /*
 if exists(select * from cdn.DekretyElem where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferKRoID)
  update cdn.DekretyElem set DeE_DokumentTyp = null, DeE_DokumentId = null where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferKRoID
 if exists(select * from cdn.DekretyElem where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferRozliczenieID)
  update cdn.DekretyElem set DeE_DokumentTyp = null, DeE_DokumentId = null where DeE_DokumentTyp in (44,50) and DeE_DokumentId = @BufferRozliczenieID
 */
 if @@TranCount<>0 COMMIT
  SET NOCOUNT OFF

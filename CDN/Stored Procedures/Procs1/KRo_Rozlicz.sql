CREATE   PROCEDURE CDN.KRo_Rozlicz
@LockResource int,
@SrcKRoID  int,
@DstKRoID  int,
@Kwota    decimal(15,2),
@DateType  int,
@ToDay   DateTime,
@BRKId   int
AS
  SET NOCOUNT ON
 BEGIN TRANSACTION
 if @LockResource <> 0
 begin
  --SELECT * FROM cdn.ksirozrachunki WITH (UPDLOCK)
  exec CDN.KRo_LockKsiRozrachunkiByKRoId @SrcKRoID
  exec CDN.KRo_LockKsiRozrachunkiByKRoId @DstKRoID
 end
 -- ponieważ @SrcKRoID może wskazywać na dowolne rozliczenie w obrębie
 -- 1 dekretu należy wczytać te które w kwocie rozliczenia ma wartość 0.00
    declare         @tempSrcKRoID   int,
                    @tempDstKRoID   int,
                    @SrcStrona      int,
                    @DstStrona      int,
                    @SrcDokTyp      int,
                    @SrcDokID       int,
                    @DstDokTyp      int,
                    @DstDokID       int
    select top 1    @tempSrcKRoID  = IsNull(RDe.KRo_KRoID,  RBO.KRo_KRoID),
                    @SrcStrona  = IsNull(RDe.KRo_Strona, RBO.KRo_Strona),
                    @SrcDokTyp      = A.KRo_Typ,
                    @SrcDokID       = IsNull(RDe.KRo_DeEID,     RBO.KRo_BOEID)
    from
    CDN.KsiRozrachunki A
    left outer join CDN.KsiRozrachunki RDe on (A.KRo_DeEId = RDe.KRo_DeEId and RDe.KRo_Kwota=0.00 and RDe.KRo_KwotaWal=0.00)-- and A.KRo_Strona = RDe.KRo_Strona)
    left outer join CDN.KsiRozrachunki RBO on (A.KRo_BOEId = RBO.KRo_BOEId and RBO.KRo_Kwota=0.00 and RBO.KRo_KwotaWal=0.00)-- and A.KRo_Strona = RBO.KRo_Strona)
    where A.KRo_KRoID = @SrcKRoID
    select top 1    @tempDstKRoID   = IsNull(RDe.KRo_KRoID,  RBO.KRo_KRoID),
                    @DstStrona      = IsNull(RDe.KRo_Strona, RBO.KRo_Strona),
                    @DstDokTyp      = A.KRo_Typ,
                    @DstDokID       = IsNull(RDe.KRo_DeEID,     RBO.KRo_BOEID)
    from
    CDN.KsiRozrachunki A
    left outer join CDN.KsiRozrachunki RDe on (A.KRo_DeEId = RDe.KRo_DeEId and RDe.KRo_Kwota=0.00 and RDe.KRo_KwotaWal=0.00 and A.KRo_Strona = RDe.KRo_Strona)
    left outer join CDN.KsiRozrachunki RBO on (A.KRo_BOEId = RBO.KRo_BOEId and RBO.KRo_Kwota=0.00 and RBO.KRo_KwotaWal=0.00 and A.KRo_Strona = RBO.KRo_Strona)
    where A.KRo_KRoID = @DstKRoID
    -- Jeśli @tempSrcKRoID jest NULL'em to dokument został już rozliczony
    if  @tempSrcKRoID is NULL
    begin
        exec CDN.RiseOptimaException 32515
        if @@TranCount<>0 ROLLBACK TRAN
            SET NOCOUNT OFF
        RETURN
    end
    -- Jeśli @tempDstKRoID jest NULL'em to dokument został już rozliczony
    if  @tempDstKRoID is NULL
    begin
        exec CDN.RiseOptimaException 32515
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    set @SrcKRoID = @tempSrcKRoID
    set @DstKRoID = @tempDstKRoID
    -- Sprawdzenie czy strony dokumentów są przeciwne
    if @SrcStrona = @DstStrona
    begin
        exec CDN.RiseOptimaException 32516
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    -- wczytanie kwot dokumntu rozliczanego , sum kwot rozliczonych
    -- kwoty dokumentu rozliczanego
    declare @KwotaDeEPozostalo      decimal(15,2),
            @KwotaBOEPozostalo      decimal(15,2),
            @KwotaDokumentu         decimal(15,2),
            @KwotaPozostalo         decimal(15,2),
            @KwotaDeEPozostaloWal   decimal(15,2),
            @KwotaBOEPozostaloWal   decimal(15,2),
            @KwotaDokumentuWal      decimal(15,2),
            @KwotaPozostaloWal      decimal(15,2),
            @Waluta                 NVARCHAR(3)
    select          @KwotaDokumentu         = R.KRo_KwotaDok,
                    @KwotaDeEPozostalo      = sum(IsNull(RDe.KRo_Kwota,0.00)),
                    @KwotaBOEPozostalo      = sum(IsNull(RBO.KRo_Kwota,0.00)),
                    @KwotaDokumentuWal      = R.KRo_KwotaDokWal,
                    @KwotaDeEPozostaloWal   = sum(IsNull(RDe.KRo_KwotaWal,0.00)),
                    @KwotaBOEPozostaloWal   = sum(IsNull(RBO.KRo_KwotaWal,0.00)),
                    @Waluta                 = R.KRo_Waluta
    from
    CDN.KsiRozrachunki R
    left outer join CDN.KsiRozrachunki as RDe on (R.KRo_DeEId = RDe.KRo_DeEId and R.KRo_Strona = RDe.KRo_Strona)
    left outer join CDN.KsiRozrachunki as RBO on (R.KRo_BOEId = RBO.KRo_BOEId and R.KRo_Strona = RBO.KRo_Strona)
    where R.KRo_KRoID = @SrcKRoID
    group by R.KRo_Dokument, R.KRo_Konto, R.KRo_KwotaDok, R.KRo_KwotaDokWal, R.KRo_Waluta
    -- Waluta systemowa powinna być oznaczona NULL'em
    if len(IsNull(@Waluta, '')) = 0
    begin
        set @Waluta = NULL
    end
    -- sprawdzenie czy kwota dokumentu nie jest mniejsza od sumu kwot rozliczeń
    -- częściowych + kwota auktualnie podana do rozliczenia
    set @KwotaPozostalo     = @KwotaDokumentu       - (@KwotaDeEPozostalo       + @KwotaBOEPozostalo)
    set @KwotaPozostaloWal  = @KwotaDokumentuWal    - (@KwotaDeEPozostaloWal    + @KwotaBOEPozostaloWal)
    --if @Waluta is NULL and @KwotaPozostalo <= 0.00 or @Waluta is not NULL and @KwotaPozostaloWal <= 0.00
    if @KwotaPozostalo <= 0.00 and @KwotaPozostaloWal <= 0.00
    begin
        exec CDN.RiseOptimaException 32515
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    -- kwoty dokumentu rozliczającego
    declare         @KwotaRoDeEPozostalo    decimal(15,2),
                    @KwotaRoBOEPozostalo    decimal(15,2),
                    @KwotaRoDokumentu       decimal(15,2),
                    @KwotaRoPozostalo       decimal(15,2),
                    @KwotaRoDeEPozostaloWal decimal(15,2),
                    @KwotaRoBOEPozostaloWal decimal(15,2),
                    @KwotaRoDokumentuWal    decimal(15,2),
                    @KwotaRoPozostaloWal    decimal(15,2),
                    @WalutaRo               NVARCHAR(3)
    -- wczytanie kwot dokumntu rozliczającego, sum kwot rozliczonych
    select          @KwotaRoDokumentu       = R.KRo_KwotaDok,
                    @KwotaRoDeEPozostalo    = sum(IsNull(RDe.KRo_Kwota,0.00)),
                    @KwotaRoBOEPozostalo    = sum(IsNull(RBO.KRo_Kwota,0.00)),
                    @KwotaRoDokumentuWal    = R.KRo_KwotaDokWal,
                    @KwotaRoDeEPozostaloWal = sum(IsNull(RDe.KRo_KwotaWal,0.00)),
                    @KwotaRoBOEPozostaloWal = sum(IsNull(RBO.KRo_KwotaWal,0.00)),
                    @WalutaRo               = R.KRo_Waluta
    from
    CDN.KsiRozrachunki R
    left outer join CDN.KsiRozrachunki as RDe on (R.KRo_DeEId = RDe.KRo_DeEId and R.KRo_Strona = RDe.KRo_Strona)
    left outer join CDN.KsiRozrachunki as RBO on (R.KRo_BOEId = RBO.KRo_BOEId and R.KRo_Strona = RBO.KRo_Strona)
    where R.KRo_KRoID = @DstKRoID
    group by R.KRo_Dokument, R.KRo_Konto, R.KRo_KwotaDok, R.KRo_KwotaDokWal, R.KRo_Waluta
    -- Waluta systemowa powinna być oznaczona NULL'em
    if len(IsNull(@WalutaRo, '')) = 0
    begin
        set @WalutaRo = NULL
    end
    -- rozliczamy tylko dokumenty w tych samych walutach
    if IsNull(@Waluta,'') <> IsNull(@WalutaRo,'')
    begin
        exec CDN.RiseOptimaException 32517
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    -- sprawdzenie czy dokumen rozliczający posiada wystarczające środki do rozliczenia
    set @KwotaRoPozostalo       = @KwotaRoDokumentu     - (@KwotaRoDeEPozostalo     + @KwotaRoBOEPozostalo)
    set @KwotaRoPozostaloWal    = @KwotaRoDokumentuWal  - (@KwotaRoDeEPozostaloWal  + @KwotaRoBOEPozostaloWal)
    --if @Waluta is NULL and @KwotaRoPozostalo <= 0.00 or @Waluta is not NULL and @KwotaRoPozostaloWal <= 0.00
    if @KwotaRoPozostalo <= 0.00 and @KwotaRoPozostaloWal <= 0.00
    begin
        exec CDN.RiseOptimaException 32518
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
 if @Waluta is not NULL and @KwotaDokumentuWal <> 0.00 and @KwotaPozostaloWal <= 0.00 and @WalutaRo is not NULL and (@KwotaRoDokumentuWal <> 0.00 or @KwotaRoPozostaloWal <> 0.00)
    begin
        exec CDN.RiseOptimaException 32519
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
 if @WalutaRo is not NULL and @KwotaRoDokumentuWal <> 0.00 and @KwotaRoPozostaloWal <= 0.00 and @Waluta is not NULL and (@KwotaDokumentuWal <> 0.00 or @KwotaPozostaloWal <> 0.00)
    begin
        exec CDN.RiseOptimaException 32520
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    -- ustalenie największej możliwej kwoty która może wziąć udział w rozliczeniu
    declare @KwotaSys   decimal(15,2)
    declare @KwotaRoSys decimal(15,2)
    declare @KwotaWal   decimal(15,2)
    set @KwotaSys   = 0.00
    set @KwotaRoSys = 0.00
    set @KwotaWal   = 0.00
 declare @s1 nvarchar(20);
 declare @s2 nvarchar(20);
 declare @s3 nvarchar(20);
    -- Ustalenie kwoty w walucie systemowej
    -- dla rozliczeń w walucie systemowej
    -- oraz rozliczeń różnicą kursową
    if @Waluta is NULL or (@Waluta is not NULL and (@KwotaDokumentuWal = 0.00 or @KwotaRoDokumentuWal = 0.00))
    begin
        if @KwotaRoPozostalo < @KwotaPozostalo
        begin
         set @KwotaSys   = @KwotaRoPozostalo
            set @KwotaRoSys = @KwotaRoPozostalo
        end
        else
     begin
            set @KwotaSys   = @KwotaPozostalo
            set @KwotaRoSys = @KwotaPozostalo
        end
  -- rozliczenia częściowe w walucie systemowej
  -- rużnice kursowe @Waluta is not NULL and (@KwotaDokumentuWal = 0.00 or @KwotaRoDokumentuWal = 0.00) bez zmian
  if @Waluta is NULL
  begin
   if @Kwota > @KwotaSys or @Kwota > @KwotaRoSys
   begin
    set @s1 = convert(nvarchar, @Kwota);
    set @s2 = convert(nvarchar, @KwotaSys);
    set @s3 = convert(nvarchar, @KwotaRoSys);
    exec CDN.RiseOptimaException 32521, 's1', @s1, 's2', @s2, 's3', @s3
    if @@TranCount<>0 ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   end
   else
   begin
    if IsNull(@Kwota,0) <> 0
    begin
     set @KwotaSys   = @Kwota
     set @KwotaRoSys = @Kwota
    end
   end
  end
    end
    else
    --ustalenie kwoty w walucie obcej
    if @Waluta is not NULL
    begin
        declare @KursL decimal(15,4)
        declare @KursM decimal(5,0)
  declare @KursR decimal(15,4)
        if @KwotaRoPozostaloWal < @KwotaPozostaloWal
        begin
            set @KwotaWal = @KwotaRoPozostaloWal
        end
        else
        begin
            set @KwotaWal = @KwotaPozostaloWal
        end
  -- rozliczenia częściowe w walucie obcej
  -- podstawieni ekwoty z argumentu funkcji, pomijamy różnice kursowe
  if @KwotaDokumentuWal <> 0.00 and @KwotaRoDokumentuWal <> 0.00
  begin
   if @Kwota > @KwotaWal
   begin
    Set @Kwota = @KwotaWal
   end
   else
   begin
    if IsNull(@Kwota,0) <> 0
    begin
     set @KwotaWal = @Kwota
    end
   end
  end
        -- Obsługa różnic kursowych
        if @KwotaPozostaloWal - @KwotaWal = 0.00
        begin
            set @KwotaSys = @KwotaPozostalo
        end
        else
        begin
            -- wczytanie kursów
            if @SrcDokTyp = 1
                select @KursL = DeE_KursL, @KursM = DeE_KursM from CDN.DekretyElem where DeE_DeEID = @SrcDokID
            else
                select @KursL = BOE_KursL, @KursM = BOE_KursM from CDN.BOElem where BoE_BoEID = @SrcDokID
   --if @KursL = 0.0000 or @KursM = 0
   set @KursR = @KursL * @KursM
            if @KursR = 0 or @KursR = 1
            begin
                declare @K  decimal (15,9)
                set @K  = @KwotaDokumentu   / @KwotaDokumentuWal
                set @KwotaSys   = @K  * @KwotaWal
            end
            else
            begin
                set @KwotaSys = @KwotaWal * @KursL / @KursM
            end
        end
        if @KwotaRoPozostaloWal - @KwotaWal = 0.00
        begin
            set @KwotaRoSys = @KwotaRoPozostalo
        end
        else
        begin
            -- wczytanie kursów
            if @DstDokTyp = 1
                select @KursL = DeE_KursL, @KursM = DeE_KursM from CDN.DekretyElem where DeE_DeEID = @DstDokID
            else
             select @KursL = BOE_KursL, @KursM = BOE_KursM from CDN.BOElem where BoE_BoEID = @DstDokID
            --if @KursL = 0.0000 or @KursM = 0
   set @KursR = @KursL * @KursM
            if @KursR = 0 or @KursR = 1
            begin
                declare @KR decimal (15,9)
                set @KR = @KwotaRoDokumentu / @KwotaRODokumentuWal
                set @KwotaRoSys = @KR * @KwotaWal
            end
            else
            begin
                set @KwotaRoSys = @KwotaWal * @KursL / @KursM
            end
        end
        if @KwotaSys < @KwotaRoSys
        begin
            set @KwotaRoSys = @KwotaSys
        end
        else
        begin
            set @KwotaSys = @KwotaRoSys
        end
  if @KwotaRoPozostalo < @KwotaPozostalo
  begin
   if @KwotaRoPozostalo < @KwotaSys
   begin
    set @KwotaSys   = @KwotaRoPozostalo
    set @KwotaRoSys = @KwotaRoPozostalo
   end
  end
  else
  begin
   if @KwotaPozostalo < @KwotaSys
   begin
    set @KwotaSys = @KwotaPozostalo
    set @KwotaRoSys = @KwotaPozostalo
   end
  end
    end
    update CDN.KsiRozrachunki
    set KRo_RozliczenieId = @DstKRoID,
     KRo_Kwota   = @KwotaSys,
        KRo_KwotaWal  = @KwotaWal,
        KRo_DataRozliczenia = GETDATE(),
  KRo_BRKID   = @BRKId
    where
    KRo_KRoId = @SrcKRoID
    update CDN.KsiRozrachunki
    set KRo_RozliczenieId  = @SrcKRoID,
  KRo_Kwota    = @KwotaRoSys,
        KRo_KwotaWal   = @KwotaWal,
        KRo_DataRozliczenia  = GETDATE(),
  KRo_BRKID    = @BRKId
    where
    KRo_KRoId = @DstKRoID
    exec CDN.KRo_RejestrOperacjiDodaj 0, 0, 117, @SrcKRoID;
    exec CDN.KRo_RejestrOperacjiDodaj 0, 0, 117, @DstKRoID;
    -- ustalenie daty rozliczenie, jako późniejszą datę z dokumentów biorących udział w rozliczeniu
    -- rodzaj daty odczytujemy z konfiguracji
    -- KRo_DataRoz = Dok1.Data > Dok2.Data
    exec CDN.KRo_UstawDateRozrachunku @SrcKRoID, @DstKRoID,  @DateType, @ToDay
    -- jeśli podana kwota rozliczenia nie rozliczyła całkowicie dokumentu
    -- dodaje pozycję z kwotą nierozliczoną
    set @KwotaPozostalo     =  @KwotaDokumentu      - ( @KwotaSys + @KwotaDeEPozostalo      + @KwotaBOEPozostalo    )
    set @KwotaPozostaloWal  =  @KwotaDokumentuWal   - ( @KwotaWal + @KwotaDeEPozostaloWal   + @KwotaBOEPozostaloWal )
    if @KwotaPozostalo > 0.00 or @KwotaPozostaloWal > 0.00
    begin
        insert into CDN.KsiRozrachunki (KRo_OObId, KRo_Dziennik, KRo_NumerDziennika, KRo_Typ, KRo_DataDokumentu, KRo_DataOperacji, KRo_TerminPlatnosci, KRo_Dokument, KRo_Waluta, KRo_KwotaDok, KRo_Kwota, KRo_SumRozliczen, KRo_KwotaDokWal, KRo_KwotaWal, KRo_SumRozliczenWal, KRo_Konto, KRo_KontoIdx, KRo_DeEId, KRo_BOEId, KRo_Opis, KRo_Strona, KRo_NrDziennika, KRo_NrKsiegi, KRo_IdentKsieg, KRo_Storno, KRo_Bufor, KRo_KontoPrzeciw)
        select KRo_OObId, KRo_Dziennik, KRo_NumerDziennika, KRo_Typ, KRo_DataDokumentu, KRo_DataOperacji, KRo_TerminPlatnosci, KRo_Dokument, KRo_Waluta, KRo_KwotaDok, 0.00, KRo_SumRozliczen, KRo_KwotaDokWal, 0.00, KRo_SumRozliczenWal, KRo_Konto, KRo_KontoIdx, KRo_DeEId, KRo_BOEId, KRo_Opis, KRo_Strona, KRo_NrDziennika, KRo_NrKsiegi, KRo_IdentKsieg, KRo_Storno, KRo_Bufor, KRo_KontoPrzeciw
        from CDN.KsiRozrachunki
        where
        KRo_KRoId = @SrcKRoID
    end
    else
    if @KwotaPozostalo < 0.00 or @KwotaPozostaloWal < 0.00
    begin
        exec CDN.RiseOptimaException 32522
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    -- jeżeli @kwota rozliczenia jest mniejsza od kwoty dokumentu rozliczającego
    -- dodaje pozycję z pozostałą kwotą
    set @KwotaRoPozostalo       =  @KwotaRoDokumentu    - ( @KwotaRoSys + @KwotaRoDeEPozostalo    + @KwotaRoBOEPozostalo      )
    set @KwotaRoPozostaloWal    =  @KwotaRoDokumentuWal - ( @KwotaWal   + @KwotaRoDeEPozostaloWal + @KwotaRoBOEPozostaloWal   )
    if @KwotaRoPozostalo > 0.00 or @KwotaRoPozostaloWal > 0.00
    begin
        insert into CDN.KsiRozrachunki (KRo_OObId, KRo_Dziennik, KRo_NumerDziennika, KRo_Typ, KRo_DataDokumentu, KRo_DataOperacji, KRo_TerminPlatnosci, KRo_Dokument, KRo_Waluta, KRo_KwotaDok, KRo_Kwota, KRo_SumRozliczen, KRo_KwotaDokWal, KRo_KwotaWal, KRo_SumRozliczenWal, KRo_Konto, KRo_KontoIdx, KRo_DeEId, KRo_BOEId, KRo_Opis, KRo_Strona, KRo_NrDziennika, KRo_NrKsiegi, KRo_IdentKsieg, KRo_Storno, KRo_Bufor, KRo_KontoPrzeciw)
        select KRo_OObId, KRo_Dziennik, KRo_NumerDziennika, KRo_Typ, KRo_DataDokumentu, KRo_DataOperacji, KRo_TerminPlatnosci, KRo_Dokument, KRo_Waluta, KRo_KwotaDok, 0.00, KRo_SumRozliczen, KRo_KwotaDokWal, 0.00, KRo_SumRozliczenWal, KRo_Konto, KRo_KontoIdx, KRo_DeEId, KRo_BOEId, KRo_Opis, KRo_Strona, KRo_NrDziennika, KRo_NrKsiegi, KRo_IdentKsieg, KRo_Storno, KRo_Bufor, KRo_KontoPrzeciw
        from CDN.KsiRozrachunki
        where
        KRo_KRoId = @DstKRoID
    end
    else
    if @KwotaRoPozostalo < 0.00 or @KwotaRoPozostaloWal < 0.00
    begin
        exec CDN.RiseOptimaException 32523
        if @@TranCount<>0 ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    end
    -- update sum dokumentu rozliczanego
    if      @SrcDokTyp = 1
    begin
        update CDN.KsiRozrachunki Set   KRo_SumRozliczen    = IsNull(KRo_SumRozliczen,      0.00) + @KwotaSys,
                                        KRo_SumRozliczenWal = IsNull(KRo_SumRozliczenWal,   0.00) + @KwotaWal
        where KRo_DeEID = @SrcDokID and KRo_Strona = @SrcStrona
    end
    else if @SrcDokTyp = 2
    begin
        update CDN.KsiRozrachunki Set   KRo_SumRozliczen    = IsNull(KRo_SumRozliczen,      0.00) + @KwotaSys,
                                        KRo_SumRozliczenWal = IsNull(KRo_SumRozliczenWal,   0.00) + @KwotaWal
        where KRo_BOEID = @SrcDokID and KRo_Strona = @SrcStrona
    end
    -- update sum dokumentu rozliczającego
    if      @DstDokTyp = 1
    begin
        update CDN.KsiRozrachunki Set   KRo_SumRozliczen    = IsNull(KRo_SumRozliczen,      0.00) + @KwotaRoSys,
                                        KRo_SumRozliczenWal = IsNull(KRo_SumRozliczenWal,   0.00) + @KwotaWal
        where KRo_DeEID = @DstDokID and KRo_Strona = @DstStrona
    end
    else if @DstDokTyp = 2
    begin
        update CDN.KsiRozrachunki Set   KRo_SumRozliczen    = IsNull(KRo_SumRozliczen,      0.00) + @KwotaRoSys,
                                        KRo_SumRozliczenWal = IsNull(KRo_SumRozliczenWal,   0.00) + @KwotaWal
        where KRo_BOEID = @DstDokID and KRo_Strona = @DstStrona
    end
    if @@TranCount<>0 COMMIT
    SET NOCOUNT OFF
 select
  Dokument.KRo_KRoId as Dok_KRoId,
  Dokument.KRo_DataRozliczenia as Dok_DataRozliczenia,
  Dokument.KRo_DataRoz as Dok_DataRoz,
  Dokument.KRo_KwotaDok as Dok_KwotaDok,
  Dokument.KRo_KwotaDokWal as Dok_KwotaDokWal,
  Dokument.KRo_Kwota as Dok_Kwota,
  Dokument.KRo_KwotaWal as Dok_KwotaWal,
  Dokument.KRo_Waluta as Dok_Waluta,
  Dokument.KRo_BRKID as Dok_BRKID,
  Dokument.KRo_Typ as Dok_Typ,
  Dokument.KRo_DeEId as Dok_DeEId,
  Dokument.KRo_BOEId as Dok_BOEId,
  Dokument.KRo_Konto as Dok_Konto,
  Dokument.KRo_KontoIdx as Dok_KontoIdx,
  DekretDokumnet.DeE_DeNId as Dok_DeNId,
  IsNull(case when Dokument.KRo_Typ = 1 then DekretDokumnet.DeE_BezRozliczenia else BODokumnet.BoE_BezRozliczenia end, 0) as Dok_BezRozliczenia,
  IsNull(case when Dokument.KRo_Typ = 1 then DekretDokumnet.DeE_KursNumer else BODokumnet.BoE_KursNumer end, 0) as Dok_KursNumer,
  IsNull(case when Dokument.KRo_Typ = 1 then DekretDokumnet.DeE_KursL else BODokumnet.BoE_KursL end, 0) as Dok_KursL,
  IsNull(case when Dokument.KRo_Typ = 1 then DekretDokumnet.DeE_KursM else BODokumnet.BoE_KursM end, 0) as Dok_KursM,
  Rozliczenie.KRo_KRoId as Roz_KRoId,
  Rozliczenie.KRo_DataRozliczenia as Roz_DataRozliczenia,
  Rozliczenie.KRo_DataRoz as Roz_DataRoz,
  Rozliczenie.KRo_KwotaDok as Roz_KwotaDok,
  Rozliczenie.KRo_KwotaDokWal as Roz_KwotaDokWal,
  Rozliczenie.KRo_Kwota as Roz_Kwota,
  Rozliczenie.KRo_KwotaWal as Roz_KwotaWal,
  Rozliczenie.KRo_Waluta as Roz_Waluta,
  Rozliczenie.KRo_BRKID as Roz_BRKID,
  Rozliczenie.KRo_Typ as Roz_Typ,
  Rozliczenie.KRo_DeEId as Roz_DeEId,
  Rozliczenie.KRo_BOEId as Roz_BOEId,
  Rozliczenie.KRo_Konto as Roz_Konto,
  Rozliczenie.KRo_KontoIdx as Roz_KontoIdx,
  DekretRozliczenie.DeE_DeNId as Roz_DeNId,
  IsNull(case when Rozliczenie.KRo_Typ = 1 then DekretRozliczenie.DeE_BezRozliczenia else BORozliczenie.BoE_BezRozliczenia end, 0) as Roz_BezRozliczenia,
  IsNull(case when Rozliczenie.KRo_Typ = 1 then DekretRozliczenie.DeE_KursNumer else BORozliczenie.BoE_KursNumer end, 0) as Roz_KursNumer,
  IsNull(case when Rozliczenie.KRo_Typ = 1 then DekretRozliczenie.DeE_KursL else BORozliczenie.BoE_KursL end, 0) as Roz_KursL,
  IsNull(case when Rozliczenie.KRo_Typ = 1 then DekretRozliczenie.DeE_KursM else BORozliczenie.BoE_KursM end, 0) as Roz_KursM
 from cdn.KsiRozrachunki as Dokument join cdn.KsiRozrachunki as Rozliczenie on (Dokument.KRo_RozliczenieId = Rozliczenie.KRo_KRoId)
 left outer join CDN.DekretyElem DekretDokumnet on (Dokument.KRo_DeEId = DekretDokumnet.DeE_DeEId)
 left outer join CDN.DekretyElem DekretRozliczenie on (Rozliczenie.KRo_DeEId = DekretRozliczenie.DeE_DeEId)
 left outer join CDN.BOElem BODokumnet on (Dokument.KRo_BoEId = BODokumnet.BoE_BoEId)
 left outer join CDN.BOElem BORozliczenie on (Rozliczenie.KRo_BoEId = BORozliczenie.BoE_BoEId)
 where
 Dokument.KRo_KRoId = @SrcKRoID and Rozliczenie.KRo_KRoId = @DstKRoID

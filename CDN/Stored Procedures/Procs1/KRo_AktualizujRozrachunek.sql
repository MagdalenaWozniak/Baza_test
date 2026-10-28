CREATE   PROCEDURE CDN.KRo_AktualizujRozrachunek
@OObId    int,
@Rozliczenie     int,
@DataDokumentu      datetime,
@DataOperacji      datetime,
@TerminPlatnosci    datetime,
@Dokument       NVARCHAR(256),
@NrDziennika        NVARCHAR(256),
@Dziennik   NVARCHAR(256),
@NumerDziennika     int,
@NrKsiegi           NVARCHAR(256),
@IDKsiegowy         NVARCHAR(256),
@KwotaDok       decimal(15,2),
@KwotaDokWal     decimal(15,2),
@Waluta             NVARCHAR(3),
@KontoWn    NVARCHAR(50),
@KontoMa    NVARCHAR(50),
@KontoPrzeciwstawne NVARCHAR(50),
@DeEId     int,
@BOEId     int,
@Opis     NVARCHAR(50),
@Bufor              int,
@Storno             int
AS
  SET NOCOUNT ON
 set @NrDziennika    = SUBSTRING(@NrDziennika, 1, 30);
 set @Dziennik  = SUBSTRING(@Dziennik, 1, 30);
 set @NrKsiegi       = SUBSTRING(@NrKsiegi, 1, 30);
 set @IDKsiegowy     = SUBSTRING(@IDKsiegowy, 1, 30);
 -- ***************************************************************************
  DECLARE @KRo_OObId      int,
   @KRo_Typ       smallint,
            @KRo_DataDokumentu              datetime,
   @KRo_DataOperacji               datetime,
            @KRo_TerminPlatnosci            datetime,
   @KRo_Dokument            NVARCHAR(256),
   @KRo_NrDziennika          NVARCHAR(30),
   @KRo_Dziennik     NVARCHAR(30),
   @KRo_NumerDziennika    int,
   @KRo_NrKsiegi        NVARCHAR(30),
   @KRo_IdentKsieg           NVARCHAR(50),
   @KRo_KwotaDok            decimal(15, 2),
            @KRo_KwotaDokWal          decimal(15, 2),
            @KRo_Waluta                     NVARCHAR(3),
   @KRo_Konto          NVARCHAR(50),
   @KRo_KontoIdx            NVARCHAR(50),
            @KRo_KontoPrzeciw               NVARCHAR(50),
   @KRo_DeEId          int,
   @KRo_BOEId          int,
   @KRo_Opis          NVARCHAR(50),
   @KRo_RozliczenieId              int,
   @KRo_Strona         int,
            @KRo_Bufor             int,
            @KRo_Storno            int,
            @KwotaRozrachunkuSys            decimal(15,2),
            @KwotaRozrachunkuWal            decimal(15,2)
 -- ***************************************************************************
 -- ***************************************************************************
 -- określenie typu dokumentu żródłowego
 -- Typ = 1 - DekretElem
 -- Typ = 2 - BOElem
 set @KRo_Typ = 0
 if @DeEId is not NULL and @BOEId is NULL
 begin
  set @KRo_Typ = 1
 end
 else
 if @DeEId is NULL and @BOEId is not NULL
 begin
  set @KRo_Typ = 2
 end
 -- ***************************************************************************
 -- kasowanie rozliczen
 if @Rozliczenie = 0
  begin
                if exists(
                            select * from
          CDN.KsiRozrachunki L join  CDN.KsiRozrachunki R on (L.KRo_KRoID = R.KRo_RozliczenieID)
                            where
                            (L.KRo_DeEID = @DeEId or L.KRo_BOEID = @BOEId)
                            and  exists(
                                    select * from CDN.KsiDokElem join CDN.KsiDokNag on (KDE_KDNID = KDN_KDNID)
                                    where
            KDN_Bufor <> -1 and KDN_Typ = 113 and (KDE_KRoID = L.KRo_KRoID or KDE_KRoID = L.KRo_RozliczenieID)
                                    or
                                    KDN_Typ in (-1, -1) and (KDE_DeEID = L.KRo_DeEID or KDE_BoEID = L.KRo_BoEID or KDE_DeEID = R.KRo_DeEID or KDE_BoEID = R.KRo_BoEID)
                                        )
                )
                begin
                    exec CDN.RiseOptimaException 32514, 's1', @Dokument
                    if @@TranCount<>0 ROLLBACK TRAN
                    SET NOCOUNT OFF
              RETURN
                end
          declare @DelKRoID  int
          declare @delDeEID  int
          declare @delBoEID  int
                declare @delSumRozSys   decimal(15,2)
                declare @delSumRozWal   decimal(15,2)
                Declare DelRozrachunki Cursor Local Fast_Forward For
          Select KRo_KRoID
          from
          CDN.KsiRozrachunki
          where
          KRo_DeEID = @DeEId or KRo_BOEID = @BOEId
          Open DelRozrachunki
          While 1=1
          Begin
        Fetch Next From DelRozrachunki InTo @DelKRoID
        If @@Fetch_Status <> 0 Break
        select @delDeEID = KRo_DeEID, @delBoEID = KRo_BoEID from CDN.KsiRozrachunki
        where KRo_RozliczenieId = @DelKRoID
        update CDN.KsiRozrachunki set   KRo_Kwota           = 0.00,
                                                    KRo_KwotaWal        = 0.00,
                                                    KRo_RozliczenieId   = NULL,
                                                    KRo_DataRozliczenia = NULL,
                                                    KRo_DataRoz         = NULL
        where KRo_RozliczenieId = @DelKRoID
        if @delDeEID is not NULL
        begin
         select  @delSumRozSys = Sum(KRo_Kwota),
           @delSumRozWal = Sum(KRo_KwotaWal)
         from CDN.KsiRozrachunki
         where KRo_DeEId = @delDeEID
         update CDN.KsiRozrachunki set KRo_SumRozliczen = @delSumRozSys, KRo_SumRozliczenWal = @delSumRozWal
         where KRo_DeEId = @delDeEID
        end
        if @delBoEID is not NULL
        begin
         select  @delSumRozSys = Sum(KRo_Kwota),
           @delSumRozWal = Sum(KRo_KwotaWal)
         from CDN.KsiRozrachunki
         where KRo_BoEID = @delBoEID
         update CDN.KsiRozrachunki set KRo_SumRozliczen = @delSumRozSys, KRo_SumRozliczenWal = @delSumRozWal
         where KRo_BoEID = @delBoEID
        end
          End
          Close DelRozrachunki
          Deallocate DelRozrachunki
    -- skasowanie elementów rozliczeń
    delete from CDN.KsiRozrachunki where KRo_DeEId = @DeEId or KRo_BOEID = @BOEId
  end -- if @Rozliczenie = 0
 else
  -- dodawanie lub aktualizacja rozliczeń
  if @Rozliczenie = 1
  begin
            if len(@Waluta) = 0 -- walutę systemową zapisujemy jako null
            begin
                set @Waluta = NULL
            end
            declare @KwotaDokumentu decimal(15,2)
            if @Waluta is NULL      -- waluta systemowa
            begin
                set @KwotaDokumentu = @KwotaDok
                set @KwotaDokWal    = 0.00
            end
            else                    -- waluta obca
            begin
                if @KwotaDok <> 0 and @KwotaDokWal = 0  -- różnica kursowa
                begin
                    set @KwotaDokumentu = @KwotaDok
                end
                else
                begin
                    set @KwotaDokumentu = @KwotaDokWal
                end
            end
   -- Określenie strony rozliczenia Wn/Ma
   if Len(@KontoWn) > 0 and @KwotaDokumentu <> 0.00
   begin
    -- kwota jest dodatnia, ustawiam sronę Wn
    if @KwotaDokumentu > 0.00
     begin
      set @KRo_Strona      = 1
      set @KRo_KwotaDok       = @KwotaDok
                        set @KRo_KwotaDokWal    = @KwotaDokWal
      set @KRo_Konto       = replace(@KontoWn, '.', '-')
      set @KRo_KontoIdx       = replace(@KontoWn, '-', '.')
     end
    else
    -- kwota jest ujemna, ustawiam sronę Ma
    if @KwotaDokumentu < 0.00
     begin
      set @KRo_Strona      = 2
      set @KRo_KwotaDok     = -1 * @KwotaDok
                        set @KRo_KwotaDokWal    = -1 * @KwotaDokWal
      set @KRo_Konto       = replace(@KontoWn, '.', '-')
      set @KRo_KontoIdx     = replace(@KontoWn, '-', '.')
     end
   end
   else
   if Len(@KontoMa) > 0 and @KwotaDokumentu <> 0.00
   begin
    -- kwota jest dodatnia, ustawiam sronę Ma
    if @KwotaDokumentu > 0.00
     begin
      set @KRo_Strona      = 2
      set @KRo_KwotaDok     = @KwotaDok
                        set @KRo_KwotaDokWal    = @KwotaDokWal
      set @KRo_Konto       = replace(@KontoMa, '.', '-')
      set @KRo_KontoIdx     = replace(@KontoMa, '-', '.')
     end
    else
    -- kwota jest ujemna, ustawiam sronę Wn
    if @KwotaDokumentu < 0.00
     begin
      set @KRo_Strona      = 1
      set @KRo_KwotaDok       = -1 * @KwotaDok
                        set @KRo_KwotaDokWal    = -1 * @KwotaDokWal
      set @KRo_Konto       = replace(@KontoMa, '.', '-')
      set @KRo_KontoIdx       = replace(@KontoMa, '-', '.')
     end
   end
   -- Określenie czy nastąpi aktualizacja czy dodanie nowych pozycji
   -- możliwe wartości @EDIT_MODE (0,1,2)
   -- 0 - nie robie nic
   -- 1 - dodajwanie elementów rozliczeń
   -- 2 - zktualizacja elementów rozliczeń
   declare @EDIT_MODE int
   set @EDIT_MODE = 0
   if @KRo_Typ = 1
   begin
    if not exists(select * from CDN.KsiRozrachunki where KRo_DeEId = @DeEId) -- and KRo_Strona = @KRo_Strona)
     set @EDIT_MODE = 1
    else
     set @EDIT_MODE = 2
   end
   else
   if @KRo_Typ = 2
   begin
    if not exists(select * from CDN.KsiRozrachunki where KRo_BOEId = @BOEId)-- and KRo_Strona = @KRo_Strona)
     set @EDIT_MODE = 1
    else
     set @EDIT_MODE = 2
   end
   set @KRo_OObId    = @OObId
   set @KRo_Dokument   = @Dokument
            set @KRo_DataDokumentu      = @DataDokumentu
   set @KRo_DataOperacji       = @DataOperacji
            set @KRo_TerminPlatnosci    = @TerminPlatnosci
   set @KRo_NrDziennika  = @NrDziennika
   set @KRo_Dziennik   = @Dziennik
   set @KRo_NumerDziennika  = @NumerDziennika
   set @KRo_NrKsiegi   = @NrKsiegi
   set @KRo_IdentKsieg   = @IDKsiegowy
   set @KRo_Opis    = @Opis
   set @KRo_RozliczenieId     = NULL
   set @KRo_DeEId    = @DeEId
   set @KRo_BOEId     = @BOEId
            set @KRo_Bufor     = @Bufor
            set @KRo_Storno    = @Storno
            set @KRo_KontoPrzeciw       = @KontoPrzeciwstawne
            set @KRo_Waluta             = @Waluta
   if @EDIT_MODE = 1
   -- dodawanie nowych elementów rozliczeń
   begin
    if @KRo_KwotaDok <> 0.00 or @KRo_KwotaDokWal <> 0.00
    begin
     insert into CDN.KsiRozrachunki ( KRo_OObId,
              KRo_Dziennik,
              KRo_NumerDziennika,
              KRo_Typ,
                                                        KRo_DataDokumentu,
              KRo_DataOperacji,
                                                        KRo_TerminPlatnosci,
              KRo_Dokument,
              KRo_NrDziennika,
              KRo_NrKsiegi,
              KRo_IdentKsieg,
                                                        KRo_Waluta,
              KRo_KwotaDok,
                                                        KRo_KwotaDokWal,
              KRo_Kwota,
                                                        KRo_KwotaWal,
                                                        KRo_SumRozliczen,
                                                        KRo_SumRozliczenWal,
              KRo_Konto,
              KRo_KontoIdx,
                                                        KRo_KontoPrzeciw,
              KRo_DeEId,
              KRo_BOEId,
              KRo_Opis,
              KRo_RozliczenieId,
              KRo_Strona,
                                                        KRo_Storno,
                                                        KRo_Bufor)
             values (
              @KRo_OObId,
              @KRo_Dziennik,
              @KRo_NumerDziennika,
              @KRo_Typ,
                                                        @KRo_DataDokumentu,
              @KRo_DataOperacji,
                                                        @KRo_TerminPlatnosci,
              @KRo_Dokument,
              @KRo_NrDziennika,
              @KRo_NrKsiegi,
              @KRo_IdentKsieg,
                                                        @KRo_Waluta,
              @KRo_KwotaDok,
                                                        @KRo_KwotaDokWal,
              0.00,               --KRo_Kwota
              0.00,               --KRo_KwotaWal
                                                        0.00,               --KRo_SumRozliczen
                                                        0.00,               --KRo_SumRozliczenWal
              @KRo_Konto,
              @KRo_KontoIdx,
                                                        @KRo_KontoPrzeciw,
              @KRo_DeEId,
              @KRo_BOEId,
              @KRo_Opis,
              @KRo_RozliczenieId,
              @KRo_Strona,
                                                        @KRo_Storno,
                                                        @KRo_Bufor )
    end
   end -- if @EDIT_MODE = 1
   else
   -- aktualizacja elementów rozliczeń
   if @EDIT_MODE = 2
   begin
    declare @TmpKRoID  int
    if @KRo_Typ = 1
    begin
                    if not exists( select * from CDN.KsiRozrachunki where KRo_DeEId = @KRo_DeEId and KRo_RozliczenieId is not NULL)
                    begin
                        -- rozrachunki są nierozliczone update wszystkiego jest możliwy
         update CDN.KsiRozrachunki set KRo_OObId   = @KRo_OObId,
              KRo_Dziennik  = @KRo_Dziennik,
              KRo_NumerDziennika = @KRo_NumerDziennika,
              KRo_Dokument  = @KRo_Dokument,
                                                        KRo_DataDokumentu   = @KRo_DataDokumentu,
              KRo_DataOperacji    = @KRo_DataOperacji,
                                                        KRo_TerminPlatnosci = @KRo_TerminPlatnosci,
                 KRo_NrDziennika     = @KRo_NrDziennika,
                 KRo_NrKsiegi  = @KRo_NrKsiegi,
                 KRo_IdentKsieg     = @KRo_IdentKsieg,
                 KRo_KwotaDok  = @KRo_KwotaDok,
                                                        KRo_KwotaDokWal  = @KRo_KwotaDokWal,
                                                        KRo_Waluta      = @KRo_Waluta,
                 KRo_Konto   = @KRo_Konto,
                 KRo_KontoIdx  = @KRo_KontoIdx,
                                                        KRo_KontoPrzeciw    = @KRo_KontoPrzeciw,
                                                        KRo_Strona          = @KRo_Strona,
                 KRo_Opis   = @KRo_Opis,
                                                        KRo_Storno          = @KRo_Storno,
                                                        KRo_Bufor   = @KRo_Bufor
         where KRo_DeEId = @KRo_DeEId
                    end
                    else
                    begin
                        --  rozrachunki są rozliczone częściowo lub całkowicie
                        --  dozwolony jest update tylko niektórych pól.
         update CDN.KsiRozrachunki set KRo_OObId   = @KRo_OObId,
              KRo_Dziennik  = @KRo_Dziennik,
              KRo_NumerDziennika = @KRo_NumerDziennika,
              KRo_Dokument  = @KRo_Dokument,
                                                        KRo_DataDokumentu   = @KRo_DataDokumentu,
              KRo_DataOperacji    = @KRo_DataOperacji,
                                                        KRo_TerminPlatnosci = @KRo_TerminPlatnosci,
                 KRo_NrDziennika     = @KRo_NrDziennika,
                 KRo_NrKsiegi  = @KRo_NrKsiegi,
                 KRo_IdentKsieg     = @KRo_IdentKsieg,
                 --KRo_KwotaDok  = @KRo_KwotaDok,
                 --KRo_Konto   = @KRo_Konto,
                 --KRo_KontoIdx  = @KRo_KontoIdx,
                                                        KRo_KontoPrzeciw    = @KRo_KontoPrzeciw,
                                                        --KRo_Strona          = @KRo_Strona,
                 KRo_Opis   = @KRo_Opis,
                                                        KRo_Storno          = @KRo_Storno,
                                                        KRo_Bufor   = @KRo_Bufor
         where KRo_DeEId = @KRo_DeEId
                        -- możliwy jest tylko update kwoty w przypadku gdy nowa kwota jest
                        -- większa od wartości dotychczasowego rozliczenia
                        select  @KwotaRozrachunkuSys = CDN.KRo_KwotaRozrachunku( 1,  @KRo_DeEId, @KRo_Strona, 'SYS'         ),
                                @KwotaRozrachunkuWal = CDN.KRo_KwotaRozrachunku( 1,  @KRo_DeEId, @KRo_Strona, @KRo_Waluta )
            select top 1 @TmpKRoID = KRo_KRoID from CDN.KsiRozrachunki where KRo_DeEId = @KRo_DeEId
                        if @KwotaRozrachunkuSys < @KRo_KwotaDok or (@KRo_Waluta is not NULL and @KwotaRozrachunkuWal < @KRo_KwotaDokWal)
                        begin
                            -- ustawienie nowej kwoty dokumentu
             update CDN.KsiRozrachunki set KRo_KwotaDok = @KRo_KwotaDok, KRo_KwotaDokWal = @KRo_KwotaDokWal
             where KRo_DeEId = @KRo_DeEId
                            if not exists( select * from CDN.KsiRozrachunki where KRo_DeEId = @KRo_DeEId and KRo_Strona = @KRo_Strona and (KRo_Kwota = 0.00 and KRo_KwotaWal = 0.00))
                            -- rozrachunki są w pełni rozliczone, dodaje nowy record z KRo_Kwota ustawioną na 0.00
                            -- oraz z czystym linkiem do dokumentu rozliczającego
                            begin
           insert into CDN.KsiRozrachunki (
         KRo_OObId,
         KRo_Dziennik,
         KRo_NumerDziennika,
            KRo_Typ,
                                    KRo_DataDokumentu,
         KRo_DataOperacji,
                                    KRo_TerminPlatnosci,
            KRo_NrDziennika,
            KRo_Dokument,
            KRo_NrKsiegi,
            KRo_IdentKsieg,
            KRo_KwotaDok,
            KRo_Kwota,
                                    KRo_SumRozliczen,
            KRo_KwotaDokWal,
            KRo_KwotaWal,
                                    KRo_SumRozliczenWal,
                                    KRo_Waluta,
            KRo_Konto,
            KRo_KontoIdx,
                                    KRo_KontoPrzeciw,
            KRo_DeEId,
            KRo_BOEId,
            KRo_Opis,
            KRo_RozliczenieId,
            KRo_Strona,
                                    KRo_Storno,
                                    KRo_Bufor)
           select
         KRo_OObId,
         KRo_Dziennik,
         KRo_NumerDziennika,
            KRo_Typ,
                                    KRo_DataDokumentu,
         KRo_DataOperacji,
                                    KRo_TerminPlatnosci,
            KRo_NrDziennika,
            KRo_Dokument,
            KRo_NrKsiegi,
            KRo_IdentKsieg,
            KRo_KwotaDok,
            0.00,
                                    KRo_SumRozliczen,
            KRo_KwotaDokWal,
            0.00,
                                    KRo_SumRozliczenWal,
                                    KRo_Waluta,
            KRo_Konto,
            KRo_KontoIdx,
                                    KRo_KontoPrzeciw,
            KRo_DeEId,
            KRo_BOEId,
            KRo_Opis,
            NULL, --KRo_RozliczenieId
            KRo_Strona,
                                    KRo_Storno,
                                    KRo_Bufor
           from CDN.KsiRozrachunki where KRo_KRoID = @TmpKRoID
                            end
                        end
        end
                end -- if @KRo_Typ = 1
                else
    if @KRo_Typ = 2
    begin
                    if not exists( select * from CDN.KsiRozrachunki where KRo_BOEID = @KRo_BOEID and KRo_RozliczenieId is not NULL)
                    begin
                        -- rozrachunki są nierozliczone update wszystkiego jest możliwy
         update CDN.KsiRozrachunki set KRo_OObId   = @KRo_OObId,
              KRo_Dziennik  = @KRo_Dziennik,
              KRo_NumerDziennika = @KRo_NumerDziennika,
              KRo_Dokument  = @KRo_Dokument,
                                                        KRo_DataDokumentu   = @KRo_DataDokumentu,
              KRo_DataOperacji    = @KRo_DataOperacji,
                                                        KRo_TerminPlatnosci = @KRo_TerminPlatnosci,
                 KRo_NrDziennika     = @KRo_NrDziennika,
                 KRo_NrKsiegi  = @KRo_NrKsiegi,
                 KRo_IdentKsieg     = @KRo_IdentKsieg,
                 KRo_KwotaDok  = @KRo_KwotaDok,
                                                        KRo_KwotaDokWal  = @KRo_KwotaDokWal,
                                                        KRo_Waluta      = @KRo_Waluta,
                 KRo_Konto   = @KRo_Konto,
                 KRo_KontoIdx  = @KRo_KontoIdx,
                                                        KRo_KontoPrzeciw    = @KRo_KontoPrzeciw,
                                                        KRo_Strona          = @KRo_Strona,
                 KRo_Opis   = @KRo_Opis,
                                                        KRo_Storno          = @KRo_Storno,
                                                        KRo_Bufor   = @KRo_Bufor
         where KRo_BOEID = @KRo_BOEID
                    end
                    else
                    begin
                        -- rozrachunki są rozliczone częściowo lub całkowicie
                        --  dozwolony jest update tylko niektórych pól.
         update CDN.KsiRozrachunki set KRo_OObId   = @KRo_OObId,
              KRo_Dziennik  = @KRo_Dziennik,
              KRo_NumerDziennika = @KRo_NumerDziennika,
              KRo_Dokument  = @KRo_Dokument,
                                                        KRo_DataDokumentu   = @KRo_DataDokumentu,
              KRo_DataOperacji = @KRo_DataOperacji,
                                                        KRo_TerminPlatnosci = @KRo_TerminPlatnosci,
                 KRo_NrDziennika     = @KRo_NrDziennika,
                 KRo_NrKsiegi  = @KRo_NrKsiegi,
                 KRo_IdentKsieg     = @KRo_IdentKsieg,
                 --KRo_KwotaDok  = @KRo_KwotaDok,
                 --KRo_Konto   = @KRo_Konto,
                 --KRo_KontoIdx  = @KRo_KontoIdx,
                                                        KRo_KontoPrzeciw    = @KRo_KontoPrzeciw,
                                                        --KRo_Strona          = @KRo_Strona,
                 KRo_Opis   = @KRo_Opis,
                                                        KRo_Storno          = @KRo_Storno,
                                                        KRo_Bufor   = @KRo_Bufor
         where KRo_BOEID = @KRo_BOEID
                        -- możliwy jest tylko update kwoty w przypadku gdy nowa kwota jest
                        -- większa od wartości dotychczasowego rozliczenia
                        select  @KwotaRozrachunkuSys = CDN.KRo_KwotaRozrachunku( 2,  @KRo_BOEID, @KRo_Strona, 'SYS'),
                                @KwotaRozrachunkuWal = CDN.KRo_KwotaRozrachunku( 2,  @KRo_BOEID, @KRo_Strona, @KRo_Waluta )
            select top 1 @TmpKRoID = KRo_KRoID from CDN.KsiRozrachunki where KRo_BOEID = @KRo_BOEID
                        if @KwotaRozrachunkuSys < @KRo_KwotaDok or (@KRo_Waluta is not NULL and @KwotaRozrachunkuWal < @KRo_KwotaDokWal)
                        begin
                            -- ustawienie nowej kwoty dokumentu
             update CDN.KsiRozrachunki set KRo_KwotaDok = @KRo_KwotaDok, KRo_KwotaDokWal = @KRo_KwotaDokWal
             where KRo_BOEID = @KRo_BOEID
                            if not exists( select * from CDN.KsiRozrachunki where KRo_BOEID = @KRo_BOEID and KRo_Strona = @KRo_Strona and (KRo_Kwota = 0.00 and KRo_KwotaWal = 0.00))
                            -- rozrachunki są w pełni rozliczone, dodaje nowy record z KRo_Kwota ustawioną na 0.00
                            -- oraz z czystym linkiem do dokumentu rozliczającego
                            begin
           insert into CDN.KsiRozrachunki (
         KRo_OObId,
         KRo_Dziennik,
         KRo_NumerDziennika,
            KRo_Typ,
                                    KRo_DataDokumentu,
         KRo_DataOperacji,
                                    KRo_TerminPlatnosci,
            KRo_NrDziennika,
            KRo_Dokument,
            KRo_NrKsiegi,
            KRo_IdentKsieg,
            KRo_KwotaDok,
            KRo_Kwota,
                                    KRo_SumRozliczen,
            KRo_KwotaDokWal,
            KRo_KwotaWal,
                                    KRo_SumRozliczenWal,
                                    KRo_Waluta,
            KRo_Konto,
            KRo_KontoIdx,
                                    KRo_KontoPrzeciw,
            KRo_DeEID,
            KRo_BOEId,
            KRo_Opis,
            KRo_RozliczenieId,
            KRo_Strona,
                                    KRo_Storno,
                                    KRo_Bufor)
           select
         KRo_OObId,
         KRo_Dziennik,
         KRo_NumerDziennika,
            KRo_Typ,
                                    KRo_DataDokumentu,
         KRo_DataOperacji,
                                    KRo_TerminPlatnosci,
            KRo_NrDziennika,
            KRo_Dokument,
            KRo_NrKsiegi,
            KRo_IdentKsieg,
            KRo_KwotaDok,
            0.00,
                                    KRo_SumRozliczen,
            KRo_KwotaDokWal,
            0.00,
                                    KRo_SumRozliczenWal,
                                    KRo_Waluta,
            KRo_Konto,
            KRo_KontoIdx,
                                    KRo_KontoPrzeciw,
            KRo_DeEID,
            KRo_BOEId,
            KRo_Opis,
            NULL, --KRo_RozliczenieId
            KRo_Strona,
                                    KRo_Storno,
                                    KRo_Bufor
           from CDN.KsiRozrachunki where KRo_KRoID = @TmpKRoID
                            end
                        end
        end
                end -- if @KRo_Typ = 2
      end -- if @EDIT_MODE = 2
    end -- if @Rozliczenie = 1
  SET NOCOUNT OFF
  -- END OF PROCEDURE CDN.KRo_AktualizujRozrachunek

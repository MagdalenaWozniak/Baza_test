CREATE PROCEDURE [CDN].[Detal_StanyMagazynowe]
  @detalStanowiskoId INT
 ,@towarID    INT
 ,@towarKod    NVARCHAR(50)
 ,@uwzgledniajWszystkieMagazyny TINYINT
 ,@iloscNaParagonie  DECIMAL(15,4)
AS
SET NOCOUNT ON
 DECLARE
  @MagId INT,
  @towarIDOptima INT,
  @dstaid INT,
  @dsta_magid INT,
  @IloscPozostala DECIMAL(15,4),
  @Jednostka NVARCHAR(20)
 SET @MagId = 0
 SET @IloscPozostala = 0
 SELECT @MagId = DSta_MagID  FROM cdn.detalstanowiska WHERE DSta_DStaId = @detalStanowiskoId
 IF @towarID = 0
  SELECT  Top 1 @towarID=DSTwr_DSTwrID, @towarIDOptima = DSTwr_OptimaID, @Jednostka = DSTwr_JM FROM CDN.DetalStanTowary
  WHERE (DSTwr_EAN=@towarKod or DSTwr_Kod=@towarKod) and DSTwr_standetalid = @detalStanowiskoId
  ORDER BY CASE WHEN DSTwr_EAN =@towarKod THEN 1 WHEN DsTwr_Kod =@towarKod THEN 2 END
 ELSE
  SELECT  top 1 @towarIDOptima = DSTwr_OptimaID, @Jednostka = DSTwr_JM FROM CDN.DetalStanTowary WHERE DSTwr_DSTwrID = @towarID
 IF @towarID = 0
 BEGIN
  RAISERROR('Nie znaleziono Towaru', 16, 1)
  rollback
  SET NOCOUNT OFF
  RETURN
 END
  CREATE TABLE  #Zasoby(id int identity(1,1),TowarID INT,TowarIdOptima INT, Kod NVARCHAR(50),EAN NVARCHAR(40),Typ int,MagId int,MagSymbol NVARCHAR(20), Ilosc DECIMAL(15,4) )
  IF @uwzgledniajWszystkieMagazyny = 1
    INSERT INTO #Zasoby (TowarID,TowarIdOptima, Kod,EAN,Typ,MagId, MagSymbol, Ilosc )
    SELECT @towarID,@towarIDOptima,CDN.Towary.Twr_Kod, CDN.Towary.Twr_EAN,CDN.Towary.Twr_Typ ,Mag_MagId,Mag_Symbol,
    CASE WHEN Mag_MagId = @MagId THEN
    CASE WHEN CDN.Towary.Twr_Typ = 0 THEN 1 ELSE CASE WHEN IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje - @iloscNaParagonie, 0.00) >= 0 THEN IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje - @iloscNaParagonie, 0.00) ELSE 0 END END
    else
    CASE WHEN CDN.Towary.Twr_Typ = 0 THEN 1 ELSE CASE WHEN IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje, 0.00) >= 0 THEN IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje, 0.00) ELSE 0 END END
    end
    AS TwI_Ilosc
    FROM CDN.Towary
    JOIN CDN.TwrIlosci B ON CDN.Towary.Twr_TwrId = B.TwI_TwrId
    JOIN CDN.Magazyny on B.TwI_MagId = Mag_MagId
    WHERE CDN.Towary.Twr_TwrId = @towarIDOptima AND B.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = CDN.Towary.Twr_TwrId AND H.TwI_MagId = Mag_MagId AND H.TwI_Data <= GETDATE() ORDER BY H.TwI_Data DESC)
    and Mag_typ = 1 and  Mag_NieAktywny = 0
  ELSE
  Begin
    INSERT INTO #Zasoby(TowarID,TowarIdOptima, Kod,EAN,Typ,MagId,MagSymbol, Ilosc )
    SELECT @towarID,@towarIDOptima,CDN.Towary.Twr_Kod, CDN.Towary.Twr_EAN,CDN.Towary.Twr_Typ ,Mag_MagId,Mag_Symbol,
    CASE WHEN CDN.Towary.Twr_Typ = 0 THEN 1 ELSE CASE WHEN IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje - @iloscNaParagonie, 0.00) >= 0 THEN IsNull(B.TwI_Ilosc - B.TwI_Rezerwacje - @iloscNaParagonie, 0.00) ELSE 0 END END AS TwI_Ilosc
    FROM CDN.Towary
    JOIN CDN.TwrIlosci B ON CDN.Towary.Twr_TwrId = B.TwI_TwrId AND B.TwI_MagId = @MagId AND B.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = CDN.Towary.Twr_TwrId AND H.TwI_MagId = @MagId AND H.TwI_Data <= GETDATE() ORDER BY H.TwI_Data DESC)
    JOIN CDN.Magazyny on B.TwI_MagId = Mag_MagId
    WHERE CDN.Towary.Twr_TwrId = @towarIDOptima and Mag_typ = 1 and  Mag_NieAktywny = 0
  End
  CREATE TABLE  #ZasobyStan(StanDetalID INT, Ilosc DECIMAL(15,4) )
  INSERT INTO #ZasobyStan(StanDetalID, Ilosc )
  (
      select DSTrN_StanDetalID, ISNULL(sum(dstre_ilosc*(DSTrE_JMPrzelicznikL/DSTrE_JMPrzelicznikM)),0) from cdn.detalstantraelem
      join cdn.detalstantranag on dstrn_dstrnid = dstre_dstrnid
      join cdn.detalstantowary on dstre_TwrId = dstwr_dstwrid
      where dstwr_OptimaId = @towarIDOptima and ISNULL(dstrn_Stansynchronizacji,0) = 0
      and ((dstrn_typdokumentu = 305 and ISNULL(dstrn_korekta,0) = 0) OR (dstrn_typdokumentu IN(305,302) and ISNULL(dstrn_korekta, 0) = 1) )
   group by DSTrN_StanDetalID
 )
   INSERT INTO #ZasobyStan(StanDetalID, Ilosc )
   (
      select DTrN_StanDetalID, ISNULL(sum(dtre_ilosc),0) from cdn.detaltraelem
      join cdn.detaltranag on dtrn_dstrnid = dtre_dstrnid and DTrN_StanDetalID =  DTrE_StanDetalId
      where dtre_TwrId = @towarIDOptima and dtrn_Stansynchronizacji = 1
      and ((dtrn_typdokumentu = 305 and ISNULL(dtrn_korekta,0) = 0) OR (dtrn_typdokumentu IN(305,302) and ISNULL(dtrn_korekta,0) = 1) )
   group by DTrN_StanDetalID
   )
   INSERT INTO #ZasobyStan(StanDetalID, Ilosc )
   (
      select DSTrN_StanDetalID,  ISNULL(sum(dstre_ilosc),0) * -1 from cdn.detalstantraelem
      join cdn.detalstantranag on dstrn_dstrnid = dstre_dstrnid
      join cdn.detalstantowary on dstre_TwrId = dstwr_dstwrid
      where dstwr_OptimaId = @towarIDOptima and ISNULL(dstrn_Stansynchronizacji,0) = 0
      and dstrn_typdokumentu = 313
   group by DSTrN_StanDetalID
   )
   INSERT INTO #ZasobyStan(StanDetalID, Ilosc )
   (
      select DTrN_StanDetalID, ISNULL(sum(dtre_ilosc),0) * -1 from cdn.detaltraelem
      join cdn.detaltranag on dtrn_dstrnid = dtre_dstrnid and DTrN_StanDetalID =  DTrE_StanDetalId
      where dtre_TwrId = @towarIDOptima and dtrn_Stansynchronizacji = 1
      and dtrn_typdokumentu = 313
   group by DTrN_StanDetalID
   )
  DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR SELECT dsta_dstaid, dsta_magid FROM cdn.DetalStanowiska
  OPEN Dodawane
  WHILE 1=1
    BEGIN
      FETCH NEXT FROM Dodawane INTO
      @dstaid,
      @dsta_magid
      IF @@FETCH_STATUS <> 0 BREAK
      set @IloscPozostala =0
      if not exists(select TowarId from #Zasoby where TowarIdOptima = @towarIDOptima AND MagId = @dsta_magid)
        Begin
        INSERT INTO #Zasoby(TowarID,TowarIdOptima, Kod,EAN,Typ,MagId,MagSymbol, Ilosc )
        SELECT @towarID,@towarIDOptima,CDN.Towary.Twr_Kod, CDN.Towary.Twr_EAN,CDN.Towary.Twr_Typ ,Mag_MagId,Mag_Symbol,
        0 AS TwI_Ilosc
        FROM CDN.Towary
        JOIN CDN.Magazyny on @dsta_MagId = Mag_MagId
        WHERE CDN.Towary.Twr_TwrId = @towarIDOptima and Mag_typ = 1
      End
   select @IloscPozostala = ISNULL(sum(Ilosc),0) FROM #ZasobyStan WHERE StanDetalID = @dstaid
      update #Zasoby set Ilosc = case when Ilosc - @IloscPozostala < 0 then 0 else Ilosc - @IloscPozostala end where TowarID = @towarID and MagId = @dsta_MagId
    END
  CLOSE Dodawane
  DEALLOCATE Dodawane
 IF @uwzgledniajWszystkieMagazyny = 0
 BEGIN
  if exists (select Ilosc from #Zasoby WHERE MagId = @MagId)
   select kod, MagSymbol, Ilosc, @Jednostka as Jednostka from #Zasoby WHERE MagId = @MagId
  else
   select '' as kod, '' as MagSymbol, convert(decimal(15,4),0) as Ilosc, @Jednostka as Jednostka
 END
 ELSE
 BEGIN
  select kod, MagSymbol, ilosc, @Jednostka as Jednostka from #Zasoby
  union all
  select '' as kod,Mag_Symbol as MagSymbol,0 as ilosc, '' as Jednostka from cdn.magazyny where Mag_typ = 1 and  Mag_NieAktywny = 0 and  mag_magid not in (select MagId from #Zasoby)
 END
SET NOCOUNT OFF

CREATE FUNCTION CDN.SrsCzynnosciKontrolaTerminu (
@Id			INT,
@SrZId		INT,
@OpiekunTyp INT,
@OpiekunId  INT,
@DataOd		DATETIME,
@DataDo		DATETIME,
@DoNTyp		INT,
@DoNId		INT)
  RETURNS     VARCHAR(255)
  AS
  BEGIN
    DECLARE @Komunikat      VARCHAR(255)
    DECLARE @KomunikatCrm   VARCHAR(255)
    DECLARE @Numery         VARCHAR(255)
    DECLARE @Temat          VARCHAR(255)
    DECLARE @NewId          INT

    SET @Numery = ''
    SET @Temat = ''
    SET @Komunikat = ''
    IF @Id IS NULL
        SET @NewId = 0
    ELSE
        SET @NewId = @Id

    
    -- sprawdzam, (1) - czy termin czynności nie zachodzi na zadanie w CRM
	

	SET @Komunikat = cdn.CrmKontrolaTerminu (0, 0, @OpiekunTyp, @OpiekunId, @DataOd, @DataDo, 1, 0)
	IF @Komunikat <> ''
	BEGIN
		SET @KomunikatCrm = N'zadania CRM ' + @Komunikat
		GOTO KONIEC
	END
    
    -- sprawdzam, (2) - czy termin czynności nie zachodzi na zadanie w OBD
	
	IF IsNull(@DoNId,0) = 0
	BEGIN
		 IF EXISTS( SELECT * FROM CDN.DokNagProcesEtapyView
		 JOIN CDN.DokNagEtapyView ON DnPr_Typ=DnE_Typ AND DnPr_DnPrID=DnE_DnPrID
		 JOIN CDN.DokNagView ON DnPr_Typ=DnV_Typ AND DnPr_DoNID=DnV_DoNID
		 WHERE  DnV_EtapBiezacyLp > 0
				AND DnE_Wykonany = 0
				AND DnE_RezerwujCzas = 1
				AND DnE_OpeId = @OpiekunId
				AND (	@DataOd > DNE_TerminOd AND @DataOd < DNE_TerminDo
					OR (@DataDo > DNE_TerminOd AND @DataDo < DNE_TerminDo)
					OR (DNE_TerminOd > @DataOd AND DNE_TerminOd < @DataDo)
					OR (DNE_TerminDo > @DataOd AND DNE_TerminDo < @DataDo) )
				)
		BEGIN
		   SELECT TOP 1  @Numery = IsNull(DnV_NumerPelny, '') FROM CDN.DokNagProcesEtapyView
			 JOIN CDN.DokNagEtapyView ON DnPr_Typ=DnE_Typ AND DnPr_DnPrID=DnE_DnPrID
			 JOIN CDN.DokNagView ON DnPr_Typ=DnV_Typ AND DnPr_DoNID=DnV_DoNID
			 WHERE  DnV_EtapBiezacyLp > 0
					AND DnE_Wykonany = 0
					AND DnE_RezerwujCzas = 1
					AND DnE_OpeId = @OpiekunId
					AND (	@DataOd > DNE_TerminOd AND @DataOd < DNE_TerminDo
						OR (@DataDo > DNE_TerminOd AND @DataDo < DNE_TerminDo)
						OR (DNE_TerminOd > @DataOd AND DNE_TerminOd < @DataDo)
						OR (DNE_TerminDo > @DataOd AND DNE_TerminDo < @DataDo) )
			ORDER BY DnV_DoNId
			SET @Komunikat = 'etapu obiegu dokumentów numer: ' + RTRIM(@Numery)
			GOTO KONIEC
		END
	END
	ELSE
	BEGIN
		 IF EXISTS( SELECT * FROM CDN.DokNagProcesEtapyView
		 JOIN CDN.DokNagEtapyView ON DnPr_Typ=DnE_Typ AND DnPr_DnPrID=DnE_DnPrID
		 JOIN CDN.DokNagView ON DnPr_Typ=DnV_Typ AND DnPr_DoNID=DnV_DoNID AND (DnV_DoNID<>@DoNID OR (DnPr_Typ<>@DoNTyp AND DnPr_DoNID=DnV_DoNID))
		 WHERE  DnV_EtapBiezacyLp > 0
				AND DnE_Wykonany = 0
				AND DnE_RezerwujCzas = 1
				AND DnE_OpeId = @OpiekunId
				AND (	@DataOd > DNE_TerminOd AND @DataOd < DNE_TerminDo
					OR (@DataDo > DNE_TerminOd AND @DataDo < DNE_TerminDo)
					OR (DNE_TerminOd > @DataOd AND DNE_TerminOd < @DataDo)
					OR (DNE_TerminDo > @DataOd AND DNE_TerminDo < @DataDo) )
				)
		BEGIN
		   SELECT TOP 1  @Numery = IsNull(DnV_NumerPelny, '') + ' (' + DnE_Symbol + ')' FROM CDN.DokNagProcesEtapyView
			 JOIN CDN.DokNagEtapyView ON DnPr_Typ=DnE_Typ AND DnPr_DnPrID=DnE_DnPrID
			 JOIN CDN.DokNagView ON DnPr_Typ=DnV_Typ AND DnPr_DoNID=DnV_DoNID AND (DnV_DoNID<>@DoNID OR (DnPr_Typ<>@DoNTyp AND DnPr_DoNID=DnV_DoNID))
			 WHERE  DnV_EtapBiezacyLp > 0
					AND DnE_Wykonany = 0
					AND DnE_RezerwujCzas = 1
					AND DnE_OpeId = @OpiekunId
					AND (	@DataOd > DNE_TerminOd AND @DataOd < DNE_TerminDo
						OR (@DataDo > DNE_TerminOd AND @DataDo < DNE_TerminDo)
						OR (DNE_TerminOd > @DataOd AND DNE_TerminOd < @DataDo)
						OR (DNE_TerminDo > @DataOd AND DNE_TerminDo < @DataDo) )
			ORDER BY DnV_DoNId
			SET @Komunikat = 'etapu obiegu dokumentów numer: ' + RTRIM(@Numery)
			GOTO KONIEC
		END
	END
    
    -- sprawdzam, (3) - czy termin czynności nie zachodzi na termin czynności innego zlecenia
	
	IF IsNull(@SrZId,0) <> 0
	BEGIN
		IF EXISTS(  SELECT * FROM CDN.SrsCzynnosci JOIN cdn.SrsZlecenia on SrY_SrZId = SrZ_SrZId
					WHERE
						SrZ_Bufor = 1 AND SrY_Zakonczona = 0 And SrY_SerwisantTyp = @OpiekunTyp And SrY_SerwisantID = @OpiekunId AND SrY_SrZId <> @SrZId
						AND SrY_Realizacja = 2
						AND (	@DataOd > SrY_TerminOd AND @DataOd < SrY_TerminDo
							OR (@DataDo > SrY_TerminOd AND @DataDo < SrY_TerminDo)
							OR (SrY_TerminOd > @DataOd AND SrY_TerminOd < @DataDo)
							OR (SrY_TerminDo > @DataOd AND SrY_TerminDo < @DataDo) )
				)
		BEGIN
		   SELECT TOP 1  @Numery = IsNull(SrZ_NumerPelny, '')
		   FROM CDN.SrsZlecenia JOIN CDN.SrsCzynnosci ON SrZ_SrZId = SrY_SrZId
					WHERE
						SrZ_Bufor = 1 AND SrY_Zakonczona = 0 And SrY_SerwisantTyp = @OpiekunTyp And SrY_SerwisantID = @OpiekunId AND SrY_SrZId <> @SrZId
						AND SrY_Realizacja = 2
						AND (	@DataOd > SrY_TerminOd AND @DataOd < SrY_TerminDo
							OR (@DataDo > SrY_TerminOd AND @DataDo < SrY_TerminDo)
							OR (SrY_TerminOd > @DataOd AND SrY_TerminOd < @DataDo)
							OR (SrY_TerminDo > @DataOd AND SrY_TerminDo < @DataDo) )
		   ORDER BY SrY_SrZId
		   SET @Komunikat = 'czynności dla zlecenia numer: ' + RTRIM(@Numery)
		   GOTO KONIEC
		END
	END
	ELSE
	BEGIN
		IF EXISTS(  SELECT * FROM CDN.SrsCzynnosci JOIN cdn.SrsZlecenia on SrY_SrZId = SrZ_SrZId
					WHERE
						SrZ_Bufor = 1 AND SrY_Zakonczona = 0 And SrY_SerwisantTyp = @OpiekunTyp And SrY_SerwisantID = @OpiekunId
						AND SrY_Realizacja = 2
						AND (	@DataOd > SrY_TerminOd AND @DataOd < SrY_TerminDo
							OR (@DataDo > SrY_TerminOd AND @DataDo < SrY_TerminDo)
							OR (SrY_TerminOd > @DataOd AND SrY_TerminOd < @DataDo)
							OR (SrY_TerminDo > @DataOd AND SrY_TerminDo < @DataDo) )
				)
		BEGIN
		   SELECT TOP 1  @Numery = IsNull(SrZ_NumerPelny, '')
		   FROM CDN.SrsZlecenia JOIN CDN.SrsCzynnosci ON SrZ_SrZId = SrY_SrZId
					WHERE
						SrZ_Bufor = 1 AND SrY_Zakonczona = 0 And SrY_SerwisantTyp = @OpiekunTyp And SrY_SerwisantID = @OpiekunId
						AND SrY_Realizacja = 2
						AND (	@DataOd > SrY_TerminOd AND @DataOd < SrY_TerminDo
							OR (@DataDo > SrY_TerminOd AND @DataDo < SrY_TerminDo)
							OR (SrY_TerminOd > @DataOd AND SrY_TerminOd < @DataDo)
							OR (SrY_TerminDo > @DataOd AND SrY_TerminDo < @DataDo) )
		   ORDER BY SrY_SrZId
		   SET @Komunikat = 'czynności dla zlecenia numer: ' + RTRIM(@Numery)
		   GOTO KONIEC
		END

	END
KONIEC:
    RETURN  @Komunikat
  END

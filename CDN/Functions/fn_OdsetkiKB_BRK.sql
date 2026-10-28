CREATE FUNCTION CDN.fn_OdsetkiKB_BRK
(
@BRKID    INT, -- id rozliczenia, dla którego odsetki liczymy
@OdsetkiNal   TINYINT, -- 0 - nie, 1 - tak
@OdsetkiZob   TINYINT, -- 0 - nie, 1 - tak
@OdsetkiTyp   TINYINT, -- 1 = e_op_OdsetkiTypUstawowe (ustawowe od zaległości), 2 = e_op_OdsetkiTypIndywidualne, 3 = e_op_OdsetkiTypPodatkowe, 4 - e_op_OdsetkiTypZalTrn (od zaległ. w trans. handl.)
@OdsetkiIndStopa DECIMAL(7,2) -- uwzględniane tylko jeśli @TypOdsetek = e_op_OdsetkiTypIndywidualne
)
RETURNS DECIMAL(15,2)
AS
BEGIN
/*
Założenia:
- kompensat nie uwzględniamy w ogóle (zwracamy zerowe odsetki)
- rozliczenia zdarzenie - zapis i zapis - zdarzenie uwzględniamy w zależności od BZd_Kierunek i przekazanych parametrów @OdsetkiNal, @OdsetkiZob
- dla kompensat liczymy odsetki od terminu tego zdarzenia, które ma wcześniejszą BZd_DataDok, a w przypadku równych dat - od zdarzenia przychodowego
*/
	DECLARE @retVal DECIMAL(15,2)
	DECLARE @e_op_OdsetkiTypUstawowe INT
	SET @e_op_OdsetkiTypUstawowe = 1
	DECLARE @e_op_OdsetkiTypIndywidualne INT
	SET @e_op_OdsetkiTypIndywidualne = 2
	DECLARE @e_op_OdsetkiTypPodatkowe INT
	SET @e_op_OdsetkiTypPodatkowe = 3
	DECLARE @TypL TINYINT
	DECLARE @TypP TINYINT
	DECLARE @DataRoz DATETIME
	DECLARE @Podstawa DECIMAL(15,2)
	DECLARE @KierunekL SMALLINT
	DECLARE @KierunekP SMALLINT
	DECLARE @DataDokL DATETIME
	DECLARE @DataDokP DATETIME
	DECLARE @TerminL DATETIME
	DECLARE @TerminP DATETIME
	DECLARE @NieNaliczajOdsetekL TINYINT
	DECLARE @NieNaliczajOdsetekP TINYINT

	SELECT @DataRoz = BRK_DataDok, @Podstawa = BRK_Kwota, @TypL = BRK_LDokTyp, @TypP = BRK_PDokTyp,
		@TerminL = CASE WHEN BRK_LDokTyp = 1 THEN zdL.BZd_Termin ELSE zpL.BZp_DataDok END,
		@TerminP = CASE WHEN BRK_PDokTyp = 1 THEN zdP.BZd_Termin ELSE zpP.BZp_DataDok END,
		@DataDokL = CASE WHEN BRK_LDokTyp = 1 THEN zdL.BZd_DataDok ELSE zpL.BZp_DataDok END,
		@DataDokP = CASE WHEN BRK_PDokTyp = 1 THEN zdP.BZd_DataDok ELSE zpP.BZp_DataDok END,
		@KierunekL = CASE WHEN BRK_LDokTyp = 1 THEN zdL.BZd_Kierunek ELSE zpL.BZp_Kierunek END,
		@KierunekP = CASE WHEN BRK_PDokTyp = 1 THEN zdP.BZd_Kierunek ELSE zpP.BZp_Kierunek END,
		@NieNaliczajOdsetekL = CASE WHEN BRK_LDokTyp = 1 THEN zdL.BZd_NieNaliczajOdsetek ELSE 0 END,
		@NieNaliczajOdsetekP = CASE WHEN BRK_PDokTyp = 1 THEN zdP.BZd_NieNaliczajOdsetek ELSE 0 END
	FROM cdn.BnkRozKwoty
	LEFT OUTER JOIN cdn.BnkZdarzenia zdL ON BRK_LDokTyp = 1 AND zdL.BZd_BZdID = BRK_LDokID
	LEFT OUTER JOIN cdn.DokDefinicje ddfZdL ON ddfZdL.DDf_DDfID = zdL.BZd_DDfID
	LEFT OUTER JOIN cdn.BnkZapisy zpL ON BRK_LDokTyp = 2 AND zpL.BZp_BZpID = BRK_LDokID
	LEFT OUTER JOIN cdn.DokDefinicje ddfZpL ON ddfZpL.DDf_DDfID = zpL.BZp_DDfID
	LEFT OUTER JOIN cdn.BnkZdarzenia zdP ON BRK_PDokTyp = 1 AND zdP.BZd_BZdID = BRK_PDokID
	LEFT OUTER JOIN cdn.DokDefinicje ddfZdP ON ddfZdP.DDf_DDfID = zdP.BZd_DDfID
	LEFT OUTER JOIN cdn.BnkZapisy zpP ON BRK_PDokTyp = 2 AND zpP.BZp_BZpID = BRK_PDokID
	LEFT OUTER JOIN cdn.DokDefinicje ddfZpP ON ddfZpP.DDf_DDfID = zpP.BZp_DDfID
	WHERE BRK_BRKID = @BRKID

	IF @TypP = @TypL
		RETURN NULL; -- kompensata - zawsze bez odsetek
	IF ((@TypL = 1 AND @TypP = 2 AND @KierunekL = 1) OR (@TypL = 2 AND @TypP = 1 AND @KierunekP = 1)) AND @OdsetkiNal = 0
		RETURN NULL; -- rozliczenie zdarzenia o kierunku przychód z zapisem podczas gdy nie uwzględniamy odsetek od należności
	IF ((@TypL = 1 AND @TypP = 2 AND @KierunekL = -1) OR (@TypL = 2 AND @TypP = 1 AND @KierunekP = -1)) AND @OdsetkiZob = 0
		RETURN NULL; -- rozliczenie zdarzenia o kierunku rozchód z zapisem podczas gdy nie uwzględniamy odsetek od zobowiązań

	DECLARE @NieNaliczajOdsetek TINYINT
	IF (@TypL = 1 AND @TypP = 2)
		SELECT @NieNaliczajOdsetek = @NieNaliczajOdsetekL
	ELSE IF (@TypL = 2 AND @TypP = 1)
		SELECT @NieNaliczajOdsetek = @NieNaliczajOdsetekP
	ELSE IF (@TypL = 1 AND @TypP = 1 AND @KierunekL = 1)
		SELECT @NieNaliczajOdsetek = @NieNaliczajOdsetekL
	ELSE IF (@TypL = 1 AND @TypP = 1 AND @KierunekP = 1)
		SELECT @NieNaliczajOdsetek = @NieNaliczajOdsetekP
	ELSE
		SELECT @NieNaliczajOdsetek = 0

	IF @NieNaliczajOdsetek <> 0
		RETURN NULL;

	DECLARE @Termin DATETIME
	IF (@TypL = 1 AND @TypP = 2)
		SELECT @Termin = @TerminL
	ELSE IF (@TypL = 2 AND @TypP = 1)
		SELECT @Termin = @TerminP
	ELSE IF (@TypL = 1 AND @TypP = 1)
	BEGIN
		IF (@TerminL < @TerminP)
			SELECT @Termin = @TerminL
		ELSE IF (@TerminP < @TerminL)
			SELECT @Termin = @TerminP
		ELSE
		BEGIN
			IF @KierunekL = 1
				SELECT @Termin = @TerminL
			ELSE
				SELECT @Termin = @TerminP
		END
	END

	IF @DataRoz < @Termin
		RETURN NULL

	SELECT @Termin = cdn.fn_GetWorkingDayAfter(@Termin)

	IF @Podstawa > 0
	BEGIN
		IF @OdsetkiTyp = @e_op_OdsetkiTypIndywidualne
		BEGIN
			SET @retVal = @Podstawa * @OdsetkiIndStopa * DATEDIFF(day, @Termin, @DataRoz) / 36500.00
		END
		ELSE
		BEGIN
			DECLARE @OdsetkiKnf table (Od DATETIME, Do DATETIME, Stopa DECIMAL(15,2))
			INSERT @OdsetkiKnf SELECT KOKBV_OkresOd, KOKBV_OkresDo, CAST(REPLACE(KOKBV_Stopa, ',', '.') AS DECIMAL(7,2)) FROM cdn.KnfOdsetkiKBView
			WHERE KOKBV_Typ = @OdsetkiTyp AND
			KOKBV_OkresOd <= @DataRoz AND KOKBV_OkresDo > @Termin
			ORDER BY KOKBV_OkresOd

			DECLARE @Od DATETIME
			DECLARE @Do DATETIME
			DECLARE @Stopa DECIMAL(15,2)
			DECLARE @Odsetki DECIMAL(15,2)
			SET @Odsetki = 0
			DECLARE @days INT
			DECLARE c CURSOR LOCAL FAST_FORWARD FOR
			SELECT Od, Do, Stopa FROM @OdsetkiKnf
			OPEN c
			WHILE 1=1
			BEGIN
				FETCH NEXT FROM c INTO @Od, @Do, @Stopa
				IF @@fetch_status <> 0
					BREAK

				SET @Do = @Do - 1

				DECLARE @dOd DATETIME
				DECLARE @dDo DATETIME

				IF @Od > @Termin
				BEGIN
					SET @dOd = @Od
					IF @Do >= @DataRoz
						SET @dDo = @DataRoz
					ELSE
						SET @dDo = @Do
				END
				ELSE
				BEGIN
					SET @dOd = @Termin + 1
					IF @Do >= @DataRoz
						SET @dDo = @DataRoz
					ELSE
						SET @dDo = @Do
				END

				SET @days = DATEDIFF(day, @dOd, @dDo) + 1
				SET @Odsetki = @Odsetki + (@Podstawa * @Stopa * @days / 36500.00)
			END
			CLOSE c
			DEALLOCATE c
			SET @Odsetki = ROUND(@Odsetki, 2)
			SET @retVal = @Odsetki
		END
	END

 -- rozliczenie zdarzenia rozchodowego (zobowiązanie) zapisem ma zwrócić ujemne odsetki
	IF ((@TypL = 1 AND @TypP = 2 AND @KierunekL = -1) OR (@TypL = 2 AND @TypP = 1 AND @KierunekP = -1))
	SELECT @retVal = -@retVal

	RETURN @retVal
END

CREATE FUNCTION CDN.fn_OdsetkiKB
(
@BZdID    INT, -- id zdarzenia, dla którego odsetki liczymy
@naDzien   DATETIME, -- na jaki dzień mają być liczone odsetki
@OdsetkiTyp   TINYINT, -- 1 = e_op_OdsetkiTypUstawowe (ustawowe od zaległości), 2 = e_op_OdsetkiTypIndywidualne, 3 = e_op_OdsetkiTypPodatkowe, 4 - e_op_OdsetkiTypZalTrn (od zaległ. w trans. handl.)
@OdsetkiIndStopa DECIMAL(7,2) -- uwzględniane tylko jeśli @TypOdsetek = e_op_OdsetkiTypIndywidualne
)
RETURNS DECIMAL(15,2)
AS

BEGIN
	DECLARE @e_op_OdsetkiTypUstawowe INT
	SET @e_op_OdsetkiTypUstawowe = 1
	DECLARE @e_op_OdsetkiTypIndywidualne INT
	SET @e_op_OdsetkiTypIndywidualne = 2
	DECLARE @e_op_OdsetkiTypPodatkowe INT
	SET @e_op_OdsetkiTypPodatkowe = 3
	DECLARE @BRKID INT
	DECLARE @Termin DATETIME
	DECLARE @DataRoz DATETIME
	DECLARE @Podstawa DECIMAL(15,2)
	DECLARE @NieNaliczajOdsetek TINYINT
	SET @DataRoz = @naDzien
	SELECT @BRKID = 0, @Termin = BZd_Termin, @Podstawa = BZd_Kwota - BZd_KwotaRoz, @NieNaliczajOdsetek = CASE WHEN BZd_NieNaliczajOdsetek Is Null Then 0 ELSE BZd_NieNaliczajOdsetek END
	FROM cdn.BnkZdarzenia
	WHERE BZd_BZdID = @BZdID AND BZd_Termin < @naDzien AND BZd_Stan > 0AND BZd_Rozliczono <> 0 AND BZd_Kwota - BZd_KwotaRoz > 0
	IF @NieNaliczajOdsetek <> 0
		RETURN NULL

	IF @DataRoz < @Termin
		RETURN NULL

	SELECT @Termin = cdn.fn_GetWorkingDayAfter(@Termin)

	DECLARE @retVal DECIMAL(15,2)

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

				DECLARE @dOd DATETIME
				DECLARE @dDo DATETIME

				SET @Do = @Do - 1

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
	RETURN @retVal
END

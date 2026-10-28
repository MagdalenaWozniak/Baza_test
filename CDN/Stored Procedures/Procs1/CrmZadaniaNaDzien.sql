CREATE PROCEDURE CDN.CrmZadaniaNaDzien
@OpiekunTyp AS INT,
@OpiekunId  AS INT,
@Date  AS DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	Declare @Licznik Int
	Set @Licznik = 0
	Declare @Zadania Table (Data VarChar(10), Dzien VarChar(3), Typ VarChar(4), Link Int, Zadanie VarChar(50), Poczatek VarChar(5), Koniec VarChar(5), Status VarChar(10)) --, Primary Key(Data, Link))
    While @Licznik < 7
    Begin
        Insert InTo @Zadania
        (
            Data,
            Dzien,
            Typ,
            Link,
            Zadanie,
            Poczatek,
            Koniec,
            Status
            )
        Select DISTINCT
            Convert (VarChar(10), @Date, 120),
            Case ((DATEPART(dw, @Date) + @@DATEFIRST-2) % 7 + 1) When 1 Then 'pn' When 2 Then 'wt' When 3 Then 'śr' When 4 Then 'cz' When 5 Then 'pt' When 6 Then 'so' When 7 Then 'nd' End,
			'CRM',
            CRK_CRKId,
            Case CRK_Temat When '' Then Convert (NVarChar(50), CRK_Opis) Else Convert (NVarChar(50), CRK_Temat) End,
			CASE WHEN CrC_CrCId IS NULL THEN
				CASE WHEN CRK_TerminOd < @Date				THEN '06:00'
					 WHEN DATEPART(hh, CRK_TerminOd) < 6	THEN '06:00'
					 ELSE Substring ( Convert(VarChar(16), CRK_TerminOd, 120), 12, 5) END
			ELSE
				CASE WHEN CRC_TerminOd < @Date				THEN '06:00'
					 WHEN DATEPART(hh, CRC_TerminOd) < 6	THEN '06:00'
					 ELSE Substring ( Convert(VarChar(16), CRC_TerminOd, 120), 12, 5) END
			END,
			CASE WHEN CrC_CrCId IS NULL THEN
				CASE WHEN CRK_TerminDo > DateAdd(Day, 1, @Date)	Then '20:59'
					 WHEN DATEPART(hh, CRK_TerminDo) > 20		Then '20:59'
					 ELSE Substring ( Convert(VarChar(16), CRK_TerminDo, 120), 12, 5) END
			ELSE
				CASE WHEN CRC_TerminDo > DateAdd(Day, 1, @Date)	Then '20:59'
					 WHEN DATEPART(hh, CRC_TerminDo) > 20		Then '20:59'
					 ELSE Substring ( Convert(VarChar(16), CRC_TerminDo, 120), 12, 5) END
			END,
			CASE WHEN CrC_CrCId IS NULL THEN
				CASE WHEN CRK_Bufor=0 Then 'done'
					WHEN CRK_Bufor=1 AND IsNull(CRK_ParId, 0)=0	Then 'parent'
					WHEN CRK_Bufor=1 AND IsNull(CRK_ParId, 0)>0	Then 'child'
					ELSE 'in process' End
			ELSE
				CASE WHEN CRC_Bufor=0 THEN 'done'
					WHEN CRC_Bufor=1  THEN 'parent'
					ELSE 'in process' END
			END
        FROM CDN.CRMKontakty
        JOIN CDN.CrmUczestnicy ON CrU_CrkId = CrK_CrKId
        LEFT JOIN CDN.CrmKontaktyCykl ON CrC_CrKId = CrK_CrKId AND CRC_Bufor = 1 AND CRC_Aktywny = 1 AND CDN.CrmCzasPozaZakresem(CRC_TerminOd, CRC_TerminDo)=0
        WHERE CRK_Zadanie = 1
			And CRK_Bufor > -1
            And CRU_PodmiotTyp = @OpiekunTyp
            And CRU_PodmiotId  = @OpiekunId
			AND (   (CRC_CRCID IS NULL AND CRK_TerminOd < DateAdd(day, 1, @Date) And CRK_TerminDo > @Date And CDN.CrmCzasPozaZakresem(CRK_TerminOd, CRK_TerminDo)=0 )
			OR  (CRC_CRCID IS NOT NULL AND CRC_TerminOd < DateAdd(day, 1, @Date) And CRC_TerminDo > @Date And CDN.CrmCzasPozaZakresem(CRC_TerminOd, CRC_TerminDo)=0 ))

		UNION
        Select
            Convert (VarChar(10), @Date, 120),
            Case ((DATEPART(dw, @Date) + @@DATEFIRST-2) % 7 + 1) When 1 Then 'pn' When 2 Then 'wt' When 3 Then 'śr' When 4 Then 'cz' When 5 Then 'pt' When 6 Then 'so' When 7 Then 'nd' End,
			'SRS',
            SrY_SrYId,
            SrY_TwrNazwa,
            Case
                When SrY_TerminOd < @Date                   Then '06:00'
                When DATEPART(hh, SrY_TerminOd) < 6         Then '06:00'
                Else Substring ( Convert(VarChar(16), SrY_TerminOd, 120), 12, 5) End,
            Case
                When SrY_TerminDo > DateAdd(Day, 1, @Date)  Then '20:59'
                When DATEPART(hh, SrY_TerminDo) > 20        Then '20:59'
                Else Substring ( Convert(VarChar(16), SrY_TerminDo, 120), 12, 5) End,
            Case
				When SrY_Zakonczona=1 Then 'srsdone'
				Else 'srs' End
FROM cdn.SrsCzynnosci JOIN cdn.SrsZlecenia on SrY_SrZId = SrZ_SrZId
WHERE
	SrZ_Bufor > -1
	AND SrY_Realizacja = 2     --wg terminu
	AND SrY_RezerwujCzas = 1
            And SrY_SerwisantTyp = @OpiekunTyp
            And SrY_SerwisantID = @OpiekunId
            And SrY_TerminOd < DateAdd(day, 1, @Date)
            And SrY_TerminDo > @Date
            And CDN.CrmCzasPozaZakresem(SrY_TerminOd, SrY_TerminDo)=0
		UNION
        Select
            Convert (VarChar(10), @Date, 120),
            Case ((DATEPART(dw, @Date) + @@DATEFIRST-2) % 7 + 1) When 1 Then 'pn' When 2 Then 'wt' When 3 Then 'śr' When 4 Then 'cz' When 5 Then 'pt' When 6 Then 'so' When 7 Then 'nd' End,
			'SEK' + LTrim(RTrim(Str(DnV_Typ))),
            DnPr_DnPrId,
            DnE_Nazwa,
            Case
                When DnE_TerminOd < @Date                   Then '06:00'
                When DATEPART(hh, DnE_TerminOd) < 6         Then '06:00'
                Else Substring ( Convert(VarChar(16), DnE_TerminOd, 120), 12, 5) End,
            Case
                When DnE_TerminDo > DateAdd(Day, 1, @Date)  Then '20:59'
                When DATEPART(hh, DnE_TerminDo) > 20        Then '20:59'
                Else Substring ( Convert(VarChar(16), DnE_TerminDo, 120), 12, 5) End,
            Case
				When DnV_EtapBiezacyLp=-1 Then 'sekdone'
				Else 'sek' End
		FROM cdn.DokNagProcesEtapyView
		JOIN cdn.DokNagEtapyView on DnE_Typ = DnPr_Typ and DnE_DnPrID = DnPr_DnPrId and DnE_OpeID = @OpiekunId
		JOIN cdn.DokNagView  on DnPr_Typ = DnV_Typ and DnPr_DoNId = DnV_DoNId and DnPr_Lp = DnV_EtapBiezacyLp
		WHERE
			DnE_Wykonany = 0
			And DnE_RezerwujCzas = 1
            And @OpiekunTyp = 8
            And DnE_TerminOd < DateAdd(day, 1, @Date)
            And DnE_TerminDo > @Date
            And CDN.CrmCzasPozaZakresem(DnE_TerminOd, DnE_TerminDo)=0

        If Not Exists (Select * From @Zadania Where Convert(DATETIME,Data,120)  = @Date)
            Insert InTo @Zadania
            (
            Data,
            Dzien,
            Typ,
            Link,
            Zadanie,
            Poczatek,
            Koniec,
            Status
            )
            Values
            (
            Convert (VarChar(10), @Date, 120),
            Case ((DATEPART(dw, @Date) + @@DATEFIRST-2) % 7 + 1) When 1 Then 'pn' When 2 Then 'wt' When 3 Then 'śr' When 4 Then 'cz' When 5 Then 'pt' When 6 Then 'so' When 7 Then 'nd' End,
            'CRM',
            0,
            '',
            '06:00',
            '20:59',
            ''
            )

        Set @Licznik = @Licznik + 1
        Set @Date = DateAdd (day, 1, @Date)
    End

 	Select * From @Zadania Order By Data, Poczatek, Link
END

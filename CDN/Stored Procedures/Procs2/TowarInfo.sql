CREATE  PROCEDURE CDN.TowarInfo
 @TrE_TypDokumentu INT,
    @TrN_Rodzaj       INT,
 @TrN_FVMarza      INT,
 @Twr_TwrId        INT
AS
SELECT Twr_typ,Twr_EdycjaNazwy,Twr_EdycjaOpisu,Twr_TwcNumer,1,1,Twr_JM,'',Twr_KosztUslugi,Twr_KosztUslugiTyp,
 CASE
     WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_StawkaZak
     WHEN @TrN_FVMarza=1 Then 0
     ELSE Twr_Stawka
    END AS Twr_Stawka,
    CASE
     WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_FlagaZak
     WHEN @TrN_FVMarza=1 Then 4
     ELSE Twr_Flaga
    END AS Twr_Flaga,
    CASE
     WHEN @TrE_TypDokumentu IN ( 301, 303, 307, 309, 350, 310, 317, 321, 322, 313 ) and @TrN_Rodzaj <> 322000 THEN Twr_ZrodlowaZak
     ELSE Twr_Zrodlowa
    END AS Twr_Zrodlowa,
   Twr_Nazwa,Twr_TypMinimum,Twr_MinCenaMarza,Twr_Kaucja,Twr_Kod,Twr_JMCalkowite, Twr_NumerKat, Twr_KosztKGO,
   case when Twr_Akcyza = 0 then 1 else  Twr_AkcyzaJMPomPrzelicznikL end as Twr_AkcyzaJMPomPrzelicznikL,
   case when Twr_Akcyza = 0 then 1 else  Twr_AkcyzaJMPomPrzelicznikM end as Twr_AkcyzaJMPomPrzelicznikM,
   Twr_PobieranieSkladnikowFSUslugaZlozona, Twr_CenaZCzteremaMiejscami
   FROM Cdn.Towary WHERE Twr_TwrId=@Twr_TwrId

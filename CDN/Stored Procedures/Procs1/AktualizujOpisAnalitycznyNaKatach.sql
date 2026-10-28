CREATE procedure CDN.AktualizujOpisAnalitycznyNaKatach
@AccId int = NULL,
@Guid nvarchar(255) = NULL
As
 declare @dokumentTyp int = 0;
 select @dokumentTyp = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Konto księgowe';
 WITH Konta AS (
  SELECT Acc_AccId as AccId from CDN.Konta where Acc_AccId = @AccId
  UNION ALL
  SELECT A.Acc_AccId as AccId from CDN.Konta A join Konta on (Konta.AccId= A.Acc_ParId)
 )
 delete from CDN.WymiaryWartosci where WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId in (select AccId from Konta where AccId <> @AccId);
 WITH Konta AS (
  SELECT Acc_AccId as AccId from CDN.Konta where Acc_AccId = @AccId
  UNION ALL
  SELECT A.Acc_AccId as AccId from CDN.Konta A join Konta on (Konta.AccId= A.Acc_ParId)
 )
 insert into CDN.WymiaryWartosci (WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, WyW_DokumentId, WyW_Procent, WyW_Kwota, WyW_SlownikId)
 SELECT WyW_WyyId, WyW_Guid, WyW_Wartosc, @dokumentTyp, AccId, WyW_Procent, WyW_Kwota, WyW_SlownikId
 FROM CDN.WymiaryWartosci join Konta on (WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId = @AccId)
 where AccId <> @AccId
 order by WyW_WyWId;

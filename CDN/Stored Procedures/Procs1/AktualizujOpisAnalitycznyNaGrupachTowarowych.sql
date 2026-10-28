CREATE procedure CDN.AktualizujOpisAnalitycznyNaGrupachTowarowych
@Id int = NULL,
@Guid nvarchar(255) = NULL
As
 declare @dokumentTyp int = 0;
 select @dokumentTyp = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Grupy towarowe';
 declare @gid int = 0;
 SELECT @gid = TwG_GIDNumer from CDN.TwrGrupy where TwG_GIDTyp = -16 and TwG_TwGId = @Id;
 WITH Slownik AS (
  SELECT TwG_GIDNumer as ID, TwG_TwGId from CDN.TwrGrupy where TwG_GIDTyp = -16 and TwG_GIDNumer = @gid
  UNION ALL
  SELECT A.TwG_GIDNumer as ID, A.TwG_TwGId from CDN.TwrGrupy A join Slownik on (Slownik.ID= A.TwG_GrONumer) where A.TwG_GIDTyp = -16
 )
 delete from CDN.WymiaryWartosci where WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId in (select TwG_TwGId from Slownik where ID <> @gid);
 WITH Slownik AS (
  SELECT TwG_GIDNumer as ID,TwG_TwGId from CDN.TwrGrupy where TwG_GIDTyp = -16 and TwG_GIDNumer = @gid
  UNION ALL
  SELECT A.TwG_GIDNumer as ID, A.TwG_TwGId from CDN.TwrGrupy A join Slownik on (Slownik.ID= A.TwG_GrONumer) where A.TwG_GIDTyp = -16
 )
 insert into CDN.WymiaryWartosci (WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, WyW_DokumentId, WyW_Procent, WyW_Kwota, WyW_SlownikId)
 SELECT WyW_WyyId, WyW_Guid, WyW_Wartosc, @dokumentTyp, TwG_TwGId, WyW_Procent, WyW_Kwota, WyW_SlownikId
 FROM CDN.WymiaryWartosci join Slownik on (WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId = @Id)
 where ID <> @gid
 order by WyW_WyWId;

CREATE   PROCEDURE CDN.KRo_AktualizujStatusRozrachunku
@DokTyp  int,
@DokID  int
AS
    SET NOCOUNT ON
 BEGIN TRANSACTION
 if @DokTyp = 1 and @DokID is not NULL  -- dekrety
 begin
  alter table CDN.DekretyElem disable trigger DekretyElem_DeleteHandler
  alter table CDN.DekretyElem disable trigger DekretyElem_InsertUpdateDelete_Trigger
  alter table CDN.DekretyElem disable trigger DekretyElem_InsertUpdateHandler
  update CDN.DekretyElem set DeE_StatusRozrachunku = 0 where DeE_Rozrachunki is NULL and DeE_DeEID = @DokID
  update CDN.DekretyElem set DeE_StatusRozrachunku = 0 where DeE_Rozrachunki = 0 and DeE_DeEID = @DokID
  if exists (select * from CDN.KsiRozrachunki where KRo_Typ = 1 and KRo_DeEID = @DokID and KRo_SumRozliczen = 0.00 and KRo_SumRozliczenWal = 0.00)
   update CDN.DekretyElem set DeE_StatusRozrachunku = 1 where DeE_Rozrachunki = 1 and DeE_DeEID = @DokID
  if exists (select * from CDN.KsiRozrachunki where KRo_Typ = 1 and KRo_DeEID = @DokID and (KRo_SumRozliczen <> 0.00 and KRo_SumRozliczen <> KRo_KwotaDok or KRo_SumRozliczenWal <> 0.00 and KRo_SumRozliczenWal <> KRo_KwotaDokWal))
   update CDN.DekretyElem set DeE_StatusRozrachunku = 2 where DeE_Rozrachunki = 1 and DeE_DeEID = @DokID
  if exists (select * from CDN.KsiRozrachunki where KRo_Typ = 1 and KRo_DeEID = @DokID and (KRo_SumRozliczen <> 0.00 and KRo_SumRozliczen = KRo_KwotaDok or KRo_SumRozliczenWal <> 0.00 and KRo_SumRozliczenWal = KRo_KwotaDokWal))
   update CDN.DekretyElem set DeE_StatusRozrachunku = 3 where DeE_Rozrachunki = 1 and DeE_DeEID = @DokID
  alter table CDN.DekretyElem enable trigger DekretyElem_DeleteHandler
  alter table CDN.DekretyElem enable trigger DekretyElem_InsertUpdateDelete_Trigger
  alter table CDN.DekretyElem enable trigger DekretyElem_InsertUpdateHandler
 end
 --else
 --if @DokTyp = 2  -- bilanse
 --begin
 --end
 if @@TranCount<>0 COMMIT
  SET NOCOUNT OFF

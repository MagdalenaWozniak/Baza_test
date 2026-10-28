CREATE TABLE [CDN].[PracNieobec] (
    [PNB_PnbId]             INT            IDENTITY (1, 1) NOT NULL,
    [PNB_PraId]             INT            NOT NULL,
    [PNB_TnbId]             INT            NULL,
    [PNB_TyuId]             INT            NOT NULL,
    [PNB_ParentId]          INT            NULL,
    [PNB_Tryb]              TINYINT        NULL,
    [PNB_NaPodstPoprzNB]    TINYINT        NOT NULL,
    [PNB_OkresOd]           DATETIME       NOT NULL,
    [PNB_Seria]             NVARCHAR (10)  NOT NULL,
    [PNB_Numer]             NVARCHAR (20)  NOT NULL,
    [PNB_OkresDo]           DATETIME       NOT NULL,
    [PNB_Opis]              NVARCHAR (253) NOT NULL,
    [PNB_RozliczWDniu]      TINYINT        NULL,
    [PNB_RozliczData]       DATETIME       NULL,
    [PNB_KodNieobecnosci]   NVARCHAR (4)   NULL,
    [PNB_ZwolnWystawione]   DATETIME       NULL,
    [PNB_ZwolnDostarczone]  DATETIME       NULL,
    [PNB_PomnZasilek]       TINYINT        NULL,
    [PNB_PrzedluzenieOZ]    TINYINT        NULL,
    [PNB_KontynuacjaOZ]     TINYINT        NULL,
    [PNB_PierwszyDzienChor] TINYINT        NULL,
    [PNB_UrlopNaZadanie]    TINYINT        NOT NULL,
    [PNB_Przyczyna]         INT            NOT NULL,
    [PNB_DniPracy]          INT            NOT NULL,
    [PNB_DniKalend]         INT            NOT NULL,
    [PNB_Calodzienna]       INT            NOT NULL,
    [PNB_Godz]              DATETIME       NULL,
    [PNB_WymiarL]           INT            NULL,
    [PNB_WymiarM]           INT            NULL,
    [PNB_ZlecZasilekPIT]    TINYINT        CONSTRAINT [DF_PNB_ZlecZasilekPIT] DEFAULT ((0)) NOT NULL,
    [PNB_OpeZalId]          INT            NULL,
    [PNB_StaZalId]          INT            NULL,
    [PNB_TS_Zal]            DATETIME       NOT NULL,
    [PNB_OpeModId]          INT            NULL,
    [PNB_StaModId]          INT            NULL,
    [PNB_TS_Mod]            DATETIME       NOT NULL,
    [PNB_Zrodlo]            TINYINT        CONSTRAINT [DF_PNB_Zrodlo] DEFAULT ((0)) NOT NULL,
    [PNB_PracaRodzic]       TINYINT        CONSTRAINT [DF_PNB_PracaRodzic] DEFAULT ((0)) NOT NULL,
    [PNB_Dziecko]           NVARCHAR (50)  CONSTRAINT [DF_PNB_Dziecko] DEFAULT ('') NOT NULL,
    [PNB_OpeModKod]         VARCHAR (20)   CONSTRAINT [DF_PNB_OpeModKod] DEFAULT ('') NOT NULL,
    [PNB_OpeModNazwisko]    NVARCHAR (50)  CONSTRAINT [DF_PNB_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PNB_OpeZalKod]         VARCHAR (20)   CONSTRAINT [DF_PNB_OpeZalKod] DEFAULT ('') NOT NULL,
    [PNB_OpeZalNazwisko]    NVARCHAR (50)  CONSTRAINT [DF_PNB_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [PNB_RdzId]             INT            NULL,
    CONSTRAINT [PNB_Primary] PRIMARY KEY CLUSTERED ([PNB_PnbId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PNBPraLink] FOREIGN KEY ([PNB_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE,
    CONSTRAINT [FK_PNBRdzLink] FOREIGN KEY ([PNB_RdzId]) REFERENCES [CDN].[Rodzina] ([RDZ_RdzId]),
    CONSTRAINT [FK_PNBTnbLink] FOREIGN KEY ([PNB_TnbId]) REFERENCES [CDN].[TypNieobec] ([TNB_TnbId]),
    CONSTRAINT [FK_PNBTyuLink] FOREIGN KEY ([PNB_TyuId]) REFERENCES [CDN].[TytUbezp] ([TYU_TyuId])
);


GO
CREATE NONCLUSTERED INDEX [PNBPraLink]
    ON [CDN].[PracNieobec]([PNB_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PNBTnbLink]
    ON [CDN].[PracNieobec]([PNB_TnbId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PNBTyuLink]
    ON [CDN].[PracNieobec]([PNB_TyuId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PNBParentId]
    ON [CDN].[PracNieobec]([PNB_ParentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PracNieobec_InsertUpdateTrigger
  ON CDN.PracNieobec
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
DECLARE @kalid   INT
DECLARE @PrcId    INT
DECLARE @Tryb    INT
DECLARE @Calodzienna INT
DECLARE @EtaL     DECIMAL(15,2)
DECLARE @EtaM     DECIMAL(15,2)
DECLARE @doupdate INT
DECLARE @UwzglNorme INT
DECLARE @Od    DATETIME
DECLARE @Do    DATETIME
DECLARE @NewID INT
SELECT @NewID = pnb_pnbid, @Tryb = Pnb_Tryb, @PrcId = pnb_praid, @Od = pnb_okresod, @Do = pnb_okresdo, @Calodzienna = pnb_calodzienna FROM inserted
SELECT @EtaL = pre_ETAEtatl, @EtaM = pre_ETAEtatm,@kalid = pre_kalid FROM CDN.PRACETATY WHERE Pre_PraId = @PrcId AND @Od between pre_dataod and pre_datado
SELECT @UwzglNorme = kal_UwzglWymiarEtatu, @doupdate =kal_ModPlanNB FROM CDN.Kalendarze where Kal_KalId = @kalid
 declare @d         DATETIME
 declare @tmp       INT
 set @d = @Od
 if not exists (select * from cdn.PracNieobec where PNB_PraId = @PrcId and PNB_PracaRodzic = 1 and ((PNB_OkresOd <= @Od and PNB_OkresDo >= @Od ) or (PNB_OkresOd <= @Do and PNB_OkresDo >= @Do)))
begin
 while @d<=@Do
 begin
   if @Tryb=0 AND @Calodzienna = 1 AND  EXISTS(select 1 from CDN.PracNieobec where pnb_okresod <= @d AND pnb_okresdo >= @d AND pnb_praid = @PrcId AND pnb_tryb=0 and pnb_pnbid <> @NewID)
   begin
      raiserror('Istnieje już nieobecność w podanym okresie.', 16, 1)
      rollback tran
      set nocount off
      return
   end
   set @d = @d + 1
 end
end
if @doupdate=1
begin
 declare @Czas0     datetime, @OdGodziny datetime, @DoGodziny datetime, @czasPracy decimal(15,2), @Strefa int, @DoGodzinyX  datetime, @DstPodst  int, @DstUndef  int, @LP int
 set @DstPodst = (select dst_dstid from cdn.definicjestref where dst_standardowy=1)
 set @DstUndef = (select dst_dstid from cdn.definicjestref where dst_standardowy=99)
 set @d = @Od
 while @d<=@Do
 begin
  if exists (select 1 from cdn.kalenddni where kad_kalid=@kalid and kad_data=@d)
   and not exists (select 1 from cdn.pracplandni where ppl_praid = @PrcId and ppl_data=@d)
  begin
   insert into cdn.pracplandni (ppl_praid, ppl_data, ppl_typdnia, ppl_ts_zal, ppl_ts_mod, ppl_opezalid, ppl_opemodid)
    select @PrcId, @d, kad_typdnia, GetDate(), GetDate(), 1, 1
     from cdn.kalenddni where kad_kalid = @kalid and kad_data = @d
   declare @GodzId int
   declare GODZINY cursor local fast_forward for
    select kdg_kdgid, kdg_LP, kdg_odgodziny, kdg_dogodziny, kdg_strefa
     from cdn.KalendDniGodz join cdn.KalendDni on KDG_KadId = KAD_KadId
     where kad_kalid = @kalid and kad_data = @d order by kdg_lp
    open GODZINY
       while (1=1)
     begin
      fetch next from GODZINY into @GodzId, @LP, @OdGodziny, @DoGodziny, @Strefa
      if @@fetch_status <> 0 break
     if @UwzglNorme=1
      begin
       set @czasPracy  = CDN.Czas(@OdGodziny, @DoGodziny)
       set @DoGodziny = CDN.AddTime(@OdGodziny, @czasPracy)
       if @czasPracy <> 0 AND @Strefa <> @DstUndef
       begin
          set @czasPracy = ROUND((@czasPracy * @EtaL) / @EtaM, 0)
          if @LP > 1 and @DoGodziny <> @OdGodziny
              set @OdGodziny = @DoGodzinyX
          set @DoGodziny = CDN.AddTime(@OdGodziny, @czasPracy)
       end
       set @DoGodzinyX = @DoGodziny
      end
     declare @PplId int
     select @PplId = PPL_PplId from cdn.PracPlanDni where PPL_PraId = @PrcId and PPL_Data = @d
     insert into cdn.PracPlanDniGodz (PGL_PplId, PGL_LP, PGL_OdGodziny, PGL_DoGodziny, PGL_Strefa, PGL_DzlId, PGL_PrjId)
      select @PplId, @LP, @OdGodziny, @DoGodziny, @Strefa, 1, 1
       from cdn.KalendDniGodz join cdn.kalenddni on kdg_kadid = KAD_KadId
       where kad_kalid = @kalid and kad_data = @d and kdg_kdgid = @GodzId
     end
    close GODZINY
   deallocate GODZINY
  end
  if exists (select 1 from cdn.pracplandni where ppl_praid = @PrcId AND ppl_data=@d)
  begin
   update cdn.PracPlanDniGodz set
    PGL_Strefa = case when pgl_strefa = @DstUndef then @DstUndef when PGL_Strefa <> @DstPodst and exists (select 1 from CDN.DefinicjeStref where Dst_DstId = PGL_Strefa and Dst_UwzglCzasPracy = 1) then @DstPodst else PGL_Strefa end
    from cdn.PracPlanDniGodz join cdn.PracPlanDni on PGL_PplId = PPL_PplId
        where ppl_praid = @PrcId and ppl_data = @d
  end
  set @d = @d + 1
 end
end
set nocount off

GO
CREATE TRIGGER CDN.PracNieobec2WypSkladniki_Delete_Trigger
  ON CDN.PracNieobec
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.WypSkladniki
IF EXISTS (SELECT * FROM CDN.WypSkladniki JOIN deleted ON PNb_PNbId = WPS_ZrodloId
           WHERE CDN.WypSkladniki.WPS_RodzajZrodla=6)
  BEGIN
 RAISERROR('##OPT32559##', 16, 1)
    --RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą WypSkladniki). ', 16, 1)--ERR_SQL_Place_WypSkladnikiPowiazanieWPS 32559
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.PracNieobec_UpdateTrigger
  ON CDN.PracNieobec
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
if exists(select i.PNB_PnbId from inserted i
join deleted d on (i.PNB_PnbId = d.PNB_PnbId) where (i.PNB_TnbId <> d.PNB_TnbId AND i.PNB_TS_Mod = d.PNB_TS_Mod))
begin
      raiserror('Niekontrolowana próba zmiany typu nieobecności.', 16, 1)
      rollback tran
      set nocount off
      return
end
set nocount off

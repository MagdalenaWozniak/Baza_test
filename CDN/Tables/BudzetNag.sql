CREATE TABLE [CDN].[BudzetNag] (
    [BuN_BuNId]           INT             IDENTITY (1, 1) NOT NULL,
    [BuN_AccId]           INT             NOT NULL,
    [BuN_Kwota]           DECIMAL (15, 2) NOT NULL,
    [BuN_KwotaPoprzednia] DECIMAL (15, 2) NOT NULL,
    [BuN_DataDok]         DATETIME        NOT NULL,
    [BuN_Opis]            NVARCHAR (50)   NOT NULL,
    [BuN_Bufor]           TINYINT         NOT NULL,
    [BuN_Korekta]         INT             NOT NULL,
    [BuN_Finalny]         TINYINT         NOT NULL,
    [BuN_OpeZalID]        INT             NULL,
    [BuN_StaZalId]        INT             NULL,
    [BuN_TS_Zal]          DATETIME        NOT NULL,
    [BuN_OpeModID]        INT             NULL,
    [BuN_StaModId]        INT             NULL,
    [BuN_TS_Mod]          DATETIME        NOT NULL,
    [BuN_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_BuN_OpeModKod] DEFAULT ('') NOT NULL,
    [BuN_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_BuN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BuN_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_BuN_OpeZalKod] DEFAULT ('') NOT NULL,
    [BuN_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_BuN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BuN_Primary] PRIMARY KEY CLUSTERED ([BuN_BuNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [BuNDokument]
    ON [CDN].[BudzetNag]([BuN_DataDok] ASC, [BuN_Bufor] ASC, [BuN_Korekta] ASC, [BuN_Finalny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BuNKonto]
    ON [CDN].[BudzetNag]([BuN_AccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE   TRIGGER CDN.BudzetNag_InsertDelete_Trigger
  ON CDN.BudzetNag
  FOR Insert, Delete
AS
  SET NOCOUNT ON
  if exists(select * from deleted)
    begin
    if exists (SELECT * FROM deleted where deleted.BuN_Bufor=0)
      BEGIN
     exec CDN.RiseOptimaException 32583
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
      END
   if exists (select * from deleted where deleted.BuN_Korekta=1)
    begin
    --Alter Table CDN.BudzetNag Disable Trigger All
    declare @nCount int
    select @nCount = count(B.BuN_BuNID)
    from
    deleted A
    join CDN.BudzetNag B on (A.BuN_BuNId <> B.BuN_BuNId and A.BuN_AccId = B.BuN_AccId and A.BuN_Korekta=1 and B.BuN_Korekta=-1)
    if @nCount >= 1
    begin
      update CDN.BudzetNag set BuN_Korekta = 1, BuN_Finalny = 1
      from
      (select top 1 B.BuN_BuNID from deleted A
     join CDN.BudzetNag B on (A.BuN_AccId = B.BuN_AccId and A.BuN_Korekta=1 and B.BuN_Korekta=-1)
     order by B.BuN_DataDok desc, B.BuN_BuNID desc) as W
      where CDN.BudzetNag.BuN_BuNId = W.BuN_BuNID
    end
    else
      begin
      update CDN.BudzetNag set BuN_Finalny = 1
      from
      deleted A
      join CDN.BudzetNag B on (A.BuN_BuNId <> B.BuN_BuNId and A.BuN_AccId = B.BuN_AccId)
    end
     --Alter Table CDN.BudzetNag Enable Trigger All
    end
    end
  if exists(select * from inserted)
   begin
    if exists( select * from inserted inner join CDN.BudzetNag BuN on (BuN.BuN_BuNID <> inserted.BuN_BuNID and BuN.BuN_AccId = inserted.BuN_AccId and BuN.BuN_Bufor=1))
   begin
    exec CDN.RiseOptimaException 32584
       ROLLBACK TRAN
       SET NOCOUNT OFF
       RETURN
   end
   --Alter Table CDN.BudzetNag Disable Trigger All
   update CDN.BudzetNag set BuN_Korekta = -1, BuN_Finalny = 0
   from
   inserted A
   join CDN.BudzetNag B on (A.BuN_BuNId <> B.BuN_BuNId and A.BuN_AccId = B.BuN_AccId and B.BuN_Korekta=1)
   update CDN.BudzetNag set BuN_Finalny = 0
   from
   inserted A
   join CDN.BudzetNag B on (A.BuN_BuNId <> B.BuN_BuNId and A.BuN_AccId = B.BuN_AccId and B.BuN_Korekta=0)
   update CDN.BudzetNag set BuN_Finalny = 1
   from
   inserted A
   join CDN.BudzetNag B on (A.BuN_BuNId = B.BuN_BuNId)
   --Alter Table CDN.BudzetNag Enable Trigger All
  end
  SET NOCOUNT OFF

CREATE TABLE [CDN].[DefCeny] (
    [DfC_DfCId]        INT            IDENTITY (1, 1) NOT NULL,
    [DfC_Lp]           INT            NOT NULL,
    [DfC_Nazwa]        NVARCHAR (20)  NOT NULL,
    [DfC_Aktualizacja] TINYINT        NOT NULL,
    [DfC_Marza]        DECIMAL (5, 2) NOT NULL,
    [DfC_Zaokraglenie] DECIMAL (7, 4) NOT NULL,
    [DfC_Offset]       DECIMAL (7, 4) NOT NULL,
    [DfC_Waluta]       VARCHAR (3)    NOT NULL,
    [DfC_Typ]          TINYINT        NOT NULL,
    [DfC_Nieaktywna]   SMALLINT       NULL,
    [DfC_XL_Lp]        INT            NULL,
    CONSTRAINT [DfC_Primary] PRIMARY KEY CLUSTERED ([DfC_DfCId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DfCLp]
    ON [CDN].[DefCeny]([DfC_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DefCeny_InsertUpdate_Trigger
  ON CDN.DefCeny
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  IF UPDATE (DfC_Nazwa) OR UPDATE (DfC_Nieaktywna)
    BEGIN
      IF EXISTS (
        SELECT * FROM inserted A, CDN.DefCeny B WHERE A.DfC_DfcId   != B.DfC_DfcId And A.DfC_Nazwa = B.DfC_Nazwa And IsNull(B.DfC_Nieaktywna, 0) = 0)
        BEGIN
    DECLARE @nazwa NVARCHAR(20), @message NVARCHAR(100)
          SELECT TOP 1 @nazwa = B.DfC_Nazwa FROM inserted A, CDN.DefCeny B WHERE  A.DfC_DfcId   != B.DfC_DfcId   And  A.DfC_Nazwa = B.DfC_Nazwa And  IsNull(B.DfC_Nieaktywna, 0) = 0
    SET @message = N'Już istnieje aktywna cena o nazwie: '  + @nazwa
          RAISERROR (@message, 16,1)
          ROLLBACK TRAN
          RETURN
        END
    END

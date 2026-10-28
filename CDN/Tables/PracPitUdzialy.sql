CREATE TABLE [CDN].[PracPitUdzialy] (
    [PPU_PPUID]           INT             IDENTITY (1, 1) NOT NULL,
    [PPU_PPDID]           INT             NOT NULL,
    [PPU_UdzialL]         DECIMAL (15, 3) NOT NULL,
    [PPU_UdzialM]         DECIMAL (15, 2) NOT NULL,
    [PPU_DataOd]          DATETIME        NOT NULL,
    [PPU_DataDo]          DATETIME        NOT NULL,
    [PPU_Przychody]       DECIMAL (15, 2) CONSTRAINT [DF_PPU_Przychody] DEFAULT ((0)) NOT NULL,
    [PPU_Koszty]          DECIMAL (15, 2) CONSTRAINT [DF_PPU_Koszty] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka1Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka1Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka2Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka2Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka3Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka3Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka4Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka4Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka5Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka5Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka6Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka6Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka7Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka7Przychod] DEFAULT ((0)) NOT NULL,
    [PPU_Stawka8Przychod] DECIMAL (15, 2) CONSTRAINT [DF_PPU_Stawka8Przychod] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PPU_PRIMARY] PRIMARY KEY CLUSTERED ([PPU_PPUID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PPUPPDID] FOREIGN KEY ([PPU_PPDID]) REFERENCES [CDN].[PracPitDzialalnosci] ([PPD_PPDId]) ON DELETE CASCADE
);


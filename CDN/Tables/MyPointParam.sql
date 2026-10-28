CREATE TABLE [CDN].[MyPointParam] (
    [MPP_Nazwa]     VARCHAR (50) NOT NULL,
    [MPP_Param]     INT          NOT NULL,
    [MPP_Data]      VARCHAR (80) NOT NULL,
    [MPP_Timestamp] ROWVERSION   NOT NULL,
    PRIMARY KEY CLUSTERED ([MPP_Nazwa] ASC)
);


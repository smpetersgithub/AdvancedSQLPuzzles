CREATE SCHEMA demo;
GO
--------------------------------------------------------
--------------------------------------------------------
CREATE TYPE demo.CustomersTableType AS TABLE(
	[CustomerName] [varchar](100) NOT NULL)
GO
--------------------------------------------------------
--------------------------------------------------------
CREATE TABLE demo.Customers
	(
	InsertDate DATETIME NULL DEFAULT GETDATE(),
	CustomerName VARCHAR(100) NULL
	)
GO
--------------------------------------------------------
--------------------------------------------------------
CREATE TABLE demo.CustomersMetadata
	(
	InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
	CustomerName VARCHAR(MAX),
	File_ItemName VARCHAR(MAX) NULL,
	File_ItemType VARCHAR(MAX) NULL,
	File_Size INT NULL,
	File_LastModified datetime NULL,
	File_ContentMD5 VARCHAR(MAX) NULL,
	File_Structure VARCHAR(MAX) NULL,
	File_ColumnCount INT NULL,
	File_Exists BIT NULL,
	System_DataFactoryName VARCHAR(MAX) NULL,
	System_PipelineName VARCHAR(MAX) NULL,
	System_PipelineRunId VARCHAR(MAX) NULL,
	System_PipelineTriggerType VARCHAR(MAX) NULL,
	System_PipelineTriggerId VARCHAR(MAX) NULL,
	System_PipelineTriggerName VARCHAR(MAX) NULL,
	System_PipelineTriggerTime VARCHAR(MAX) NULL,
	System_PipelineGroupID VARCHAR(MAX) NULL,
	System_PipelineTriggeredByPipelineName VARCHAR(MAX) NULL,
	System_PipelineTriggerByPipelineRunId VARCHAR(MAX) NULL
	);
GO
--------------------------------------------------------
--------------------------------------------------------
CREATE PROCEDURE demo.SpInsertCustomersTable
@pCustomersTableType demo.CustomersTableType READONLY,
@pInsertDate DATETIME
AS
BEGIN

INSERT INTO demo.Customers (InsertDate, CustomerName)
SELECT	@pInsertDate, CustomerName 
FROM	@pCustomersTableType;

END;
GO
--------------------------------------------------------
--------------------------------------------------------
CREATE OR ALTER PROCEDURE demo.SpInsertCustomersMetadata
	@pCustomersTableType demo.CustomersTableType READONLY
	,@pFile_ItemName VARCHAR(MAX) NULL
	,@pFile_ItemType VARCHAR(MAX) NULL
	,@pFile_Size INT NULL
	,@pFile_LastModified datetime NULL
	,@pFile_ContentMD5 VARCHAR(MAX) NULL
	,@pFile_Structure VARCHAR(MAX) NULL
	,@pFile_ColumnCount INT NULL
	,@pFile_Exists BIT NULL
	,@pSystem_DataFactoryName VARCHAR(MAX) NULL
	,@pSystem_PipelineName VARCHAR(MAX) NULL
	,@pSystem_PipelineRunId VARCHAR(MAX) NULL
	,@pSystem_PipelineTriggerType VARCHAR(MAX) NULL
	,@pSystem_PipelineTriggerId VARCHAR(MAX) NULL
	,@pSystem_PipelineTriggerName VARCHAR(MAX) NULL
	,@pSystem_PipelineTriggerTime VARCHAR(MAX) NULL
	,@pSystem_PipelineGroupID VARCHAR(MAX) NULL
	,@pSystem_PipelineTriggeredByPipelineName VARCHAR(MAX) NULL
	,@pSystem_PipelineTriggerByPipelineRunId VARCHAR(MAX) NULL
AS
BEGIN

INSERT INTO demo.CustomersMetadata
	(
	CustomerName
	,File_ItemName
	,File_ItemType
	,File_Size
	,File_LastModified
	,File_Contentmd5
	,File_Structure
	,File_ColumnCount
	,File_Exists
	,System_DataFactoryName
	,System_PipelineName
	,System_PipelineRunId
	,System_PipelineTriggerType
	,System_PipelineTriggerId
	,System_PipelineTriggerName
	,System_PipelineTriggerTime
	,System_PipelineGroupID
	,System_PipelineTriggeredByPipelineName
	,System_PipelineTriggerByPipelineRunId
	)
SELECT
	CustomerName
	,@pFile_ItemName
	,@pFile_ItemType
	,@pFile_Size
	,@pFile_LastModified
	,@pFile_Contentmd5
	,@pFile_Structure
	,@pFile_ColumnCount
	,@pFile_Exists
	,@pSystem_DataFactoryName
	,@pSystem_PipelineName
	,@pSystem_PipelineRunId
	,@pSystem_PipelineTriggerType
	,@pSystem_PipelineTriggerId
	,@pSystem_PipelineTriggerName
	,@pSystem_PipelineTriggerTime
	,@pSystem_PipelineGroupID
	,@pSystem_PipelineTriggeredByPipelineName
	,@pSystem_PipelineTriggerByPipelineRunId
FROM	@pCustomersTableType;

END
GO
--------------------------------------------------------
--------------------------------------------------------

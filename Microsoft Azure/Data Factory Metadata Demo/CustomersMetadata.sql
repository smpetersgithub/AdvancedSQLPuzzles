DROP TABLE IF EXISTS demo.CustomerMetadata;

CREATE TABLE demo.CustomersMetadata(
	InsertDate datetime NOT NULL DEFAULT GETDATE(),
	CustomerName VARCHAR(MAX),
	File_ItemName varchar(MAX) NULL,
	File_ItemType varchar(MAX) NULL,
	File_Size int NULL,
	File_LastModified datetime NULL,
	File_ContentMD5 varchar(MAX) NULL,
	File_Structure varchar(MAX) NULL,
	File_ColumnCount int NULL,
	File_Exists bit NULL,
	System_DataFactoryName varchar(MAX) NULL,
	System_PipelineName varchar(max) NULL,
	System_PipelineRunId varchar(max) NULL,
	System_PipelineTriggerType varchar(max) NULL,
	System_PipelineTriggerId varchar(max) NULL,
	System_PipelineTriggerName varchar(max) NULL,
	System_PipelineTriggerTime varchar(max) NULL,
	System_PipelineGroupID varchar(max) NULL,
	System_PipelineTriggeredByPipelineName varchar(max) NULL,
	System_PipelineTriggerByPipelineRundId varchar(max) NULL
);
GO
/****** Object:  StoredProcedure [demo].[SpInsertCustomersMetadata]    Script Date: 12/11/2021 11:34:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE demo.SpInsertCustomersMetadata
	--User Defined Table
	@pCustomersTableType demo.CustomersTableType READONLY
	,@pFile_ItemName varchar(MAX) NULL
	,@pFile_ItemType varchar(MAX) NULL
	,@pFile_Size int NULL
	,@pFile_LastModified datetime NULL
	,@pFile_ContentMD5 varchar(MAX) NULL
	,@pFile_Structure varchar(MAX) NULL
	,@pFile_ColumnCount int NULL
	,@pFile_Exists bit NULL
	,@pSystem_DataFactoryName varchar(MAX) NULL
	,@pSystem_PipelineName varchar(max) NULL
	,@pSystem_PipelineRunId varchar(max) NULL
	,@pSystem_PipelineTriggerType varchar(max) NULL
	,@pSystem_PipelineTriggerId varchar(max) NULL
	,@pSystem_PipelineTriggerName varchar(max) NULL
	,@pSystem_PipelineTriggerTime varchar(max) NULL
	,@pSystem_PipelineGroupID varchar(max) NULL
	,@pSystem_PipelineTriggeredByPipelineName varchar(max) NULL
	,@pSystem_PipelineTriggerByPipelineRundId varchar(max) NULL
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
	,System_PipelineTriggerByPipelineRundId
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
	,@pSystem_PipelineTriggerByPipelineRundId
FROM	@pCustomersTableType;

END
GO
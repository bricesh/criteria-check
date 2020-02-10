SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Brice Hoareau
-- Create date: 20190809
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[cust_cont_criteria_check] 
	-- Add the parameters for the stored procedure here
	@psEntryPoint	varchar(254)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	select
		a.ACTION as a,
		oa.CYCLE as cy,
		oa.CRITERIANO as c,
		dbo.fn_GetCriteriaNo(c.CASEID,'E',oa.ACTION,getdate(),null) as cc,
		oa.POLICEEVENTS as p
	into #temp_tl
	from
		cases c
		join OPENACTION oa on oa.caseid = c.caseid
		join ACTIONS a on a.ACTION = oa.ACTION
	where
		c.irn = @psEntryPoint
	order by a.ACTIONNAME

	select 'http://localhost/criteria_check/index.html#' + 
	--cast((select replace(replace(stuff((select ', ' + evt + ', ' + cast(dt as nvarchar(10)) from #temp_tl  as ce for xml path('')), 1, 2, ''), ' ', '_'), ',', '__'))  as nvarchar(max))
	--cast((select * from #temp_tl  as ce FOR XML AUTO, ELEMENTS, TYPE, ROOT('tl')) as nvarchar(max)) + '"'
	(SELECT CAST((select * from #temp_tl  as ce FOR XML AUTO, ELEMENTS, TYPE, ROOT('cr')) as varbinary(max)) FOR XML PATH(''), BINARY BASE64)
	END
GO

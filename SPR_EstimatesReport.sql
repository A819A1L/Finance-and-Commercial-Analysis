SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EstimatesReport]
AS
BEGIN

SELECT med.CustomerName as Customer_Name
      ,med.JobDescription as Job_Description
      ,med.Estimator
      ,med.TotalTotal as Sales_Price
      ,med.AgencyComPerc /100 as Agency_Com_Percent
      ,med.AgencyComValue as Agency_Com_Value
      ,med.EstimateHeaderRef as Estimate_No
      ,med.JobCreated as Job_Created
      ,mjd.JobCancelled as Job_Cancelled
      ,med.IsTemplate as Made_From_Template
      ,med.CreatedDateTime as Estimate_Created
      ,med.Ref3 as Umbrella_Co
      ,med.JobTypeDesc as Product
      ,med.Quantity
      ,med.Ref2 as KA_Team
      ,med.Ref6 as End_Customer
      ,med.Required as Required_Date
      ,med.PricePerRunOn as Sales_Price_Per_Unit
      ,med.PaperSubTot as Paper_Sub_Total
      ,med.PaperMarkUpPercent /100 as Paper_MarkUp_Percent
      ,med.PaperMarkup as Paper_Markup
      ,med.OriginMatSubTot as Studio_Mat_Sub_Total
      ,med.OriginMatMarkUpPercent /100 as Studio_Mat_MarkUp_Percent
      ,med.OriginMatMarkUp as Studio_Mat_MarkUp
      ,med.OriginLabSubTot as Studio_Lab_Sub_Total
      ,med.OriginLabMarkUpPercent /100 as Studio_Lab_MarkUp_Percent
      ,med.OriginLabMarkUp as Studio_Lab_MarkUp
      ,med.OriginLabLabSubTot as Studio_Lab_OH_Sub_Total
      ,med.OutworkSubtot as Outwork_Sub_Total
      ,med.OutworkMarkUpPercent /100 as Outwork_MarkUp_Percent
      ,med.OutworkMarkUp as Outwork_MarkUp
      ,med.OtherMatSubTotal as Other_Mat_Sub_Total
      ,med.OtherMatMarkUpPercent /100 as Other_Mat_MarkUp_Percent
      ,med.OtherMatMarkUp as Other_Mat_MarkUp
      ,med.PrintingLabSubTotal as Printing_Lab_Sub_Total
      ,med.PrintingOHSubTotal as Printing_OH_Sub_Total
      ,med.PrintingSubTotal as Printing_Sub_Total
      ,med.PrintingMarkUpPercent /100 as Printing_MarkUp_Percent
      ,med.PrintingMarkUp as Printing_MarkUp
      ,med.FinishingLabSubTotal as Finishing_Lab_Sub_Total
      ,med.FinishingOHSubTotal as Finishing_OH_Sub_Total
      ,med.FinishingSubTotal as Finishing_Sub_Total
      ,med.FinishingMarkUpPercent /100 as Finishing_MarkUp_Percent
      ,med.FinishingMarkUp as Finishing_MarkUp
      ,med.CarriageSubTotal as Carriage_Sub_Total
      ,med.CarriageMarkUpPercent /100 as Carriage_MarkUp_Percent
      ,med.CarriageMarkUp as Carriage_MarkUp
      ,med.TotalMarkUpPercent /100 as Total_MarkUp_Percent
      ,med.TotalMarkUp as Total_MarkUp
      
into #EstimatesReport

  FROM database1.dbo.MainEstimateDetails as med
  LEFT JOIN database1.dbo.MainJobDetails mjd on med.EstimateHeaderRef = mjd.EstimateHeaderRef
  WHERE med.EstimateDate >= DATEADD(day, -1, CAST(GETDATE() AS date))
  AND med.EstimateDate < CAST(GETDATE() AS date)
  AND med.Estimator NOT IN('Davies.A')

if exists (select * from #EstimatesReport where Job_Created IS NOT NULL)
    begin delete from #EstimatesReport where (Job_Cancelled  = 1)
        END
 
alter table #EstimatesReport
add Total_3rd_Party_Costs float,
    Contribution_Value float,
    Contribution_Percent float,
    Direct_Labour float,
    Gross_Margin_Value float,
    Gross_Margin_Percent float,
    Total_OH float,
    Nett_Margin_Value float,
    Nett_Margin_Percent float,
    SalesType VARCHAR(32) 

update #EstimatesReport set Total_3rd_Party_Costs = Paper_Sub_Total + Studio_Mat_Sub_Total + Outwork_Sub_Total + Other_Mat_Sub_Total + Carriage_Sub_Total
update #EstimatesReport set Contribution_Value = Sales_Price - Total_3rd_Party_Costs - Agency_Com_Value
update #EstimatesReport set Contribution_Percent = isnull(Contribution_Value / nullif(Sales_Price,0),0)
update #EstimatesReport set Direct_Labour = Printing_Lab_Sub_Total + Finishing_Lab_Sub_Total
update #EstimatesReport set Gross_Margin_Value = Contribution_Value - Direct_Labour
update #EstimatesReport set Gross_Margin_Percent = isnull(Gross_Margin_Value / nullif(Sales_Price,0),0)
update #EstimatesReport set Total_OH = Printing_OH_Sub_Total + Finishing_OH_Sub_Total + Studio_Lab_Sub_Total
update #EstimatesReport set Nett_Margin_Value = Gross_Margin_Value - Total_OH
update #EstimatesReport set Nett_Margin_Percent = isnull(Nett_Margin_Value / nullif(Sales_Price,0),0)
update #EstimatesReport set SalesType = case when Job_Created is null then 'Estimate Only' else 'Sales Order' end

select Customer_Name
      ,Job_Description
      ,Estimator
      ,Sales_Price
      ,Total_3rd_Party_Costs
      ,Agency_Com_Percent
      ,Agency_Com_Value
      ,Contribution_Value
      ,Contribution_Percent
      ,Direct_Labour
      ,Gross_Margin_Value
      ,Gross_Margin_Percent
      ,Total_OH
      ,Nett_Margin_Value
      ,Nett_Margin_Percent
      ,Estimate_No
      ,Job_Created
      ,Made_From_Template
      ,Estimate_Created
      ,Umbrella_Co
      ,Product
      ,Quantity
      ,KA_Team
      ,End_Customer
      ,Required_Date
      ,Sales_Price_Per_Unit
      ,Paper_Sub_Total
      ,Paper_MarkUp_Percent
      ,Paper_Markup
      ,Studio_Mat_Sub_Total
      ,Studio_Mat_MarkUp_Percent
      ,Studio_Mat_MarkUp
      ,Studio_Lab_Sub_Total
      ,Studio_Lab_MarkUp_Percent
      ,Studio_Lab_MarkUp
      ,Studio_Lab_OH_Sub_Total
      ,Outwork_Sub_Total
      ,Outwork_MarkUp_Percent
      ,Outwork_MarkUp
      ,Other_Mat_Sub_Total
      ,Other_Mat_MarkUp_Percent
      ,Other_Mat_MarkUp
      ,Printing_Lab_Sub_Total
      ,Printing_OH_Sub_Total
      ,Printing_Sub_Total
      ,Printing_MarkUp_Percent
      ,Printing_MarkUp
      ,Finishing_Lab_Sub_Total
      ,Finishing_OH_Sub_Total
      ,Finishing_Sub_Total
      ,Finishing_MarkUp_Percent
      ,Finishing_MarkUp
      ,Carriage_Sub_Total
      ,Carriage_MarkUp_Percent
      ,Carriage_MarkUp
      ,Total_MarkUp_Percent
      ,Total_MarkUp
      ,SalesType

from #EstimatesReport
order by SalesType desc, Customer_Name

drop table #EstimatesReport
END
     
GO

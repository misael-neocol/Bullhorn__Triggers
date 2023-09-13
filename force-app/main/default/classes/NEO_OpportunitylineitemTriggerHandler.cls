public class NEO_OpportunitylineitemTriggerHandler {
  public static OpportunityLineItem populateFields(
    OpportunityLineItem oli,
    SBQQ__QuoteLine__c quoteLine
  ) {
    oli.NEO_Effective_Start_Date__c = quoteLine.NEO_Effective_Start_Date__c;
    oli.NEO_Calculated_End_Date__c = quoteLine.SBQQ__EffectiveEndDate__c;
    oli.NEO_Year_1_ACV__c = quoteLine.NEO_Year_1_ACV__c;
    oli.NEO_Year_2_ACV__c = quoteLine.NEO_Year_2_ACV__c;
    oli.NEO_Year_3_ACV__c = quoteLine.NEO_Year_3_ACV__c;
    oli.NEO_Year_4_ACV__c = quoteLine.NEO_Year_4_ACV__c;
    oli.NEO_Year_5_ACV__c = quoteLine.NEO_Year_5_ACV__c;
    oli.Quantity = 0;
    oli.NEO_Total_Monthly_Net_Unit_Price__c = quoteLine.NEO_Total_Monthly_Net_Unit_Price__c;
    oli.TotalPrice = null;
    return oli;
  }
}

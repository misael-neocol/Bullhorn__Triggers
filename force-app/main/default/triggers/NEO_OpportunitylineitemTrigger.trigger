trigger NEO_OpportunitylineitemTrigger on OpportunityLineItem(after delete) {
  try {
    if (Trigger.isDelete && Trigger.isAfter) {
      List<OpportunityLineItem> clonedOpportunityLineItems = new List<OpportunityLineItem>();
      Id oppId;
      Id primaryQuoteId;

      oppId = Trigger.old[0].OpportunityId;

      SBQQ__Quote__c mostRecentPrimaryQuote = [
        SELECT Id
        FROM SBQQ__Quote__c
        WHERE SBQQ__Primary__c = TRUE AND SBQQ__Opportunity2__c = :oppId
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];
      primaryQuoteId = mostRecentPrimaryQuote.Id;

      Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>(
        [
          SELECT
            Id,
            NEO_Year_1_ACV__c,
            NEO_Year_2_ACV__c,
            NEO_Year_3_ACV__c,
            NEO_Year_4_ACV__c,
            NEO_Year_5_ACV__c,
            NEO_Total_Monthly_Net_Unit_Price__c,
            NEO_Effective_Start_Date__c,
            SBQQ__EffectiveEndDate__c,
            SBQQ__Quantity__c
          FROM SBQQ__QuoteLine__c
          WHERE SBQQ__Quote__c = :primaryQuoteId
        ]
      );

      for (OpportunityLineItem oli : Trigger.old) {
        SBQQ__QuoteLine__c relatedQuoteLine = quoteLineMap.get(
          oli.SBQQ__QuoteLine__c
        );

        if (
          relatedQuoteLine != null &&
          relatedQuoteLine.SBQQ__Quantity__c == 0
        ) {
          OpportunityLineItem clonedOli = oli.clone(false, false, false, false);

          clonedOli = NEO_OpportunitylineitemTriggerHandler.populateFields(
            clonedOli,
            relatedQuoteLine
          );

          clonedOpportunityLineItems.add(clonedOli);
        }
      }

      if (!clonedOpportunityLineItems.isEmpty()) {
        insert clonedOpportunityLineItems;
      }
    }
  } catch (Exception e) {
    System.debug('An error occurred: ' + e.getMessage());
  }
}

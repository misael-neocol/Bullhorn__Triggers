trigger NEO_OpportunitylineitemTrigger on OpportunityLineItem(after delete) {
  try {
    if (Trigger.isDelete && Trigger.isAfter) {
      List<OpportunityLineItem> clonedOpportunityLineItems = new List<OpportunityLineItem>();

      // Collect Opportunity Ids and Quote Line Ids from deleted Opportunity Line Items
      Set<Id> oppIds = new Set<Id>();
      Set<Id> quoteLineIds = new Set<Id>();
      for (OpportunityLineItem oli : Trigger.old) {
        oppIds.add(oli.OpportunityId);
        quoteLineIds.add(oli.SBQQ__QuoteLine__c);
      }

      System.debug('MVM-> oppIds: ' + oppIds);
      System.debug('MVM-> quoteLineIds: ' + quoteLineIds);

      // Query related Quotes based on Opportunity Ids
      List<SBQQ__Quote__c> relatedQuotes = [
        SELECT Id, SBQQ__Primary__c, SBQQ__Opportunity2__c
        FROM SBQQ__Quote__c
        WHERE SBQQ__Opportunity2__c IN :oppIds
      ];

      // Query related Quote Lines to get custom fields
      Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>(
        [
          SELECT
            Id,
            NEO_Year_1_ACV__c,
            NEO_Year_2_ACV__c,
            NEO_Year_3_ACV__c,
            NEO_Year_4_ACV__c,
            NEO_Year_5_ACV__c,
            NEO_Total_Monthly_Net_Unit_Price__c
          FROM SBQQ__QuoteLine__c
          WHERE Id IN :quoteLineIds
        ]
      );

      System.debug('MVM-> quoteLineMap: ' + quoteLineMap);

      // Create a map of Opportunity Id to Quote for easy lookup
      Map<Id, SBQQ__Quote__c> oppToQuoteMap = new Map<Id, SBQQ__Quote__c>();
      for (SBQQ__Quote__c quote : relatedQuotes) {
        oppToQuoteMap.put(quote.SBQQ__Opportunity2__c, quote);
      }

      System.debug('MVM-> oppToQuoteMap: ' + oppToQuoteMap);

      // Loop through deleted Opportunity Line Items
      for (OpportunityLineItem oli : Trigger.old) {
        SBQQ__Quote__c relatedQuote = oppToQuoteMap.get(oli.OpportunityId);

        System.debug('MVM-> relatedQuote: ' + relatedQuote);

        // Check if related Quote's SBQQ__Primary__c field is set to true
        if (relatedQuote != null && relatedQuote.SBQQ__Primary__c == true) {
          OpportunityLineItem clonedOli = oli.clone(false, false, false, false);

          System.debug('MVM-> clonedOli__Before: ' + clonedOli);

          // Populate custom fields from SBQQ__QuoteLine__c
          SBQQ__QuoteLine__c relatedQuoteLine = quoteLineMap.get(
            oli.SBQQ__QuoteLine__c
          );
          if (relatedQuoteLine != null) {
            System.debug(
              'MVM-> relatedQuoteLine.NEO_Year_1_ACV__c: ' +
              relatedQuoteLine.NEO_Year_1_ACV__c
            );
            System.debug(
              'MVM-> relatedQuoteLine.NEO_Year_2_ACV__c: ' +
              relatedQuoteLine.NEO_Year_2_ACV__c
            );
            System.debug(
              'MVM-> relatedQuoteLine.NEO_Year_3_ACV__c: ' +
              relatedQuoteLine.NEO_Year_3_ACV__c
            );
            System.debug(
              'MVM-> relatedQuoteLine.NEO_Year_4_ACV__c: ' +
              relatedQuoteLine.NEO_Year_4_ACV__c
            );
            System.debug(
              'MVM-> relatedQuoteLine.NEO_Year_5_ACV__c: ' +
              relatedQuoteLine.NEO_Year_5_ACV__c
            );

            clonedOli.NEO_Year_1_ACV__c = relatedQuoteLine.NEO_Year_1_ACV__c;
            clonedOli.NEO_Year_2_ACV__c = relatedQuoteLine.NEO_Year_2_ACV__c;
            clonedOli.NEO_Year_3_ACV__c = relatedQuoteLine.NEO_Year_3_ACV__c;
            clonedOli.NEO_Year_4_ACV__c = relatedQuoteLine.NEO_Year_4_ACV__c;
            clonedOli.NEO_Year_5_ACV__c = relatedQuoteLine.NEO_Year_5_ACV__c;
            clonedOli.Quantity = 0;
            clonedOli.NEO_Total_Monthly_Net_Unit_Price__c = relatedQuoteLine.NEO_Total_Monthly_Net_Unit_Price__c; // MRR
            clonedOli.TotalPrice = null;
          }

          System.debug('MVM-> clonedOli__After: ' + clonedOli);

          // Add the cloned Opportunity Line Item to the list
          clonedOpportunityLineItems.add(clonedOli);

          System.debug(
            'MVM-> clonedOpportunityLineItems__After: ' +
            clonedOpportunityLineItems
          );
        }
      }

      // Insert cloned Opportunity Line Items if any
      if (clonedOpportunityLineItems.size() > 0) {
        System.debug(
          'MVM-> clonedOpportunityLineItems.size(): ' +
          clonedOpportunityLineItems.size()
        );
        System.debug(
          'MVM-> clonedOpportunityLineItems: ' + clonedOpportunityLineItems
        );

        insert clonedOpportunityLineItems;
      }
    }
  } catch (Exception e) {
    // Log the exception for debugging
    System.debug('An error occurred: ' + e.getMessage());
  }
}

trigger NEO_OpportunitylineitemTrigger on OpportunityLineItem (after delete) {
    try {
        if (Trigger.isDelete && Trigger.isAfter) {
            List<OpportunityLineItem> clonedOpportunityLineItems = new List<OpportunityLineItem>();
            Set<Id> oppIds = new Set<Id>();
            Set<Id> quoteLineIds = new Set<Id>();

            for (OpportunityLineItem oli : Trigger.old) {
                oppIds.add(oli.OpportunityId);
                quoteLineIds.add(oli.SBQQ__QuoteLine__c);
            }

            // System.debug('MVM-> oppIds: ' + oppIds);
            // System.debug('MVM-> quoteLineIds: ' + quoteLineIds);

            // Query related Quotes based on Opportunity Ids, sorted by CreatedDate
            List<SBQQ__Quote__c> relatedQuotes = [
                SELECT Id, SBQQ__Primary__c, SBQQ__Opportunity2__c, CreatedDate
                FROM SBQQ__Quote__c
                WHERE SBQQ__Primary__c = true AND SBQQ__Opportunity2__c IN :oppIds
                ORDER BY CreatedDate DESC
            ];

            // System.debug('MVM-> relatedQuotes: ' + relatedQuotes);

            // Create a map of Opportunity Id to the most recent primary Quote
            Map<Id, SBQQ__Quote__c> oppToLatestPrimaryQuoteMap = new Map<Id, SBQQ__Quote__c>();
            for (SBQQ__Quote__c quote : relatedQuotes) {
                if (!oppToLatestPrimaryQuoteMap.containsKey(quote.SBQQ__Opportunity2__c)) {
                    oppToLatestPrimaryQuoteMap.put(quote.SBQQ__Opportunity2__c, quote);
                }
            }

            // System.debug('MVM-> oppToLatestPrimaryQuoteMap: ' + oppToLatestPrimaryQuoteMap);

            // Query related Quote Lines to get custom fields
            Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([
                SELECT Id, NEO_Year_1_ACV__c, NEO_Year_2_ACV__c, NEO_Year_3_ACV__c, NEO_Year_4_ACV__c, NEO_Year_5_ACV__c, NEO_Total_Monthly_Net_Unit_Price__c, NEO_Effective_Start_Date__c, SBQQ__EffectiveEndDate__c
                FROM SBQQ__QuoteLine__c
                WHERE Id IN :quoteLineIds
            ]);

            // System.debug('MVM-> quoteLineMap: ' + quoteLineMap);

            // Loop through deleted Opportunity Line Items
            for (OpportunityLineItem oli : Trigger.old) {
                SBQQ__Quote__c relatedQuote = oppToLatestPrimaryQuoteMap.get(oli.OpportunityId);

                // System.debug('MVM-> relatedQuote: ' + relatedQuote);

                if (relatedQuote != null && relatedQuote.SBQQ__Primary__c == true) {
                    OpportunityLineItem clonedOli = oli.clone(false, false, false, false);
                    SBQQ__QuoteLine__c relatedQuoteLine = quoteLineMap.get(oli.SBQQ__QuoteLine__c);
                    if (relatedQuoteLine != null) {

                        // System.debug('MVM-> relatedQuoteLine: ' + relatedQuoteLine);

                        clonedOli.NEO_Effective_Start_Date__c = relatedQuoteLine.NEO_Effective_Start_Date__c;
                        clonedOli.NEO_Calculated_End_Date__c = relatedQuoteLine.SBQQ__EffectiveEndDate__c;
                        clonedOli.NEO_Year_1_ACV__c = relatedQuoteLine.NEO_Year_1_ACV__c;
                        clonedOli.NEO_Year_2_ACV__c = relatedQuoteLine.NEO_Year_2_ACV__c;
                        clonedOli.NEO_Year_3_ACV__c = relatedQuoteLine.NEO_Year_3_ACV__c;
                        clonedOli.NEO_Year_4_ACV__c = relatedQuoteLine.NEO_Year_4_ACV__c;
                        clonedOli.NEO_Year_5_ACV__c = relatedQuoteLine.NEO_Year_5_ACV__c;
                        clonedOli.Quantity = 0;
                        clonedOli.NEO_Total_Monthly_Net_Unit_Price__c = relatedQuoteLine.NEO_Total_Monthly_Net_Unit_Price__c;
                        clonedOli.TotalPrice = null;
                    }

                    // System.debug('MVM-> clonedOli__After: ' + clonedOli);

                    clonedOpportunityLineItems.add(clonedOli);
                }
            }

            System.debug('MVM-> clonedOpportunityLineItems__After: ' + clonedOpportunityLineItems);

            // Insert cloned Opportunity Line Items if any
            if (clonedOpportunityLineItems.size() > 0) {
                // System.debug('MVM-> clonedOpportunityLineItems.size(): ' + clonedOpportunityLineItems.size());
                insert clonedOpportunityLineItems;
            }
        }
    } catch (Exception e) {
        System.debug('An error occurred: ' + e.getMessage());
    }
}
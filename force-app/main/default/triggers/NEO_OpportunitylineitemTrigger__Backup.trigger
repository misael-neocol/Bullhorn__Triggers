trigger NEO_OpportunitylineitemTrigger on OpportunityLineItem(after delete) {
  if (Trigger.isDelete) {
    if (Trigger.isAfter) {
      list<OpportunityLineItem> ClonedOpportunityLineItems = new List<OpportunityLineItem>();
      set<id> QuoteLineIds = new Set<id>();
      for (OpportunityLineItem OpportunityLineItem : Trigger.old) {
        QuoteLineIds.add(OpportunityLineItem.SBQQ__QuoteLine__c);
      }
      Map<String, SBQQ__QuoteLine__c> QLToQuery = new Map<String, SBQQ__QuoteLine__c>(
        [
          SELECT id
          FROM SBQQ__QuoteLine__c
          WHERE
            id IN :QuoteLineIds
            AND SBQQ__Quantity__c = 0
            AND (SBQQ__Quote__r.SBQQ__Type__c = 'Renewal'
            OR SBQQ__Quote__r.Amendment_Quote_Type__c = 'Replacement Quote')
        ]
      );
      for (OpportunityLineItem OpportunityLineItem : Trigger.old) {
        if (
          QLToQuery.keyset().contains(OpportunityLineItem.SBQQ__QuoteLine__c)
        ) {
          OpportunityLineItem OpportunityLineItemToClone = OpportunityLineItem;
          OpportunityLineItem ClonedOpportunityLineItem = OpportunityLineItemToClone.clone(
            false,
            false,
            false,
            false
          );
          //MANIPULATE OPLINE HERE
          ClonedOpportunityLineItem.Quantity = 0;
          ClonedOpportunityLineItem.TotalPrice = null;
          ClonedOpportunityLineItems.add(ClonedOpportunityLineItem);
        }
      }
      if (ClonedOpportunityLineItems.size() > 0) {
        insert ClonedOpportunityLineItems;
      }
    }
  }
}

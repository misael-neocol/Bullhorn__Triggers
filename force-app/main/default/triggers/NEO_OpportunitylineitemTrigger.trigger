trigger NEO_OpportunitylineitemTrigger on OpportunityLineItem(after delete) {
    if(Trigger.isDelete && Trigger.isAfter){
        List<OpportunityLineItem> clonedOpportunityLineItems = new List<OpportunityLineItem>();
        Set<Id> quoteLineIds = new Set<Id>();
        
        // Collect Quote Line Ids from deleted Opportunity Line Items
        for(OpportunityLineItem opportunityLineItem : Trigger.old){
            quoteLineIds.add(opportunityLineItem.SBQQ__QuoteLine__c);
        }
        
        // Query Quote Lines based on collected Ids
        Map<Id, SBQQ__QuoteLine__c> qlToQuery = new Map<Id, SBQQ__QuoteLine__c>([
            SELECT Id, SBQQ__Primary__c, Year1__c, Year2__c, Year3__c, Year4__c, Year5__c 
            FROM SBQQ__QuoteLine__c 
            WHERE Id IN :quoteLineIds
        ]);
        
        // Loop through deleted Opportunity Line Items
        for(OpportunityLineItem opportunityLineItem : Trigger.old){
            SBQQ__QuoteLine__c quoteLine = qlToQuery.get(opportunityLineItem.SBQQ__QuoteLine__c);
            
            // Check if Quote Line exists and if its SP QQ primary field is set to true
            if(quoteLine != null && quoteLine.SBQQ__Primary__c == true){
                // Clone the deleted Opportunity Line Item
                OpportunityLineItem clonedOpportunityLineItem = opportunityLineItem.clone(false, false, false, false);
                
                // Reset Quantity and Total Price
                clonedOpportunityLineItem.Quantity = 0;
                clonedOpportunityLineItem.TotalPrice = null;
                
                // Populate Year 1 through Year 5 ACV values from the Quote Line Item
                clonedOpportunityLineItem.Year1__c = quoteLine.Year1__c;
                clonedOpportunityLineItem.Year2__c = quoteLine.Year2__c;
                clonedOpportunityLineItem.Year3__c = quoteLine.Year3__c;
                clonedOpportunityLineItem.Year4__c = quoteLine.Year4__c;
                clonedOpportunityLineItem.Year5__c = quoteLine.Year5__c;
                
                // Add the cloned Opportunity Line Item to the list
                clonedOpportunityLineItems.add(clonedOpportunityLineItem);
            }
        }
        
        // Insert cloned Opportunity Line Items if any
        if(clonedOpportunityLineItems.size() > 0){
            insert clonedOpportunityLineItems;
        }
    }
}

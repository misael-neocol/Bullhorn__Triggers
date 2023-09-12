@isTest
private class TestNEO_OpportunitylineitemTrigger {
    @isTest static void testAfterDelete() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        insert opp;

        // Create test Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.Id,
            SBQQ__Primary__c = true
        );
        insert quote;

        // Create test Quote Line
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            NEO_Year_1_ACV__c = 1000,
            NEO_Year_2_ACV__c = 2000,
            NEO_Year_3_ACV__c = 3000,
            NEO_Year_4_ACV__c = 4000,
            NEO_Year_5_ACV__c = 5000,
            NEO_Total_Monthly_Net_Unit_Price__c = 6000
        );
        insert quoteLine;

        // Create test Opportunity Line Item
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            SBQQ__QuoteLine__c = quoteLine.Id,
            UnitPrice = 100,
            Quantity = 1
        );
        insert oli;

        // Delete Opportunity Line Item to trigger the logic
        Test.startTest();
        delete oli;
        Test.stopTest();

        // Validate the cloned Opportunity Line Item
        List<OpportunityLineItem> clonedOpportunityLineItems = [
            SELECT Id, NEO_Year_1_ACV__c, NEO_Year_2_ACV__c, NEO_Year_3_ACV__c, NEO_Year_4_ACV__c, NEO_Year_5_ACV__c, Quantity, NEO_Total_Monthly_Net_Unit_Price__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id
        ];

        System.assertEquals(1, clonedOpportunityLineItems.size(), 'Expected one cloned Opportunity Line Item');
        OpportunityLineItem clonedOli = clonedOpportunityLineItems[0];
        System.assertEquals(1000, clonedOli.NEO_Year_1_ACV__c);
        System.assertEquals(2000, clonedOli.NEO_Year_2_ACV__c);
        System.assertEquals(3000, clonedOli.NEO_Year_3_ACV__c);
        System.assertEquals(4000, clonedOli.NEO_Year_4_ACV__c);
        System.assertEquals(5000, clonedOli.NEO_Year_5_ACV__c);
        System.assertEquals(0, clonedOli.Quantity);
        System.assertEquals(6000, clonedOli.NEO_Total_Monthly_Net_Unit_Price__c);
    }
}
    
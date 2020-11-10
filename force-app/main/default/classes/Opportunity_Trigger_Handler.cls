public class Opportunity_Trigger_Handler {
    Public static void addProductsError(List<Opportunity> oppList){
        Set<Id> oppId=new Set<Id>();
        for(Opportunity opp:oppList){
            oppId.add(opp.id);
        }
        List<OpportunityLineItem> proList=[Select id,OpportunityId from OpportunityLineItem where OpportunityId In: oppId];
        for(Opportunity opp:oppList){
            if((opp.StageName=='Send To Plant' || opp.StageName=='Sample Ready' || opp.StageName=='Closed Won') && proList.isEmpty()){
                opp.addError(system.label.Add_Products_Opportunity);
            }
        }
        
        
    }
    Public static void createQuote(List<Opportunity> oppList){
        Set<Id> setoppId=new Set<Id>();
        List<Quote> quoList=new List<Quote>();
        Map<String,String> recordTypeMap=new Map<String,String>();
        recordTypeMap.put('Actual Opportunity','Actual Quote');
        recordTypeMap.put('Sample Opportunity','Sample Quote');
        for(Opportunity opp:oppList){
            setoppId.add(opp.id);
            Quote quo=new Quote();
            quo.OpportunityId=opp.id;
            quo.Name=opp.Name;
            quo.recordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get(recordTypeMap.get(opp.RecordTypeName__c)).getRecordTypeId();
            quoList.add(quo);
        }
        insert quoList;
        Map<Id,Id> quoIdMap=new Map<ID,ID>();
        for(Quote quo:quoList){
            quoIdMap.put(quo.OpportunityId,quo.id);
        }
        List<OpportunityLineItem> proList=[Select id,Product2Id,OpportunityId,ServiceDate,Description,ListPrice,UnitPrice,Quantity,PricebookEntryId from OpportunityLineItem where OpportunityId In: setoppId];
        for(OpportunityLineItem oppLineItem:proList){
            QuoteLineItem quoItem=new QuoteLineItem();
            quoItem.QuoteId=quoIdMap.get(oppLineItem.OpportunityId);
            quoItem.Product2Id=oppLineItem.Product2Id;
            quoItem.UnitPrice=oppLineItem.UnitPrice;
            quoItem.Quantity=oppLineItem.Quantity;
            quoItem.PricebookEntryId=oppLineItem.PricebookEntryId;
            quoItem.ServiceDate=oppLineItem.ServiceDate;
            quoItem.Description=oppLineItem.Description;
            insert quoItem;
        }
        for(Opportunity opp:oppList){
            opp.Quote_Hidden_CheckBox__c=True;
        }
    }
    
}
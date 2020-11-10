trigger Opportunity_Trigger on Opportunity (before update,after update) {
    If(Trigger.IsBefore && Trigger.isUpdate){
        Opportunity_Trigger_Handler.addProductsError(Trigger.new);
        for(Opportunity opp:Trigger.new){
            if(opp.StageName=='Closed Won' && opp.Quote__c==True && opp.Quote_Hidden_CheckBox__c==False ){
                Opportunity_Trigger_Handler.createQuote(Trigger.new);
            }   
        }
        
    }
}
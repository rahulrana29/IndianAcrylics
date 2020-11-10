trigger QuoteTrigger on Quote (before insert, before update) {
    if(Trigger.isbefore){
        if(Trigger.isInsert){
            QuoteTriggerHandler.beforeBankAdd(Trigger.new);
        }
        if(Trigger.isUpdate){
            QuoteTriggerHandler.beforeBankAdd(Trigger.new);
            QuoteTriggerHandler.sendEmailToCustomer(Trigger.new);
        }
    }
}
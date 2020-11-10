public class QuoteTriggerHandler {
    public static void beforeBankAdd(list<Quote>quotelist){ 
        map<id, quote> quoMap = new map<id, quote>();
        list<Quote> qutlist = new list<Quote>();
        for(Quote Quo: quotelist){
            if(Quo.Bank_Name__c <> 'Other' && Quo.Bank_Name__c <> null){
                quoMap.put(Quo.id, Quo);
            }
        }
        system.debug('quoMap'+quoMap);
        if(quoMap.size() >0){
            Banks_detail__mdt threatMappings = [SELECT MasterLabel, Bank_info__c ,QualifiedApiName FROM Banks_detail__mdt where MasterLabel = : quoMap.values().Bank_Name__c];
            system.debug('threatMappings'+threatMappings);
            
            for(Quote Quo: quotelist){
                if(Quo.Bank_Name__c <> 'Other' && Quo.Bank_Name__c <> null){
                    Quo.Our_Banker_s_Address__c = threatMappings.Bank_info__c;
                    system.debug('qutt.Our_Banker_s_Address__c'+ Quo.Our_Banker_s_Address__c);
                }
            }
        }    
    }
    
    public static void sendEmailToCustomer(list<Quote>quotelist){ 
        Set<Id> quoteIds = New Set<Id>();
        for(Quote Quo: quotelist){
            if(Quo.Status == 'Sample Dispatched'){
                quoteIds.add(Quo.Id);
            }
        }
        //Get your document from quote document Object
        Set<Id> contentVersionIds = New Set<Id>();
        List<QuoteDocument> quoteDocumentList = [SELECT Id, ContentVersionDocumentId FROM QuoteDocument WHERE QuoteId IN : quoteIds];
        for(QuoteDocument quotedoc : quoteDocumentList){
            contentVersionIds.add(quotedoc.ContentVersionDocumentId);
        }
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
        List<ContentVersion> documentList = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND Id IN :contentVersionIds];
        if(documentList.size() > 0){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(documentList[0].VersionData);
            attachment.setFileName(documentList[0].Title + '.' + documentList[0].FileType);
            attachments.add(attachment);
        }
        // Set the message template
        //List<EmailTemplate> templateList = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName =: 'When_Quote_Dispatched_Send_Email_To_Customer'];
        
        List<EmailTemplate> templates = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'When_Quote_Dispatched_Send_Email_To_Customer'];
        for(Quote quoterec : [SELECT Id, Email, Courier_Details__c FROM Quote WHERE Id IN : quoteIds]){
            
            //Apex Single email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { quoterec.Email });//Set To Email Address
            /*if(!templateList.isEmpty()) {
                mail.setTemplateId(templateList[0].Id);
                mail.setSubject(templateList[0].Subject);
                mail.setHtmlBody(templateList[0].HtmlValue);
             }*/
            mail.setSubject('Dispatch Details');//Set Subject
            
            String body = 'Hello ';
            body += 'Your Courier has been dispatched.';
            body += 'Courier Details : '+ quoterec.Courier_Details__c +'. ';
            body += 'Please find the attachment.';
            mail.setHtmlBody(body);
            if(attachments.size() > 0){
                mail.setFileAttachments(attachments);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
        }
    }
    
}
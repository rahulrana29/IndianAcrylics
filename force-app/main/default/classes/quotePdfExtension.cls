public class quotePdfExtension {
    public String currentRecordId {get;set;}
    public  list<TableWrapper> QuoteWrapperList{ get; set;}
    public quotePdfExtension(ApexPages.StandardController controller){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        system.debug('id'+currentRecordId);
        List<QuoteLineItem> quoteList=[SELECT Id, LineNumber, QuoteId, Quantity, UnitPrice, Discount, ServiceDate, Product2Id,Product2.Name, ListPrice, TotalPrice FROM QuoteLineItem where QuoteId=:currentrecordId];
        QuoteWrapperList =new List<TableWrapper>();
        if(!quoteList.isEmpty()){
            for(QuoteLineItem quote:quoteList){
                TableWrapper ObjWrapper = new TableWrapper();
                ObjWrapper.ProductName=quote.Product2.Name;
                ObjWrapper.QuoteItem=quote.LineNumber;
                ObjWrapper.ListPrice=quote.ListPrice;
                ObjWrapper.SalesPrice=quote.UnitPrice;
                ObjWrapper.Quantity=quote.Quantity;
                ObjWrapper.Discount=quote.Discount;
                ObjWrapper.TotalPrice=quote.TotalPrice;
                QuoteWrapperList.add(ObjWrapper);
            }
            
        }
        
    }
    public class TableWrapper{
        public string ProductName{get;set;}
        public string QuoteItem{get;set;}
        public Decimal ListPrice{get;set;}
        public Decimal SalesPrice{get;set;}
        public Decimal Quantity{get;set;}
        public Decimal Discount{get;set;}
        public Decimal TotalPrice{get;set;}
    }
    
        @auraEnabled 
    public static void savePDFQuote(string recordId){
        system.debug('inside pdf');
        PageReference pdfPage = new PageReference('/apex/quotePDF');
        pdfPage.getParameters().put('Id',recordId);
        String quotationName  = [SELECT Id, Name FROM Quote WHERE Id =: recordId].Name;
        ContentVersion cont = new ContentVersion();
        cont.Title = quotationName +'-'+ date.today();
        cont.PathOnClient = 'file.pdf';
        if (!Test.isRunningTest()) { //if we are not in testing context
            cont.VersionData = pdfPage.getContentAsPdf();//generate the pdf blob 
        } else { //otherwise, we are in testing create the blob manually 
            cont.VersionData=Blob.valueOf('Some Text');
        }
        cont.Origin = 'H';
        insert cont; 
        ContentVersion contentVersionn = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cont.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = recordId;
        contentlink.contentdocumentid = contentVersionn.contentdocumentid;
        contentlink.ShareType = 'V';
        system.debug(contentlink);
        insert contentlink; 
    }
}
public class QuotePdfPageExtension {
    public boolean checkGSTtype{get; set;}
    public string currencyType{get; set;}
    public recordWrapper WrapperList {get; set;}
    public QuotePdfPageExtension(ApexPages.StandardController stdController) {
        
        Id recId = apexpages.currentpage().getparameters().get('Id');
        String queryQuote = 'SELECT Id, TotalPrice, Total_Price_Including_GST__c, CurrencyIsoCode, ShippingState FROM Quote';  
        queryQuote += ' where Id =\'' + recId +'\' ';
        Quote quoteRecord = Database.query(queryQuote);
        String query = 'SELECT Id, QuoteId, UnitPrice, Discount, Quantity, Product2.Name, TotalPrice, GST_Price__c, Product_Category__c FROM QuoteLineItem';  
        query += ' where QuoteId =\'' + recId +'\' ';
        List<QuoteLineItem> qliList = Database.query(query);
        
        currencyType = quoteRecord.CurrencyIsoCode;
        recordWrapper wrapRec = New recordWrapper();
        List<qliWrapper> qlist = New List<qliWrapper>(); 
        Decimal tquantity = 0;
        for(QuoteLineItem qli : qliList){
            tquantity += qli.Quantity;
            String pname    = qli.Product2.Name;
            Decimal quantity    = qli.Quantity;
            Decimal discount    = qli.Discount;
            String gst;
            if(quoteRecord.ShippingState != null && quoteRecord.ShippingState == 'Punjab' && qli.Product_Category__c == 'Yarn'){
                gst   = '6% + 6%';
            }else if(quoteRecord.ShippingState != null && quoteRecord.ShippingState != 'Punjab' && qli.Product_Category__c == 'Yarn'){
                gst   = '12%';
            }else if(quoteRecord.ShippingState != null && quoteRecord.ShippingState == 'Punjab' && qli.Product_Category__c == 'Fibre'){
                gst   = '9% + 9%';
            }else if(quoteRecord.ShippingState != null && quoteRecord.ShippingState != 'Punjab' && qli.Product_Category__c == 'Fibre'){
                gst   = '18%';
            }else{
                gst   = '0%';
            }
            Decimal price;
            if(quoteRecord.ShippingState != '' && quoteRecord.ShippingState != null){
                price  = qli.GST_Price__c;
            }else{
                price  = qli.TotalPrice;
            }
            Decimal MRP  = qli.TotalPrice;
            qliWrapper qrec = New qliWrapper(pname, gst, quantity, discount, price, MRP);
            qlist.add(qrec); 
        }
        if(quoteRecord.ShippingState != '' && quoteRecord.ShippingState != null && quoteRecord.ShippingState == 'Punjab'){
            checkGSTtype = true; 
            wrapRec.Final_Price  = quoteRecord.Total_Price_Including_GST__c;
            Decimal toRoundFinal_Price = wrapRec.Final_Price;    
            Decimal roundedFinal_Price = toRoundFinal_Price.setScale(0);
            Integer_to_String wordCS = new Integer_to_String();
            wrapRec.Final_Price_Word = wordCS.numtoword1(String.valueOf(roundedFinal_Price));
            wrapRec.qliList = qlist;
            WrapperList = wrapRec;
        }else if(quoteRecord.ShippingState != '' && quoteRecord.ShippingState != null && quoteRecord.ShippingState != 'Punjab'){
            checkGSTtype = false; 
            wrapRec.Final_Price  = quoteRecord.Total_Price_Including_GST__c;
            Decimal toRoundFinal_Price = wrapRec.Final_Price;    
            Decimal roundedFinal_Price = toRoundFinal_Price.setScale(0);
            Integer_to_String wordCS = new Integer_to_String();
            wrapRec.Final_Price_Word = wordCS.numtoword1(String.valueOf(roundedFinal_Price));
            wrapRec.qliList = qlist;
            WrapperList = wrapRec;
        }else{
            wrapRec.Final_Price  = quoteRecord.TotalPrice;
            Decimal toRoundFinal_Price = wrapRec.Final_Price;    
            Decimal roundedFinal_Price = toRoundFinal_Price.setScale(0);
            Integer_to_String wordCS = new Integer_to_String();
            wrapRec.Final_Price_Word = wordCS.numtoword1(String.valueOf(roundedFinal_Price));
            wrapRec.qliList = qlist;
            WrapperList = wrapRec;
        }
        
    }
    
    public class qliWrapper{
        Public string Product_Name {get;set;}
        Public String GST {get;set;}
        Public Decimal Quantity {get;set;}
        Public Decimal Discount {get;set;}
        Public Decimal Price {get;set;}
        Public Decimal MRP {get;set;}
        Public qliWrapper(String Product_Name, String GST,  Decimal Quantity,  Decimal Discount, Decimal Price, Decimal MRP){
            this.Product_Name  = Product_Name;
            this.GST  = GST;
            this.Quantity  = Quantity;
            this.Discount  = Discount;
            this.Price  = Price;
            this.MRP  = MRP;
        }
    }
    public class recordWrapper{
        Public Decimal Final_Price {get;set;}
        public String Final_Price_Word {get;set;}
        public List<qliWrapper> qliList {get;set;}
    }
    @auraEnabled 
    public static void savePDFQuote(string recordId){
        system.debug('inside pdf');
        PageReference pdfPage = new PageReference('/apex/generateQuotePdf');
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
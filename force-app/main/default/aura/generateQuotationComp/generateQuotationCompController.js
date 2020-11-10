({
    cancleClick: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    savePDF: function(component, event, helper) {
         var recordId =  component.get("v.recordId");
        console.log("recordId"+recordId);
        var action = component.get("c.savePDFQuote");
        action.setParams({  recordId : recordId  });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        })
        $A.enqueueAction(action);
    }
})
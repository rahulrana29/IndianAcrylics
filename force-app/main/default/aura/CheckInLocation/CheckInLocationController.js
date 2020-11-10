({   
    doInit : function(component,event,helper){ 
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(success);
            function success(position) {
                var lat = position.coords.latitude;
                component.set("v.userLatitude",lat);
                var long = position.coords.longitude;
                component.set("v.userLongitude",long);
                var recId = component.get("v.recordId");
                var sobj = component.get("v.sobjecttype");
                if(sobj == 'Event'){
                  var action = component.get("c.startLocation");  
                }
                if(sobj == 'Account'){
                   var action = component.get("c.startLocation");
                }
                if(sobj == 'Enquiry__c'){
                   var action = component.get("c.startLocation");
                }
                
                action.setParams({
                    latitude : component.get("v.userLatitude"),
                    longitude: component.get("v.userLongitude"),
                    recordId: component.get("v.recordId"),
                    sobj : sobj
                });   
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(component.isValid() && state == "SUCCESS"){
                        var c = response.getReturnValue();
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({                            
                            "title": "Success!",
                            "type":"success",
                            "message": "Checked In successfully."
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                    
                    else {
                        console.log('There was a problem : '+response.getError());
                    }
                });
                $A.enqueueAction(action); 
            }
        } else {
            error('Geo Location is not supported');
        }
        
        
    }
})
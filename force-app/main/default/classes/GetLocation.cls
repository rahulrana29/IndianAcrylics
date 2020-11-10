public class GetLocation {
    @AuraEnabled
    public static void startLocation(Decimal latitude, decimal longitude, Id recordId,String sobj){
        if(sobj == 'Account'){
            Account accList = [Select Id,Start_Location__Latitude__s,Start_Location__Longitude__s  From Account Where Id =:recordId];
            accList.Start_Location__Latitude__s = latitude;
            accList.Start_Location__Longitude__s = longitude;
            update accList;
        }
    }
    @AuraEnabled
    public static void endLocation(Decimal latitude, decimal longitude, Id recordId,String sobj){
        if(sobj == 'Account'){
            /*Account accList = [Select Id,End_Location__Latitude__s,End_Location__Longitude__s  From Account Where Id =:recordId];
            accList.End_Location__Latitude__s = latitude;
            accList.End_Location__Longitude__s = longitude;
            update accList;*/
        }
    }
}
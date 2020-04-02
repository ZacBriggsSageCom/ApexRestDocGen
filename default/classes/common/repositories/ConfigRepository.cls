/**
 * Class for handling the Global Configuration custom setting.
 */
public class ConfigRepository {

    /**
     * Gets or creates the singleton Global Configuration instance.
     */
    public static Global_Configuration__c getGlobalConfig() {
        List<Global_Configuration__c> configs = [
            SELECT CreatedDate,
                Aligned_Objectives_Enabled__c,
                Company_Objective_Options__c,
                Objective_Category_Options__c,
                Objective_Priority_Options__c,
                Suppress_Emails__c
            FROM Global_Configuration__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        return configs.isEmpty()
                ? new Global_Configuration__c()
                : configs.get(0);
    }

}
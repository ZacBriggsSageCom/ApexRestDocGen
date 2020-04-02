public class PolicyEditController {

    private final ApexPages.StandardController stdController;

    private final fHCM2__Policy__c pol;

    private final fHCM2__Policy__c polBeforeEdit;

    public PolicyEditController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        
        pol = (fHCM2__Policy__c) stdController.getRecord();
        polBeforeEdit = [
            SELECT Id,
                Conversations_Is_Active__c,
                Objectives_Is_Active__c
            FROM fHCM2__Policy__c
            WHERE Id = :pol.Id
        ];
    }

    public PageReference save() {

        // Conversations cannot be disabled if Objectives is enabled
        if (polBeforeEdit.Conversations_Is_Active__c == true
                && pol.Conversations_Is_Active__c != true
                && pol.Objectives_Is_Active__c == true) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    Label.Error_Cant_Disable_Conversations));
            return null;
        }

        // Objectives cannot be enabled if Conversations is disabled
        if (pol.Conversations_Is_Active__c != true
                && pol.Objectives_Is_Active__c == true) {
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    Label.Error_Objectives_Requires_Conversations));
            return null;
        }

        return stdController.save();
    }

}
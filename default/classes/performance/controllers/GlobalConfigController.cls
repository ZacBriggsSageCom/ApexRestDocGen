public class GlobalConfigController {

    public static GlobalConfigResponseModel getGlobalConfig() {

        Global_Configuration__c cfg = ConfigRepository.getGlobalConfig();
        GlobalConfigModel cfgModel = new GlobalConfigModel();

        cfgModel.companyObjectiveOptions =
                createSelectOptions(cfg.Company_Objective_Options__c);

        cfgModel.objectiveCategoryOptions =
                createSelectOptions(cfg.Objective_Category_Options__c);

        cfgModel.objectivePriorityOptions =
                createSelectOptions(cfg.Objective_Priority_Options__c);

        cfgModel.policies = createPolicyModels();

        return new GlobalConfigResponseModel(cfgModel);
    }

    @TestVisible
    private static List<OptionModel> createSelectOptions(String optionsStr) {

        List<OptionModel> options = new List<OptionModel>();

        if (!String.isBlank(optionsStr)) {
            String[] lines = optionsStr.split('\r\n');
            for (String line : lines) {
                options.add(new OptionModel(line, line, false));
            }
        }

        return options;
    }

    @TestVisible
    private static List<PolicyModel> createPolicyModels() {

        Viewport view = new Viewport();

        // Produce a list of all relevant TM IDs
        Set<Id> tmIds = new Set<Id> { view.getViewerTeamMemberId() };
        tmIds.addAll(view.getDirectReportIds());
        
        // Retrieve the Team Members
        List<fHCM2__Team_Member__c> tms = TeamMemberRepository.get(tmIds);

        // Extract the Policy IDs from each Team Member
        Set<Id> policyIds = new Set<Id>();
        for (fHCM2__Team_Member__c tm : tms) {
            policyIds.add(TeamMemberUtils.getPolicyId(tm));
        }

        // Retrieve the Policies
        List<fHCM2__Policy__c> policies = PolicyRepository.get(policyIds);

        // Create a Model for each Policy
        List<PolicyModel> models = new List<PolicyModel>();
        for (fHCM2__Policy__c policy : policies) {
            PolicyModel policyModel = new PolicyModel();
            policyModel.policyId = policy.Id;
            policyModel.conversationsEnabled = policy.Conversations_Is_Active__c;
            policyModel.objectivesEnabled = policy.Objectives_Is_Active__c;
            models.add(policyModel);
        }

        return models;
    }

}
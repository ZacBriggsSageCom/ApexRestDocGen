@SuppressWarnings('PMD.AvoidGlobalModifier')
global class PostInstallClass implements InstallHandler {

    global void onInstall(InstallContext context) {
        migrateLegacyFeedback();
        registerProcess();
        registerProcessViews();
    }

    /**
     * Migrates now-deprecated Feedback Items to the new Comment format.
     *
     * This will only affect customers who installed the very first Performance
     * Management package, before the notion of Conversations was introduced.
     *
     *     Team Member Feedback     -> Junction object no longer needed
     *      |- Feedback                 (we create a parent Conversation and
     *      |- Team Member               a Conversation Subject instead)
     *
     *     Feedback Item            -> Comment
     *      |- Author                   (the manual Created Date field also
     *      |- Author Type               needs to be set)
     *      |- Current Version
     *
     *     Feedback Version         -> Comment Version
     *      |- Content                 (the manual Created Date field also
     *      |- Feedback Item            needs to be set)
     *      |- Version
     */
    public static void migrateLegacyFeedback() {

        // Find all Team Member Feedback records
        List<Team_Member_Feedback__c> junctions = [
            SELECT Id,
                Feedback__c,
                Team_Member__c
            FROM Team_Member_Feedback__c
        ];

        if (junctions.isEmpty()) {
            // Nothing to do!
            return;
        }

        // Find all Feedback Items
        List<Feedback__c> feedbackItems = [
            SELECT
                Id,
                Author__c,
                Author_Type__c,
                CreatedDate,
                Current_Version__c
            FROM Feedback__c
        ];

        // Find all Feedback Versions
        List<Feedback_Version__c> feedbackVersions = [
            SELECT
                Id,
                CreatedDate,
                Content__c,
                Feedback_Item__c,
                Version__c
            FROM Feedback_Version__c
        ];

        // Create a map of Feedback Item ID -> Subject TM ID
        Map<Id, Id> subjectTmIdsByFeedbackId = new Map<Id, Id>();
        for (Team_Member_Feedback__c junction : junctions) {
            subjectTmIdsByFeedbackId.put(
                    junction.Feedback__c,
                    junction.Team_Member__c);
        }

        // Find all unique subject TM IDs
        Set<Id> subjectTmIds = getSubjectsFromJunctions(junctions);

        // Retrieve these Team Members, and their managers
        List<fHCM2__Team_Member__c> subjectTms = [
            SELECT Id,
                fHCM2__Manager__c
            FROM fHCM2__Team_Member__c
            WHERE Id IN :subjectTmIds
        ];

        // Create a Conversation for each subject
        List<Conversation__c> convos = new List<Conversation__c>();
        Map<Id, Conversation__c> conversationsByTmId =
                new Map<Id, Conversation__c>();
        for (Id tmId : subjectTmIds) {
            Conversation__c convo = new Conversation__c();
            convos.add(convo);
            conversationsByTmId.put(tmId, convo);
        }
        insert convos;

        // Create a Conversation Participant for each subject and their manager
        List<Conversation_Participant__c> convoParticipants =
                getConversationParticipants(
                        subjectTms,
                        conversationsByTmId);
        insert convoParticipants;

        // Create a Conversation Subject for each subject
        List<Conversation_Subject__c> convoSubjects =
                new List<Conversation_Subject__c>();
        for (Id tmId : subjectTmIds) {
            Conversation__c convo = conversationsByTmId.get(tmId);
            Conversation_Subject__c convoSubject = new Conversation_Subject__c(
                Conversation__c = convo.Id,
                Team_Member__c = tmId
            );
            convoSubjects.add(convoSubject);
        }
        insert convoSubjects;

        // Create a Comment for each Feedback Item
        List<Comment__c> comments = new List<Comment__c>();
        Map<Id, Comment__c> commentsByFeedbackId = new Map<Id, Comment__c>();
        for (Feedback__c feedbackItem : feedbackItems) {
            Id subjectTmId = subjectTmIdsByFeedbackId.get(feedbackItem.Id);
            Conversation__c convo = conversationsByTmId.get(subjectTmId);
            Comment__c comment = new Comment__c(
                Author__c = feedbackItem.Author__c,
                Author_Type__c = feedbackItem.Author_Type__c,
                Conversation__c = convo.Id,
                Created_Date__c = feedbackItem.CreatedDate,
                Current_Version__c = feedbackItem.Current_Version__c
            );
            comments.add(comment);
            commentsByFeedbackId.put(feedbackItem.Id, comment);
        }
        insert comments;

        // Create a Comment Version for each Feedback Version
        List<Comment_Version__c> commentVersions =
                new List<Comment_Version__c>();
        for (Feedback_Version__c feedbackVersion : feedbackVersions) {
            Id feedbackId = feedbackVersion.Feedback_Item__c;
            Comment__c comment = commentsByFeedbackId.get(feedbackId);
            Comment_Version__c commentVersion = new Comment_Version__c(
                Comment__c = comment.Id,
                Content__c = feedbackVersion.Content__c,
                Created_Date__c = feedbackVersion.CreatedDate,
                Version__c = feedbackVersion.Version__c
            );
            commentVersions.add(commentVersion);
        }
        insert commentVersions;

        // Delete old records
        delete junctions;
        delete feedbackItems;
    }

    /**
     * Gets the set of subject TM IDs from Team_Member_Feedback__c records.
     */
    private static Set<Id> getSubjectsFromJunctions(
            List<Team_Member_Feedback__c> junctions) {
        Set<Id> subjectTmIds = new Set<Id>();
        for (Team_Member_Feedback__c junction : junctions) {
            subjectTmIds.add(junction.Team_Member__c);
        }
        return subjectTmIds;
    }

    /**
     * Gets the list of all Conversation Participants for each Conversation
     * (subject and manager).
     */
    private static List<Conversation_Participant__c> getConversationParticipants(
            List<fHCM2__Team_Member__c> subjectTms,
            Map<Id, Conversation__c> conversationsByTmId) {

        List<Conversation_Participant__c> convoParticipants =
                new List<Conversation_Participant__c>();

        Map<Id, fHCM2__Team_Member__c> subjectTmsById =
                new Map<Id, fHCM2__Team_Member__c>(subjectTms);

        for (Id tmId : subjectTmsById.keySet()) {
            Conversation__c convo = conversationsByTmId.get(tmId);
            fHCM2__Team_Member__c subjectTm = subjectTmsById.get(tmId);
            convoParticipants.add(new Conversation_Participant__c(
                Conversation__c = convo.Id,
                Team_Member__c = subjectTm.Id
            ));
            if (subjectTm.fHCM2__Manager__c != null) {
                convoParticipants.add(new Conversation_Participant__c(
                    Conversation__c = convo.Id,
                    Team_Member__c = subjectTm.fHCM2__Manager__c
                ));
            }
        }

        return convoParticipants;
    }

    public static void registerProcess() {
        fHCM2.HCMProcesses.getProcess('Performance Management', true)
                .setStandaloneApp(true)
                .setPackage('spperfmgmt')
                .setGroup('FairsailProfile')
                .setShowTeamMember(true)
                .setShowManager(true)
                .setUrl('Performance')
                .setVisibilityController('PerformanceVisibilityController')
                .setTilePage('PerformanceTile')
                .register();
        fHCM2.HCMProcesses.saveRegistered();
    }

    public static void registerProcessViews() {
        fHCM2.ProcessViews.register(
                'Performance Management Tile',             // View name
                'tile',                                    // View type
                'Performance Management',                  // Process
                'views/processes/standaloneapp/tile.html', // URL
                true,                                      // Is Default
                1,                                         // Number of columns
                'tile',                                    // View ID
                'Team Member',                             // Team Member or Team
                'tile',                                    // Content type
                null,                                      // Static resource
                true);                                     // Overwrite?
        fHCM2.ProcessViews.saveRegistered();
    }

}
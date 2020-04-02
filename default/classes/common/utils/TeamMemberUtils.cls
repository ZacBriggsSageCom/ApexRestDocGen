/**
 * Class containing utilities for working with Team Members.
 */
public class TeamMemberUtils {

    public static final String SELF = 'Self';
    public static final String MANAGER = 'Manager';
    public static final String DIRECT_REPORT = 'Direct Report';

    public static final String TEAM_MEMBER_TYPE = 'fHCM2__Team_Member__c';

    /**
     * Creates a PersonModel from a Team Member by ID.
     */
    public static PersonModel createPerson(Id tmId) {
        return createPerson(TeamMemberRepository.get(tmId));
    }

    /**
     * Creates a PersonModel from a Team Member.
     */
    public static PersonModel createPerson(fHCM2__Team_Member__c tm) {
        return populatePersonModel(new PersonModel(), tm);
    }

    /**
     * Populates the fields of a PersonModel.
     */
    public static PersonModel populatePersonModel(
            PersonModel model, fHCM2__Team_Member__c tm) {
        model.id = tm.Id;
        model.name = tm.Name;
        model.firstName = tm.fHCM2__First_Name__c;
        model.pictureUrl = fHCM2.UrlHelper.getFullUrl(tm.fHCM2__Picture_Url__c);
        model.policyId = getPolicyId(tm);
        return model;
    }

    /**
     * Creates a list of PersonModels from some TM IDs.
     */
    public static List<PersonModel> createPeople(Set<Id> tmIds) {
        List<fHCM2__Team_Member__c> tms = TeamMemberRepository.get(tmIds);
        return createPeople(tms);
    }

    /**
     * Creates a list of PersonModels from a list of Team Members.
     */
    public static List<PersonModel> createPeople(List<fHCM2__Team_Member__c> tms) {
        List<PersonModel> people = new List<PersonModel>();
        for (fHCM2__Team_Member__c tm : tms) {
            people.add(createPerson(tm));
        }
        return people;
    }

    /**
     * Creates a SubjectModel representing a TM.
     */
    public static SubjectModel createPersonAsSubject(Id tmId) {
        PersonModel person = createPerson(tmId);
        SubjectModel subject = new SubjectModel();
        subject.id = tmId;
        subject.name = person.name;
        subject.tmId = tmId;
        return subject;
    }

    /**
     * Find the ID of a Team Member associated with a User.
     */
    public static Id getTeamMemberId(Id userId) {
        fHCM2__Team_Member__c tm =
                TeamMemberRepository.getTeamMemberForUser(userId);
        return tm == null ? null : tm.Id;
    }

    /**
     * For some Team Members, return a list of their email addresses.
     */
    public static List<String> getUserEmailAddresses(Set<Id> tmIds) {
        List<fHCM2__Team_Member__c> tms = [
            SELECT Id, fHCM2__User__r.Email
            FROM fHCM2__Team_Member__c
            WHERE Id IN :tmIds
        ];
        List<String> emailAddresses = new List<String>();
        for (fHCM2__Team_Member__c tm : tms) {
            if (tm.fHCM2__User__c != null) {
                emailAddresses.add(tm.fHCM2__User__r.Email);
            }
        }
        return emailAddresses;
    }

    /**
     * Return the Person Model for the Viewer if it
     * has a team member id else throws an exception.
     */
    public static PersonModel getViewerPerson() {
        Id tmId = getTeamMemberId(UserInfo.getUserId());
        return createPerson(tmId);
    }

    /**
     * Creates a list of TeamMemberSummaryModels from a list of Team Members.
     */
    public static List<TeamMemberSummaryModel> createTeamMemberSummary(List<fHCM2__Team_Member__c> tms) {

        // Create objective summary models
        Map<Id, ObjectivesSummaryModel> summariesByTm  = new Map<Id, ObjectivesSummaryModel>();
        for (fHCM2__Team_Member__c tm : tms) {
            summariesByTm.put(tm.Id, new ObjectivesSummaryModel());
        }

        // Convert list to map to allow use of .keySet()
        Map<Id, fHCM2__Team_Member__c> tmsMap = new Map<Id, fHCM2__Team_Member__c>(tms);
        List<Objective__c> activeObjectives = ObjectiveRepository.getActiveForTeamMembers(tmsMap.keySet());

        for (Objective__c objective : activeObjectives) {
            summariesByTm.get(objective.Team_Member__c).activeObjectives++;
        }

        // Create, populate and return TM summary models
        List<TeamMemberSummaryModel> teamMemberSummaryModels = new List<TeamMemberSummaryModel>();

        for (fHCM2__Team_Member__c tm : tms) {
            TeamMemberSummaryModel model = new TeamMemberSummaryModel();
            model.teamMember = createPerson(tm);
            model.objectivesSummary = summariesByTm.get(tm.Id);

            teamMemberSummaryModels.add(model);
        }

        return teamMemberSummaryModels;
    }

    /**
     * Gets the Policy ID of a Team Member.
     */
    public static Id getPolicyId(fHCM2__Team_Member__c tm) {
        // Use the explicit policy, if set, else the department policy
        return tm.fHCM2__Policy__c == null
                ? tm.fHCM2__Department__r.fHCM2__Policy__c
                : tm.fHCM2__Policy__c;
    }

    /**
     * Given some TMs, returns a list of their managers.
     */
    public static List<fHCM2__Team_Member__c> getManagersOf(
            List<fHCM2__Team_Member__c> reports) {
        Set<Id> managerIds = new Set<Id>();
        for (fHCM2__Team_Member__c report : reports) {
            managerIds.add(report.fHCM2__Manager__c);
        }
        return TeamMemberRepository.get(managerIds);
    }
}
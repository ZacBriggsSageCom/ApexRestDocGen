/**
 * Class containing utility methods for Team Member operations.
 */
public class TeamMemberRepository {

    /**
     * Gets a TM by ID. Will return all fields we might need.
     */
    public static fHCM2__Team_Member__c get(Id tmId) {
        List<fHCM2__Team_Member__c> tms = [
            SELECT
                Id,
                Name,
                fHCM2__User__c,
                fHCM2__First_Name__c,
                fHCM2__Manager__c,
                fHCM2__Picture_URL__c,
                fHCM2__Policy__c,
                fHCM2__Department__r.fHCM2__Policy__c
            FROM fHCM2__Team_Member__c
            WHERE Id = :tmId
        ];
        return tms.isEmpty() ? null : tms.get(0);
    }

    /**
     * Gets all TMs whose IDs appear in the given set. Will return all fields we
     * might need.
     */
    public static List<fHCM2__Team_Member__c> get(Set<Id> tmIds) {
        return [
            SELECT
                Id,
                Name,
                fHCM2__User__c,
                fHCM2__First_Name__c,
                fHCM2__Manager__c,
                fHCM2__Picture_URL__c,
                fHCM2__Policy__c,
                fHCM2__Department__r.fHCM2__Policy__c
            FROM fHCM2__Team_Member__c
            WHERE Id IN :tmIds
            ORDER BY Name
        ];
    }

    /**
     * Return the TM with the given User ID.
     */
    public static fHCM2__Team_Member__c getTeamMemberForUser(Id userId) {
        List<fHCM2__Team_Member__c> tms = [
            SELECT
                Id,
                Name,
                fHCM2__User__c,
                fHCM2__First_Name__c,
                fHCM2__Picture_URL__c,
                fHCM2__Policy__c,
                fHCM2__Department__r.fHCM2__Policy__c
            FROM fHCM2__Team_Member__c
            WHERE fHCM2__User__c = :userId
        ];
        return tms.isEmpty() ? null : tms.get(0);
    }

    /**
     * Find all TMs whose user IDs appear in the given set.
     */
    public static List<fHCM2__Team_Member__c> getTeamMembersForUsers(Set<Id> userIds) {
        List<fHCM2__Team_Member__c> tms = [
            SELECT
                Id,
                Name,
                fHCM2__User__c,
                fHCM2__First_Name__c,
                fHCM2__Picture_URL__c,
                fHCM2__Policy__c,
                fHCM2__Department__r.fHCM2__Policy__c
            FROM fHCM2__Team_Member__c
            WHERE fHCM2__User__c IN :userIds
        ];
        return tms;
    }

    /**
     * Fetches a given Team Member's primary manager.
     */
    public static fHCM2__Team_Member__c getPrimaryManager(Id tmId) {
        Id managerId = [
            SELECT Id, fHCM2__Manager__c
            FROM fHCM2__Team_Member__c
            WHERE Id = :tmId
            LIMIT 1
        ].fHCM2__Manager__c;
        return get(managerId);
    }

    /**
     * Fetches the direct reports for a manager, ordered by name.
     */
    public static List<fHCM2__Team_Member__c> getDirectReports(Id managerId) {
        return [
            SELECT
                Id,
                Name,
                fHCM2__User__c,
                fHCM2__First_Name__c,
                fHCM2__Picture_URL__c,
                fHCM2__Policy__c,
                fHCM2__Department__r.fHCM2__Policy__c
            FROM fHCM2__Team_Member__c
            WHERE fHCM2__Manager__r.Id = :managerId
            ORDER BY Name
        ];

    }

    /**
     * Return a list of TMs whose name are 'like' a given string
     */
    public static List<fHCM2__Team_Member__c> searchByName(String name) {
        String queryName = '%' + name + '%';
        return [
            SELECT
                Id,
                Name,
                fHCM2__User__c,
                fHCM2__First_Name__c,
                fHCM2__Picture_URL__c,
                fHCM2__Policy__c,
                fHCM2__Department__r.fHCM2__Policy__c
            FROM fHCM2__Team_Member__c
            WHERE Name LIKE :queryName
            ORDER BY Name
        ];
    }

}
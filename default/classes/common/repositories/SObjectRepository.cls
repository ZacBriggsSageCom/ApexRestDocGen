/**
 * Class containing utilities for handling sObject records.
 */
@SuppressWarnings('PMD.ApexSOQLInjection')
public class SObjectRepository {

    /**
     * Determine whether a record of the given Id and type exists.
     *
     * @param id
     * @param recordType
     * @return Boolean
     */
    public static Boolean doesRecordExist(String id, String sObjectType) {

        // Guard against invalid or unsafe "Id" values
        if (!SObjectUtils.isValidId(id)) {
            return false;
        }

        String queryString =
                'SELECT Id'
                + ' FROM ' + sObjectType
                + ' WHERE Id = \'' + id + '\'';
        return Database.query(queryString).size() == 1;
    }

}

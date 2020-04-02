/**
 * Class containing utilities for dealing with sObjects.
 */
public class SObjectUtils {

    /**
     * Check whether an Id is valid and of the given type.
     *
     * @param objId
     * @param type
     * @return Boolean
     */
    public static Boolean isValidSObject(String objId, String type) {
        return isValidId(objId) && isOfType(objId, type);
    }

    /**
     * Check whether an Id in String form is valid.
     *
     * @param objId
     * @return Boolean
     */
    public static Boolean isValidId(String objId) {
        Boolean isValid;

        try {
            if (!String.isBlank(objId)) {
                Id.valueOf(objId);
                isValid = true;
            } else {
                isValid = false;
            }
        } catch (Exception e) {
            isValid = false;
        }

        return isValid;
    }

    /**
     * Check whether the supplied object Id is of the type supplied.
     *
     * @param objId
     * @param type
     * @return Boolean
     */
    public static Boolean isOfType(Id objId, String type) {
        return getTypeNameOf(objId) == type;
    }

    /**
     * Return the API Name of a record's type, by Id.
     *
     * @param recordId
     * @return String
     */
    public static String getTypeNameOf(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    /**
     * Gets the IDs from a list of SObjects.
     *
     * If you have a list of a specific record type, you need to cast it, e.g.
     * SObjectUtils.getIds((List<SObject>) myList);
     *
     * @param records
     * @return Set<Id>
     */
    public static Set<Id> getIds(List<SObject> records) {
        return new Map<Id, SObject>(records).keySet();
    }

}

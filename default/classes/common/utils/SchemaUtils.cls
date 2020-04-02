/**
 * Utility methods for retrieving schema data.
 *
 * Adapted from Compensation Planning.
 */
public class SchemaUtils {
    
    /**
     * Gets the field map for an SObject.
     *
     * The object name should both include the namespace and custom object
     * extension. They are case-insensitive.
     *
     * Returns null if the schema is not found.
     */
    public static Map<String, Schema.SObjectField> getFieldMap(String sObjectName) {
        // Fun fact: the global describe map and subsequent field maps are the
        // only maps in Apex that use case-insensitive keys.
        Schema.SObjectType objSchema =
                Schema.getGlobalDescribe().get(sObjectName);
        if (objSchema == null) {
            System.debug(LoggingLevel.WARN, 'No schema found for ' + sObjectName);
            return null;
        }
        return objSchema.getDescribe().fields.getMap();
    }

    /**
     * Gets the DescribeFieldResult for the given and object name and field name.
     *
     * The field name should both include the namespace and custom object
     * extension. They are case-insensitive.
     */
    public static DescribeFieldResult getDescribeFieldResult(
            String sObjectName, String fieldName) {
        return getDescribeFieldResult(getFieldMap(sObjectName), fieldName);
    }

    /**
     * Gets the DescribeFieldResult for the given field map.
     *
     * The field name should both include the namespace and custom object
     * extension. They are case-insensitive.
     */
    public static DescribeFieldResult getDescribeFieldResult(
            Map<String, Schema.SObjectField> fieldMap, String fieldName) {

        // Try retrieving the field, with the namespace
        Schema.SObjectField field = fieldMap.get(fieldName);

        // If we didn't find it, try adding or removing the namespace 
        if (field == null) {
            fieldName = NamespaceUtils.toggleNamespace(fieldName);
            field = fieldMap.get(fieldName);
        }

        if (field == null) {
            System.debug(LoggingLevel.WARN, 'Field ' + fieldName + ' not found.');
            return null;
        }

        return field.getDescribe();
    }

    /**
     * Gets the translated label of the given field of the given field map.
     *
     * See getDescribeFieldResult().
     */
    public static String getFieldLabel(
            Map<String, Schema.SObjectField> fieldMap, String fieldName) {
        DescribeFieldResult fieldDescribe =
                getDescribeFieldResult(fieldMap, fieldName);
        return fieldDescribe == null ? fieldName : fieldDescribe.getLabel();
    }

    /**
     * Gets the translated label of the given SObject name.
     *
     * The object name should both include the namespace and custom object
     * extension. They are case-insensitive.
     */
    public static String getSObjectLabel(String sObjectName) {
        Schema.SObjectType objSchema =
                Schema.getGlobalDescribe().get(sObjectName);
        if (objSchema == null) {
            System.debug(LoggingLevel.WARN, 'No schema found for ' + sObjectName);
            return null;
        }
        return objSchema.getDescribe().getLabel();
    }

}
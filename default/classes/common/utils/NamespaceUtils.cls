/**
 * Utility methods related to the package namespace.
 */
public class NamespaceUtils {

    /**
     * The package namespace.
     *
     * This should be null in orgs with no namespace configured.
     */
    public static final String NAMESPACE = 'spperfmgmt';

    /**
     * Gets the namespace.
     *
     * This is guaranteed to return a String, even if the namespace is null.
     */
    public static String getNamespaceString() {
        return NAMESPACE == null
                ? ''
                : NAMESPACE;
    }

    /**
     * Gets the namespace prefix.
     */
    public static String getNamespacePrefix() {
        return String.isBlank(NAMESPACE)
                ? ''
                : NAMESPACE + '__';
    }

    /**
     * Gets the Salesforce base URL with the namespace replaced.
     */
    public static String replaceNamespace(
            String targetNamespace, String requiredNamespace) {

        String baseUrl = Test.isRunningTest()
                ? 'https://spperfmgmt.pretendforce.com'
                : System.URL.getSalesforceBaseUrl().toExternalForm();

        if (requiredNamespace == null) {
            // Default namespace for unpackaged components
            requiredNamespace = 'c';
        }

        return baseUrl.replace(targetNamespace, requiredNamespace);
    }

    /**
     * Removes or add the namespace from the start of the given string.
     */
    public static String toggleNamespace(String str) {

        // Remove the custom field extension
        String tmp = str.removeEnd('__c');

        // Look for a double-underscore, which would signify a namespace
        Integer doubleUnderscoreLoc = str.indexOf('__');

        // Add or remove the namespace
        if (doubleUnderscoreLoc >= 0) {
            return str.substring(doubleUnderscoreLoc + 2);
        } else {
            return getNamespacePrefix() + str;
        }
    }

}
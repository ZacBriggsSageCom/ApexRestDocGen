/**
 * Class containing helper methods for dealing with URLs of Objective pages.
 */
public class ObjectiveUrlUtils {

    @TestVisible
    private static final String OBJECTIVE_PAGE =
            '/apex/Performance#/tm/{0}/objectives/{1}';

    /**
     * Gets the URL of an Objective.
     */
    public static String getObjectivePageUrl(Id tmId, Id objectiveId) {
        return fHCM2.UrlHelper.getFullUrl(
                String.format(
                        OBJECTIVE_PAGE,
                        new List<String>{
                                String.valueOf(tmId),
                                String.valueOf(objectiveId)
                        }
                )
        );
    }
}
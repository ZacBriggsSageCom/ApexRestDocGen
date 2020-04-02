/**
 * Remote Actions shared by all pages.
 */
public class CommonRemoting {

    // Locale for the current user
    public String userLocale { get; private set; }

    public CommonRemoting() {
        userLocale = fHCM2.CurrentUser.locale();
    }

    @RemoteAction
    public static Map<String, String> getTranslations(String lang) {
         return TranslationsBuilder.getTranslations(lang);
    }

    /**
     * Gets the link for viewing a File with the given ContentDocumentId.
     */
    @RemoteAction
    public static FileLinkResponseModel getFileLink(String contentDocumentId) {
        return FilesController.getFileLink(contentDocumentId);
    }

    /**
     * Gets a 'people' search for information such as team-members or groups
     */
    @RemoteAction
    public static SearchPeopleResponseModel searchPeople(String query) {
        return SearchController.searchPeople(query);
    }

}
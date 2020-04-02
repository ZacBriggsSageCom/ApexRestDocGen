/**
 * REST endpoint for File access.
 */
@RestResource(urlMapping='/file/*')
global class FilesRest {

    @TestVisible
    private static final String FILE_PARAM = 'file';

    /**
     * Get the link for viewing a File with the given ContentDocumentId.
     */
    @HttpGet
    global static void getFileLink() {
        try {

            // Find File Id
            Id contentDocumentId = RestUtils.getUrlParam(FILE_PARAM);

            // Attempt retrieval and construct response
            RestUtils.setResponseBody(FilesController.getFileLink(contentDocumentId));

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            RestUtils.setResponseBody(new FileLinkResponseModel(), e);
        }
    }
}

/**
 * Helper class for converting File objects to models.
 */
public class FileModelBuilder {

    /**
     * Given a list of ContentVersion objects, convert them to FileModels.
     *
     * @param versions
     * @return List<FileModel>
     */
    public static List<FileModel> build(List<ContentVersion> versions) {
        List<FileModel> models = new List<FileModel>();
        for (ContentVersion version : versions) {
            models.add(build(version));
        }
        return models;
    }

    /**
     * Given a ContentVersion object, convert it to a FileModel.
     *
     * @param version
     * @return FileModel
     */
    public static FileModel build(ContentVersion version) {
        FileModel model = new FileModel();
        model.contentDocumentId = version.ContentDocumentId;
        model.title = version.Title;
        return model;
    }
}
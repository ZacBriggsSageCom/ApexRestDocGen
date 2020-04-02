/**
 * Test utilities for working with Files.
 */
@isTest
public class FileTestUtils {

    /**
     * Creates the File objects necessary to represent a File linked to the given
     * record Id and returns the ContentVersion.
     */
    public static ContentVersion createDefaultFileLinkedTo(Id recordId) {
        Attachments2Files.ContentInfo file = LightningFileHelper.save(
                'The Blurst of Times.txt',
                'The Blurst of Times.txt',
                Blob.valueOf('It was the best of times; it was the blurst of times'),
                recordId
        );
        return FileRepository.getContentVersionById(file.fileId);
    }
}

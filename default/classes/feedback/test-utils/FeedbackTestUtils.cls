/**
 * Test utilities supplying Feedback data.
 */
@isTest
public class FeedbackTestUtils {

    public class FeedbackBuilder {

        private Comment__c item;
        private fHCM2__Team_Member__c author;
        private String content;

        public FeedbackBuilder() {
            item = new Comment__c();
        }

        public FeedbackBuilder(Comment__c template) {
            item = template;
        }

        public FeedbackBuilder(FeedItemModel template) {
            item = FeedbackRecordBuilder.build(template, 1);
        }

        public FeedbackBuilder setAuthor(Id authorId) {
            item.Author__c = authorId;
            this.author = TeamMemberRepository.get(authorId);
            return this;
        }

        public FeedbackBuilder setAuthor(fHCM2__Team_Member__c author) {
            item.Author__c = author.Id;
            this.author = author;
            return this;
        }

        public FeedbackBuilder setAuthorType(String authorType) {
            item.Author_Type__c = authorType;
            return this;
        }

        public FeedbackBuilder setContent(String content) {
            this.content = content;
            return this;
        }

        public FeedbackBuilder setConversation(Id conversationId) {
            item.Conversation__c = conversationId;
            return this;
        }

        public FeedbackBuilder save() {

            // Create a new parent Conversation if we don't already have one
            if (item.Conversation__c == null) {
                Conversation__c conversation = new Conversation__c();
                insert conversation;
                item.Conversation__c = conversation.Id;
            }

            // Save item itself
            item.Current_Version__c = 1;
            upsert item;

            // Save Version record
            Comment_Version__c feedbackVersion = new Comment_Version__c(
                    Comment__c = item.Id,
                    Content__c = content,
                    Version__c = 1
            );
            FeedbackVersionRepository.insertRecord(feedbackVersion);

            // Refresh local copy
            item = FeedbackRepository.getFeedback(item.Id);

            return this;
        }

        public FeedItemModel build() {
            return FeedItemModelBuilder.buildFromComment(item, author);
        }
    }

    public class ConversationBuilder {

        private Conversation__c conversation;
        private SubjectModel subject;
        private List<PersonModel> participants;

        public ConversationBuilder() {
            conversation = new Conversation__c();
            participants = new List<PersonModel>();
        }

        public ConversationBuilder setName(String name) {
            conversation.Name = name;
            return this;
        }

        public ConversationBuilder setSubject(Id subjectId) {
            this.subject =
                    ConversationHandlerRegistry.getHandlerForSubject(subjectId)
                            .createSubject();
            return this;
        }

        public ConversationBuilder addParticipant(fHCM2__Team_Member__c tm) {
            participants.add(TeamMemberUtils.createPerson(tm));
            return this;
        }

        public ConversationBuilder addParticipant(Id tmId) {
            participants.add(TeamMemberUtils.createPerson(tmId));
            return this;
        }

        public ConversationBuilder save() {

            // Create Conversation itself
            insert conversation;

            // Create Subject junction
            ConversationUtils.linkSubject(conversation.Id, subject.id);

            // Create Participants junctions
            List<Conversation_Participant__c> participantJunctions =
                    new List<Conversation_Participant__c>();
            for (PersonModel participant : participants) {
                participantJunctions.add(new Conversation_Participant__c(
                    Conversation__c = conversation.Id,
                    Team_Member__c = participant.id
                ));
            }
            insert participantJunctions;

            return this;
        }

        public ConversationModel build() {
            return ConversationModelBuilder.build(
                    conversation,
                    subject,
                    participants,
                    new List<FeedItemModel>());
        }

    }

}
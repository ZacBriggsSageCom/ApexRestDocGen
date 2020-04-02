/**
 * Test utilities supplying Team Member data.
 */
@isTest
public class TeamMemberTestUtils {

    /**
     * Builder for Team Member objects.
     */
    public class TeamMemberBuilder {

        private fHCM2__Team_Member__c tm;

        public TeamMemberBuilder() {
            tm = new fHCM2__Team_Member__c();
        }

        /**
         * Finish the builder chain and return the saved TM.
         */
        public fHCM2__Team_Member__c build() {
            insert tm;
            return tm;
        }

        public TeamMemberBuilder setManager(Id managerId) {
            tm.fHCM2__Manager__c = managerId;
            return this;
        }

        public TeamMemberBuilder setUser(Id userId) {
            tm.fHCM2__User__c = userId;
            return this;
        }

        public TeamMemberBuilder setName(String tmName) {
            tm.Name = tmName;
            return this;
        }

        public TeamMemberBuilder setPolicy(Id polId) {
            tm.fHCM2__Policy__c = polId;
            return this;
        }

        public TeamMemberBuilder setDepartment(Id deptId) {
            tm.fHCM2__Department__c = deptId;
            return this;
        }

    }

    /**
     * Create and return a User using the given first and last name.
     *
     * @param firstName
     * @param lastName
     * @return User
     */
    public static User createUser(String firstName, String lastName) {

        Profile profile = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Standard Platform User'
        ];

        String randomKey =
                EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String userName = firstName + randomKey.substring(0, 8) + '@test.org';

        User user = new User(
                Username = userName,
                Alias = firstName.substring(0, 1) + lastName,
                Email = firstName + '@' + lastName + '.blog',
                FirstName = firstName,
                LastName = lastName,
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );
        insert user;
        return user;
    }

}
/**
 * Class representing a notification about some event.
 */
public virtual class Notification {

    // The contents of this Notification
    public String body { get; set; }

    // The title or subject line of this Notification
    public String title { get; set; }

    // The Ids of TMs who should receive this Notification
    public Set<Id> recipients { get; set; }

    public void send() {
        Global_Configuration__c cfg = ConfigRepository.getGlobalConfig();
        if (cfg.Suppress_Emails__c != true) {
            NotificationUtils.sendEmail(recipients, title, body);
        }
    }
}

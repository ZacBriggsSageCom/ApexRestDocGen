public class TranslationsBuilder {

    @TestVisible
    private static final String SOBJECT_OBJECTIVE = 'spperfmgmt__Objective__c';

    /**
     * Gets the translations required by the front-end.
     */
    public static Map<String, String> getTranslations(String lang) {

        if (!String.isBlank(lang) && lang != UserInfo.getLocale()) {
            // HCM throws an Exception in this case, but let's just log a
            // warning; the wrong translations are probably better than nothing
            System.debug(LoggingLevel.WARN,
                    'Requested language ' + lang
                    + ' does not match current user\'s locale: '
                    + UserInfo.getLocale());
        }

        Map<String, String> translations = new Map<String, String> {
            'Active_Objectives'                             => Label.Active_Objectives,
            'Add_A_Description'                             => Label.Add_A_Description,
            'Add_New_Task'                                  => Label.Add_New_Task,
            'Back_To_My_Team_Performance'                   => Label.Back_To_My_Team_Performance,
            'Beta_Tag'                                      => Label.Beta_Tag,
            'Button_Attach_Files'                           => Label.Button_Attach_Files,
            'Button_Cancel'                                 => Label.fHCM2.Button_Cancel,
            'Button_Close_Attachments'                      => Label.Button_Close_Attachments,
            'Button_Comment_Add'                            => Label.Button_Comment_Add,
            'Button_Confirm'                                => Label.fHCM2.Button_Confirm,
            'Button_Edit'                                   => Label.fHCM2.Button_Edit,
            'Button_Objective_Activate'                     => Label.Button_Objective_Activate,
            'Button_Objective_Close'                        => Label.Button_Objective_Close,
            'Button_Objective_Delete'                       => Label.Button_Objective_Delete,
            'Button_Objective_Save'                         => Label.Button_Objective_Save,
            'Button_Performance_Overview'                   => Label.Button_Performance_Overview,
            'Button_View'                                   => Label.fHCM2.Button_View,
            'Comment_Edited'                                => Label.Comment_Edited,
            'Comment_History_Dialog_Title'                  => Label.Comment_History_Dialog_Title,
            'Comment_No_Content'                            => Label.Comment_No_Content,
            'Company_Objective'                             => Label.Company_Objective,
            'Conversation_Heading'                          => Label.Conversation_Heading,
            'Conversation_Filter_All'                       => Label.Conversation_Filter_All,
            'Conversation_Filter_By'                        => Label.Conversation_Filter_By,
            'Conversation_Filter_TM'                        => Label.Conversation_Filter_TM,
            'Conversation_Intro'                            => Label.Conversation_Intro_Text,
            'Conversation_Private_Text'                     => Label.Conversation_Private_Text,
            'Conversations_Disabled_Tooltip'                => Label.Conversations_Disabled_Tooltip,
            'Conversations_Not_Enabled'                     => Label.Conversations_Not_Enabled,
            'Created_By'                                    => Label.Created_By,
            'Error_Adding_Comment'                          => Label.Error_Adding_Comment,
            'Error_Activating_Objective'                    => Label.Error_Activating_Objective,
            'Error_Closing_Objective'                       => Label.Error_Closing_Objective,
            'Error_Creating_Objective'                      => Label.Error_Creating_Objective,
            'Error_Deleting_Objective'                      => Label.Error_Deleting_Objective,
            'Error_Editing_Objective'                       => Label.Error_Editing_Objective,
            'Error_Editing_Comment'                         => Label.Error_Editing_Comment,
            'Error_Locating_Performance_Overview'           => Label.Error_Locating_Performance_Overview,
            'Error_No_Direct_Reports_For_User'              => Label.Error_No_Direct_Reports_For_User,
            'Error_Page_Not_Found'                          => Label.Error_Page_Not_Found,
            'Error_Retrieving_Conversation'                 => Label.Error_Retrieving_Conversation,
            'Error_Retrieving_Comment_Versions'             => Label.Error_Retrieving_Comment_Versions,
            'Error_Retrieving_File'                         => Label.Error_Retrieving_File,
            'Error_Retrieving_Manager_Dashboard'            => Label.Error_Retrieving_Manager_Dashboard,
            'Error_Retrieving_Objectives'                   => Label.Error_Retrieving_Objectives,
            'Error_Retrieving_Team_Member'                  => Label.Error_Retrieving_Team_Member,
            'Feature_Disabled'                              => Label.Feature_Disabled,
            'Global_Description'                            => Label.fHCM2.Global_Description,
            'My_Conversation'                               => Label.My_Conversation,
            'My_Performance'                                => Label.My_Performance,
            'My_Team'                                       => Label.My_Team,
            'My_Team_Performance'                           => Label.My_Team_Performance,
            'No_Objectives'                                 => Label.No_Objectives,
            'None'                                          => Label.fHCM2.Global_None,
            'Objective_Add_First'                           => Label.Objective_Add_First,
            'Objective_Add_New'                             => Label.Objective_Add_New,
            'Objective_Confirm_Activation_Title'            => Label.Objective_Confirm_Activation_Title,
            'Objective_Confirm_Activation_Modal'            => Label.Objective_Confirm_Activation_Modal,
            'Objective_Confirm_Close_Title'                 => Label.Objective_Confirm_Close_Title,
            'Objective_Confirm_Close_Modal'                 => Label.Objective_Confirm_Close_Modal,
            'Objective_Confirm_Deletion_Title'              => Label.Objective_Confirm_Deletion_Title,
            'Objective_Confirm_Deletion_Modal'              => Label.Objective_Confirm_Deletion_Modal,
            'Objective_Confirm_Close_With_Open_Tasks_Modal' => Label.Objective_Confirm_Close_With_Open_Tasks_Modal,
            'Objective_New'                                 => Label.Objective_New,
            'Objective_Participants'                        => Label.Objective_Participants,
            'Objective_Review_Date'                         => Label.Objective_Review_Date,
            'Objective_Closed_Date'                         => label.Objective_Closed_Date,
            'Objective_End_Date'                            => label.Objective_End_Date,
            'Objective_Save_Draft'                          => Label.Objective_Save_Draft,
            'Objective_Title_Max_Length_Exceeded'           => Label.Objective_Title_Max_Length_Exceeded,
            'Objective_Title_No_Content'                    => Label.Objective_Title_No_Content,
            'Objectives_Disabled_Tooltip'                   => Label.Objectives_Disabled_Tooltip,
            'Objectives_Title'                              => Label.Objectives_Title,
            'Performance_Management_Name'                   => Label.Performance_Management_Name,
            'Report_Has_No_Objectives'                      => Label.Report_Has_No_Objectives,
            'Session_Timeout_Message'                       => Label.Session_Timeout_Message,
            'Subject_Performance'                           => Label.Subject_Performance,
            'Tasks'                                         => Label.Tasks,
            'Tasks_Complete'                                => Label.Tasks_Complete,
            'Task_Max_Length_Exceeded'                      => Label.Task_Max_Length_Exceeded
        };

        translations.putAll(getSObjectLabels(SOBJECT_OBJECTIVE));

        return translations;
    }

    /**
     * Creates a map containing the translated SObject name and field labels.
     *
     * The SObject name is stored using the API name as the key, with the
     * correct capitalisation, including the namespace.
     *
     *      e.g. spperfmgmt__Objective__c
     *
     * The field names are stored using lowercase keys, including the namespace,
     * and prefixed with the SObject name.
     *
     *      e.g. spperfmgmt__Objective__c.spperfmgmt__end_date__c
     */
    @TestVisible
    private static Map<String, String> getSObjectLabels(String sObjectName) {

        Map<String, String> labelMap = new Map<String, String>();

        // Add the label for the SObject itself
        labelMap.put(sObjectName, SchemaUtils.getSObjectLabel(sObjectName));

        Map<String, Schema.SObjectField> fieldMap =
                SchemaUtils.getFieldMap(sObjectName);

        // Add labels for each of the SObject's fields
        for (String fieldName : fieldMap.keySet()) {
            String fieldLabel = SchemaUtils.getFieldLabel(fieldMap, fieldName);
            labelMap.put(sObjectName + '.' + fieldName, fieldLabel);
        }

        return labelMap;
    }

}
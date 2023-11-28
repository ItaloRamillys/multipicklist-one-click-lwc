public class QueueAssignmentController {
    @AuraEnabled( cacheable=true )
    public static QueueWrapper fetchQueueAssignments(Id queueId) {
    
        QueueWrapper objQW = new QueueWrapper();
        List<String> selectedUsers = new List <String>();
        List<QueueOptionWrapper> availableUsers = new List <QueueOptionWrapper>();
        Set<Id> selectedUsersId = new Set <Id>();
        
        System.debug(queueId);
        System.debug([ SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND GroupId =:queueId ]);
        for ( GroupMember gp : [ SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =:queueId ] ) {
            selectedUsersId.add( gp.UserOrGroupId );
        }

        System.debug('Galera da fila: ' + selectedUsersId);
        
        for ( User u : [ SELECT Id, Name FROM User] ) {
            QueueOptionWrapper auxWrapper = new QueueOptionWrapper();
            auxWrapper.label = u.Name;
            auxWrapper.value = u.id;
            availableUsers.add( auxWrapper );
        }
        
        for ( User u : [ SELECT Id, Name FROM User WHERE Id IN :selectedUsersId] ) {
            // QueueOptionWrapper auxWrapper = new QueueOptionWrapper();
            // auxWrapper.label = u.Name;
            // auxWrapper.value = u.id;
            selectedUsers.add( u.id );
        }
        
        objQW.availableUsers = availableUsers;
        objQW.selectedUsers = selectedUsers;
        
        return objQW;
    
    }
    
    //reaproveitar a lógica do componente antigo
    @AuraEnabled
    public static String addRemoveQueues( List < String > selectedUsers, String queueId) {
        
        System.debug(selectedUsers);
        System.debug(queueId);
        try{

            List<GroupMember> groupMemberToInsertList = new List<GroupMember>();
            List<GroupMember> groupMemberToDeleteList = new List<GroupMember>();
            Map<Id, GroupMember> groupMemberToDeleteMap = new Map<Id, GroupMember>();
            Set<Id> userIdInQueueDB = new Set<Id>();
            List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId from GroupMember WHERE GroupId =:queueId WITH SECURITY_ENFORCED];
            
            System.debug('Usuarios da fila');
            for(GroupMember gm : groupMemberList)
            {
                System.debug(gm);
                userIdInQueueDB.add(gm.UserOrGroupId);
                //Se a lista nao possui o id de alguém que ja estava na base, deve excluir esse usuario
                groupMemberToDeleteMap.put(gm.UserOrGroupId, gm);
            }

            for(Id userId : userIdInQueueDB)
            {
                if(!selectedUsers.contains(userId))
                {
                    System.debug('Usuário: ' + userId + ' deve ser apagado da fila');
                    groupMemberToDeleteList.add(groupMemberToDeleteMap.get(userId));
                }
            }
            System.debug('Inserindo novos');
            //Incluindo na lista os novos GroupMembers para inserir
            for(Id userId : selectedUsers)
            {
                System.debug('Id: ' + userId);
                if(!userIdInQueueDB.contains(userId))
                {
                    System.debug('Usuário: ' + userId + ' deve ser inserido na fila');
                    groupMemberToInsertList.add(new GroupMember(GroupId = queueId, UserOrGroupId = userId));
                }
            }
            System.debug('Listas');
            System.debug('Insert:' + groupMemberToInsertList);
            System.debug('Delete:' + groupMemberToDeleteList);
            
            if (Schema.sObjectType.GroupMember.isCreateable() && groupMemberToInsertList.size() > 0) {
                insert groupMemberToInsertList;
            }
            System.debug(groupMemberToDeleteList);
            
            if (Schema.sObjectType.GroupMember.isDeletable() && groupMemberToDeleteList.size() > 0) {
                delete groupMemberToDeleteList;
            }
            
            return 'Successful';
            
        }catch(Exception e)
        {
            throw new AuraHandledException( e.getMessage() );
        }
        // try {
            // System.debug('@addRemoveQueues');
            // System.debug('Listas');
            // System.debug(selectedUsers);
            // System.debug(updatedQueues);
            
            // List < GroupMember > listGroupMembersForInsert = new List < GroupMember >();
        // Set < String > setGroupIds = new Set < String >();
    
        
        //     Set < String > setselectedUsers = new Set < String >();
        //     Set < String > setUpdatedQueues = new Set < String >();
        //     setselectedUsers.addAll( selectedUsers );
        //     setUpdatedQueues.addAll( updatedQueues );
            
        //     for(String userSel : selectedUsers)
        //     {
        //         if ( !updatedQueues.contains( userSel ) ) {
                    
        //             GroupMember objGM = new GroupMember();
        //             objGM.UserOrGroupId = userSel;
        //             objGM.GroupId = queueId;
        //             listGroupMembersForInsert.add( objGM );
                    
        //         }
        //     }

        //     // for ( String strQueue : setUpdatedQueues ) {
            
        //     //     if ( !setselectedUsers.contains( strQueue ) ) {
                    
        //     //         GroupMember objGM = new GroupMember();
        //     //         objGM.UserOrGroupId = strQueue;
        //     //         objGM.GroupId = queueId;
        //     //         listGroupMembersForInsert.add( objGM );
                    
        //     //     }
            
        //     // }

        //     for ( String strQueue : setUpdatedQueues ) {
            
        //         if ( !setselectedUsers.contains( strQueue ) ) {
                    
        //             setGroupIds.add( strQueue );
                    
        //         }
            
        //     }
            
        //     // for ( String strQueue : setselectedUsers ) {
            
        //     //     if ( !setUpdatedQueues.contains( strQueue ) ) {
                    
        //     //         setGroupIds.add( strQueue );
                    
        //     //     }
            
        //     // }
            
        //     if ( setGroupIds.size() > 0 ) {
        //         delete [ SELECT Id FROM GroupMember WHERE UserOrGroupId IN:updatedQueues AND GroupId =:queueId ];
        //     }
            
        //     if ( listGroupMembersForInsert.size() > 0 ) {
            
        //         insert listGroupMembersForInsert;
                
        //     }

        //     return 'Successful';
            
        
        // } catch ( Exception e ) {
        
        //     throw new AuraHandledException( e.getMessage() );
            
        // }
    
    }
    
    public class QueueWrapper {

        @AuraEnabled
        public List < QueueOptionWrapper > availableUsers;
        @AuraEnabled
        public List < String > selectedUsers;

    }

    public class QueueOptionWrapper {

        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;

    }

}
public with sharing class QueueService {
    @AuraEnabled(cacheable=true)
    public static List<GroupMember> getGroupMembersByQueueId(Id queueId)
    {
        List<GroupMember> groupMemberList = [SELECT Id, GroupId, UserOrGroupId, SystemModstamp FROM GroupMember WHERE GroupId = :queueId WITH SECURITY_ENFORCED];
        return groupMemberList;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getGroupMembersInQueueByQueueId(Id queueId)
    {
        List<GroupMember> allUsersInQueue = getGroupMembersByQueueId(queueId);
        List<Id> userIdList = new List<Id>();
        for(GroupMember gm : allUsersInQueue)
        {
            userIdList.add(gm.UserOrGroupId);
        }

        return [SELECT Id, Name FROM User WHERE Id IN :userIdList WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<User> getGroupMembersOutQueueByQueueId(Id queueId)
    {
        List<GroupMember> allUsersInQueue = getGroupMembersByQueueId(queueId);
        List<Id> idsUsersToIgnore = new List<Id>();
        for(GroupMember gm : allUsersInQueue)
        {
            idsUsersToIgnore.add(gm.UserOrGroupId);
        }

        return [SELECT Id, Name FROM User WHERE Id NOT IN :idsUsersToIgnore WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=false)
    public static void setUsersInGroup(List<Id> userIdList, Id qId)
    {   
        System.debug('userIdList' + userIdList);
        System.debug('qId' + qId);
        List<GroupMember> groupMemberToInsertList = new List<GroupMember>();
        List<GroupMember> groupMemberToDeleteList = new List<GroupMember>();
        Map<Id, GroupMember> groupMemberToDeleteMap = new Map<Id, GroupMember>();
        Set<Id> userIdInQueueDB = new Set<Id>();
        List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId from GroupMember WHERE GroupId =:qId WITH SECURITY_ENFORCED];

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
            if(!userIdList.contains(userId))
            {
                System.debug('Usuário: ' + userId + ' deve ser apagado da fila');
                groupMemberToDeleteList.add(groupMemberToDeleteMap.get(userId));
            }
        }
        System.debug('Inserindo novos');
        //Incluindo na lista os novos GroupMembers para inserir
        for(Id userId : userIdList)
        {
            System.debug('Id: ' + userId);
            if(!userIdInQueueDB.contains(userId))
            {
                System.debug('Usuário: ' + userId + ' deve ser inserido na fila');
                groupMemberToInsertList.add(new GroupMember(GroupId = qId, UserOrGroupId = userId));
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
    }
}
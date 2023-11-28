import { LightningElement, api, wire, track } from 'lwc';
import getListMembers from '@salesforce/apex/QueueService.getGroupMembersInQueueByQueueId';
import getListMembersOut from '@salesforce/apex/QueueService.getGroupMembersOutQueueByQueueId';
import saveNewGroupMembers from '@salesforce/apex/QueueService.setUsersInGroup';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QueueController extends LightningElement {

    @track error;
    @track queueId = '00GHp000005Tf4uMAC';
     groupMembersInQueue;
     groupMembersNotInQueue;
    
    @wire (getListMembers,{queueId: '$queueId'})queueFunction({ error, data }) 
    {
        if (data) {
            //console.log('In: ');
            //console.log(data);
            this.groupMembersInQueue = data;
        } else if (error) {
            //console.log('erro IN' + error);
        }
    }
    
    @wire (getListMembersOut,{queueId: '$queueId'})queueOutFunction({ error, data }) 
    {
        if (data) {
            //console.log('Out: ');
            //console.log(data);
            this.groupMembersNotInQueue = data;
        } else if (error) {
            //console.log('erro OUT' + error);
        }
    }

    @api async handleSaveClick()
    {
        let idUserListInQueue = []
        this.groupMembersInQueue.forEach(element => {
            idUserListInQueue.push(element.Id)
        })
        saveNewGroupMembers({userIdList: idUserListInQueue, qId: this.queueId}).then(response => {
            //console.log(response);
            //console.log("SUCESSO");
        })
        .catch(error => {
            //console.log('this.createError');
            //console.log(JSON.stringify(error))
        });
    }

    handleClickMoveUserToRight(event)
    {
        //console.log('@handleClickMoveUserToRight');
        let sideUser = event.currentTarget.dataset.side;
        let array = [];
        let aux = "";
        let user = event.target;
        aux = user.getAttribute("value");

        if(sideUser === "left")
        {
            this.groupMembersNotInQueue.forEach(element => {
                if(element.Id != aux)
                {
                    array.push(element);
                }else
                {
                    let arrAux = [];
                    this.groupMembersInQueue.forEach(el => {
                        arrAux.push(el);
                    });
                    arrAux.push(element);
                    this.groupMembersInQueue = arrAux;
                }
            });
            this.groupMembersNotInQueue = array;
        }else
        {
            this.groupMembersInQueue.forEach(element => {
                if(element.Id != aux)
                {
                    array.push(element);
                }else
                {
                    let arrAux = [];
                    this.groupMembersNotInQueue.forEach(el => {
                        arrAux.push(el);
                    });
                    arrAux.push(element);
                    this.groupMembersNotInQueue = arrAux;
                }
            });
            this.groupMembersInQueue = array;
        }

    
        
    }

}
import { LightningElement, track, wire } from 'lwc';
import fetchQueueAssignments from '@salesforce/apex/QueueAssignmentController.fetchQueueAssignments';
import addRemoveQueues from '@salesforce/apex/QueueAssignmentController.addRemoveQueues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QueueAssignment extends LightningElement {

    availableUsers;
    selectedUsers;
    updatedQueues;
    @track queueId = '00GHp000005Tf4uMAC';

    @wire( fetchQueueAssignments,{queueId: '$queueId'} )  
    wiredRecs( { error, data } ) {

        console.log('@fetchQueueAssignments');

        if ( data ) {

            console.log( 'Records are ' + JSON.stringify( data ) );
            this.availableUsers = data.availableUsers;
            this.selectedUsers = data.selectedUsers;
            
        } else if ( error ) {

            console.log( 'Error ' + JSON.stringify( error ) );

        }
        
    }

    handleChange( event ) {
            
        const selectedOptionsList = event.detail.value;
        this.updatedQueues = selectedOptionsList;
        this.selectedUsers = event.detail.value;

    }

    saveChanges() {
        console.log('@saveChanges');
        console.log(this.selectedUsers);
        addRemoveQueues( { selectedUsers : this.selectedUsers, queueId: this.queueId} )
        .then( result => {

            console.log( 'Result ' + JSON.stringify( result ) );
            let message;
            let variant;

            if ( result === 'Successful' ) {

                message = 'Successfully Processed!';
                variant = 'success';

            } else {

                message = 'Some error occured. Please reach out to your Admin';
                variant = 'error';
                
            }

            const toastEvent = new ShowToastEvent( {

                title: 'Queue(s) Assignment',
                message: message,
                variant: variant

            } );
            this.dispatchEvent( toastEvent );

        } )
        .catch( error => {

            console.log( 'Error ' + JSON.stringify( error ) );
            
        } );
        this.selectedUsers = this.updatedQueues;
            
    }

}
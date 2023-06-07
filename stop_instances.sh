#!/bin/bash


# Function to prompt for confirmation
confirm_action() {
    read -p "Are you sure? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        echo "Aborted."
        false
    fi
    true
}

# Get the action parameter
action=$1

# Check if an action parameter is provided
if [[ -z $action ]]; then
    echo "Please provide an action parameter: --stop, --start, or --terminate"
    exit 1
fi

# Get a list of all running EC2 instances
instance_ids=$(aws ec2 describe-instances --region eu-north-1 --query 'Reservations[].Instances[?State.Name==`running`].InstanceId' --output text)

instance_ids2=$(aws ec2 describe-instances --region eu-north-1 --query 'Reservations[].Instances[?State.Name==`stopped`].InstanceId' --output text)
# Perform the specified action

case $action in
    "--stop")
        for id in $instance_ids; do
            echo "Stopping instance: $id"
            aws ec2 stop-instances --region eu-north-1 --instance-ids $id

        done
        ;;
    "--start")
        for id in $instance_ids2; do
            echo "Starting instance: $id"
            aws ec2 start-instances --region eu-north-1 --instance-ids $id
        done
        ;;
    "--terminate")
        echo "WARNING: This action will terminate the instances."

        for id in $instance_ids; do
            echo "Terminating instance: $id"
            if confirm_action; then
            	aws ec2 terminate-instances --region eu-north-1 --instance-ids $id
		echo "terminated $id"
	    else
		echo "skipped $id"
            fi
        done
	for id in $instance_ids2; do
            echo "Terminating instance: $id"
	    if confirm_action; then
            	aws ec2 terminate-insta --region eu-north-1 --instance-ids $id
	    else
            	echo "skipping $id"
	    fi
        done
        ;;
    *)
        echo "Invalid action parameter: $action"
        exit 1
        ;;
esac

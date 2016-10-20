#! /bin/bash

set -exu

#ARTIFACT_ROOT=https://circle-artifacts.com/gh/circleci/circle-cloudformation
#ARTIFACT_FILE=$(find $CIRCLE_ARTIFACTS -name *-jar-with-dependencies.jar)
#ARTIFACT_URL=$ARTIFACT_ROOT/$CIRCLE_BUILD_NUM/artifacts/0$ARTIFACT_FILE

STACK_NAME=${CIRCLE_BRANCH}-${CIRCLE_PROJECT_REPONAME} 
#-${CIRCLE_BUILD_NUM}

export AWS_DEFAULT_REGION=us-east-1

function waitOnCompletion() {
    STATUS=IN_PROGRESS
    while expr "$STATUS" : '^.*PROGRESS' > /dev/null ; do
        sleep 10
        STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[0].StackStatus')
        echo $STATUS
    done
}

CMD=create-stack
for file in $(ls -1 *.cf); do 
   aws cloudformation $CMD \
          --stack-name $STACK_NAME \
          --template-body file://$file \
          --parameters ParameterKey=KeyName,ParameterValue=vpc-reference ParameterKey=VPCID,ParameterValue=jtl3.net
    CMD=update-stack
    waitOnCompletion
done
          

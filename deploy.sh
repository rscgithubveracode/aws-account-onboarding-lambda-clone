#!/bin/bash
set -eo pipefail
ARTIFACT_BUCKET=$(cat bucket-name.txt)
TEMPLATE=template.yml
./gradlew build -i
echo "Packaging local artifacts to generate a template file out.yml with s3 references instead of local paths..."
aws --profile $1 --region $2 cloudformation package --template-file $TEMPLATE --s3-bucket $ARTIFACT_BUCKET --output-template-file out.yml # this will upload the source code zip file to the s3 bucket and generate a template file out.yml where the local paths are replaced with the S3 URIs.
echo "Generated out.yml file..."
echo "Deploying artifacts as a cloudformation stack $3 for profile $1 in region $2"
aws --profile $1 --region $2 cloudformation deploy --template-file out.yml --stack-name $3 --capabilities CAPABILITY_NAMED_IAM # this will create the application stack using the output template file
echo "DONE"
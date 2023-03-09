echo "Creating S3 bucket $1 for profile $2 in region $3"
BUCKET_NAME=$1
echo $BUCKET_NAME > bucket-name.txt
aws --profile $2 --region $3 s3 mb s3://$BUCKET_NAME
echo "DONE"
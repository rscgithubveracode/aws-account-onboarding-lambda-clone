# Lambda function to create aws role, policy and attach policy to role

# Requirements

* Java 11 runtime environment
* Gradle 7
* Bash shell/zsh (optional if you want to run the aws commands yourself)
* aws cli v1.17 or newer
    + If using v2, add `cli_binary_format=raw-in-base64-out` to your `~/.aws/config`

# Setting up locally

`$ git clone https://github.com/logicmonitor/cloud-samples.git`

`$ cd cloud-samples`

# s3 bucket creation

This step is needed to deploy artifacts related to lambda function. We need to create a s3 bucket to
store the artifacts. Run the following command from the root level `cloud-samples`,

`$ ./create_aws_s3_bucket.sh <enter-a-bucket-name-to-create> <aws-profile-name> <aws-region>`

where <aws-profile-name> is the profile configured in `~/.aws/config`.

If you have your aws-cli setup with a single profile, you could also directly create a s3 bucket,

`$ aws s3 mb s3://<enter-a-bucket-name>`

Add `--region` option if you want it in a particular region.

# Generate the artifacts

Let's package our java code as a zip. Run the following command from the root level of
project `cloud-samples`,

`./gradlew buildZip`

Gradle will generate the zip under the project in the path `build/distributions/cloud-samples.zip`.

# Deploy artifacts and lambda function - One time process

Now that you have created a s3 bucket and our lambda function artifact, let's deploy our lambda
function using the configuration file `template.yml`

The deploy script uses aws cloudformation to package the artifacts and create the lambda function.

`$ ./deploy.sh <aws-profile-name> <aws-region> <enter-a-lambda-function-name>`

Alternatively, you can run the following commands if your profile is already setup,

`$ aws cloudformation package --template-file template.yml --s3-bucket <your-s3-bucket-name-from-step-1> --output-template-file out.yml`

Make sure you have an out.yml file generated.

`$ aws cloudformation deploy --template-file out.yml --stack-name <enter-a-lambda-function-name> --capabilities CAPABILITY_NAMED_IAM`

You should see a successfully created stack message.

# Running the lambda function

Now, you can trigger the lambda function using events from aws console. This will create the role,
policy and attach the policy to role.

Navigate to aws console -> Lambda -> <your-lambda-function-name-with-an-identifier>

There should be a Test tab in your function.

![test-tab](https://github.com/logicmonitor/cloud-samples/images/test-tab-in-function.png "Test tab in lambda function")

Under the Event Json, supply your input for role and policy creation,

Eg.,

```json
{
  "principalAccountId": "123456789",
  "policyName": "my-policy-name",
  "externalId": "my-external-id-from-lm",
  "roleName": "my-role-name",
  "policyJson": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
}
```

Test and Save this event if you are going to edit and use it for multiple role, policy creations. 

This should have created your role with proper trust entity (external-id), policy and attached the policy to role.

  
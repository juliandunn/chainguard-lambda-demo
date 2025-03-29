# Deploy Java Lambda function with Chainguard Image

Basically adapted from the "use a non-AWS base image" guide:
https://docs.aws.amazon.com/lambda/latest/dg/java-image.html#java-image-clients

## Build instructions

```
$ podman image build --arch=amd64 --os=linux --tag chainguard-lambda-demo:test -f Containerfile
```

After setting up the RIE simulator, test it out:

```
$ podman run --platform linux/amd64 -d -v ~/.aws-lambda-rie/:/aws-lambda -p 9000:8080 --entrypoint /aws-lambda/aws-lambda-rie chainguard-lambda-demo:test /usr/bin/java -cp './*' com.amazonaws.services.lambda.runtime.api.client.AWSLambda com.aquezada.App::sayHello
$ curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d
 '{}'
```

Publish it once satisfied:

```
$ podman tag chainguard-lambda-demo:test 123456.dkr.ecr.us-west-2.amazonaws.com/chainguard-lambda-demo:latest
$ podman push 123456.dkr.ecr.us-west-2.amazonaws.com/chainguard-lambda-demo:latest
```

Set up and test the Lambda function live:

```
$ aws lambda create-function --function-name chainguard-lambda-demo --package-type Image --code ImageUri=433913174136.dkr.ecr.us-west-2.amazonaws.com/chainguard-lambda-demo:latest --role arn:aws:iam::433913174136:role/lambda-ex
$ aws lambda invoke --function-name chainguard-lambda-demo response.json
```

The `response.json` should contain the Hello World text.

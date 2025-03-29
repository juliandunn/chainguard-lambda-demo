FROM cgr.dev/chainguard/maven:latest AS builder

WORKDIR /home/build

ADD pom.xml .
RUN mvn dependency:go-offline dependency:copy-dependencies

# Compile the function
ADD . .
RUN mvn package 

# Copy the function artifact and dependencies onto a clean base
FROM cgr.dev/chainguard/jre:latest
WORKDIR /app

COPY --from=builder /home/build/target/dependency/*.jar ./
COPY --from=builder /home/build/target/*.jar ./

# Set runtime interface client as default command for the container runtime
ENTRYPOINT [ "/usr/bin/java", "-cp", "./*", "com.amazonaws.services.lambda.runtime.api.client.AWSLambda" ]
# Pass the name of the function handler as an argument to the runtime
CMD [ "com.aquezada.App::sayHello" ]

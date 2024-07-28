FROM openjdk
WORKDIR /usr/app
COPY ./target/my-app-*.jar /usr/app
CMD  java -jar my-app-*.jar
EXPOSE 8080
# STAGE 1 - BUILD: Compila el JAR con Maven
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# STAGE 2 - RUNTIME: Imagen minima solo con el JAR
FROM eclipse-temurin:21-jre-alpine AS runtime

# Minimo privilegio: usuario no-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar
RUN chown appuser:appgroup app.jar

USER appuser
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]

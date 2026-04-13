# 1-ci Mərhələ: Build (Qurulma)
FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /app
# Asılılıqları yükləyirik (caching üçün)
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Kodu kopyalayıb JAR faylı hazırlayırıq
COPY src ./src
RUN mvn package -DskipTests

# 2-ci Mərhələ: Runtime (İcra)
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app
# Təhlükəsizlik üçün root olmayan user yaradırıq
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
# Yalnız lazım olan JAR faylını birinci mərhələdən kopyalayırıq
COPY --from=builder /app/target/*.jar app.jar
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]


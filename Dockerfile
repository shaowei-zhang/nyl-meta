# 使用基础镜像
FROM bellsoft/liberica-openjdk-debian:17.0.11-cds

# 维护者信息
MAINTAINER zsw


# 添加 Java 应用程序
ADD nyl_meta-0.0.1-SNAPSHOT.jar nyl_meta-0.0.1-SNAPSHOT.jar

# 暴露端口
EXPOSE 19990

# 启动 Java 应用程序
ENTRYPOINT ["java", "-jar", "nyl_meta-0.0.1-SNAPSHOT.jar"]
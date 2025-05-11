FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

# 定义构建参数（可被命令行覆盖）
ARG SERVICE_NAME

# 将参数转为环境变量（运行时可用）
ENV ENV_SERVICE_NAME=${SERVICE_NAME}

# 复制部署文件
COPY release/${ENV_SERVICE_NAME}/ .
ENTRYPOINT ["sh", "-c", "dotnet ${ENV_SERVICE_NAME}.dll"]
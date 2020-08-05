FROM mcr.microsoft.com/dotnet/core/sdk:2.2

LABEL maintainer="analytics.api.support@factset.com"

COPY dotnet /dotnet

# COPY openapi-schema.json /dotnet/openapi-schema.json

WORKDIR /dotnet

# RUN docker run --rm -v ${PWD}:/local arnoldfernandes/openapi-generator-cli-custom:4.2.2 generate --generator-name CustomCSharpNetCoreClientCodegen --input-spec /local/openapi-schema.json --output /local/GeneratedSDK --config /local/openapi-generator-config.json --http-user-agent engines-api/3.0.0/csharp --template-dir /local/Templates --skip-validate-spec

# COPY dotnet/entrypoint.sh /

# COPY dotnet/openapi-generator-config.json /

# ENTRYPOINT ["bash", "/entrypoint.sh"]

WORKDIR /dotnet/GeneratedSDK

RUN dotnet build --configuration Release 

WORKDIR /dotnet/Tests

RUN dotnet test --verbosity normal

WORKDIR /dotnet/Examples

RUN dotnet build --configuration Release

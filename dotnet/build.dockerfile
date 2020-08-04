FROM mcr.microsoft.com/dotnet/core/sdk:2.2

LABEL maintainer="analytics.api.support@factset.com"

COPY dotnet/Examples/* /Examples

COPY dotnet/Tests/* /Tests

COPY dotnet/entrypoint.sh /

COPY dotnet/openapi-generator-config.json /

ENTRYPOINT ["bash", "/entrypoint.sh"]

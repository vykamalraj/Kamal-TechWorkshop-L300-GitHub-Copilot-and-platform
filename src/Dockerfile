# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder
WORKDIR /src

COPY ["ZavaStorefront.csproj", "./"]
RUN dotnet restore "ZavaStorefront.csproj"

COPY . .
RUN dotnet build "ZavaStorefront.csproj" -c Release -o /app/build

RUN dotnet publish "ZavaStorefront.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app

COPY --from=builder /app/publish .

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80

ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]

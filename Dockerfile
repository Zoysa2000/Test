# -------------------------------
# Stage 1: Build the .NET project
# -------------------------------

# Use the official .NET 8 SDK image.
# SDK image is used to restore packages, build, and publish the project.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory inside the container to /src.
WORKDIR /src

# Copy only the project file first.
# This helps Docker cache the NuGet package restore step.
COPY ["TestBackend.csproj", "./"]

# Restore NuGet packages for the project.
RUN dotnet restore "TestBackend.csproj"

# Copy all remaining project files into the container.
# This includes Program.cs, Controllers, appsettings.json, etc.
COPY . .

# Publish the project in Release mode.
# The final publish output will be placed in /app/publish.
RUN dotnet publish "TestBackend.csproj" -c Release -o /app/publish



# Use the official ASP.NET Core runtime image.
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory inside the final container to /app.
WORKDIR /app

# Copy the published output from the build stage into the runtime stage.
# /app/publish comes from the build stage.
# . means copy into the current folder, which is /app.
COPY --from=build /app/publish .

# Tell Docker that the app uses port 8080.
# This does not open the port by itself; it is mainly documentation.
EXPOSE 8080

# Tell ASP.NET Core to listen on port 8080 inside the container.
# + means listen on all network interfaces.
ENV ASPNETCORE_URLS=http://+:8080

# Start the ASP.NET Core Web API when the container runs.
# TestBackend.dll must match your project output DLL name.
ENTRYPOINT ["dotnet", "TestBackend.dll"]
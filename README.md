# Generator for Analytics API Engines SDKs

## Overview

This repository contains all the configurations and customizations required to generate API client libraries (SDKs) for FactSet's Analytics API Engines product. It replies on the API's [Open API Specification](https://github.com/OAI/OpenAPI-Specification) document and uses the [Open API Generator](https://github.com/OpenAPITools/openapi-generator) tool for SDK generation.

Follow the below links for generated language specific SDK repositories.

* [Python](https://github.com/factset/analyticsapi-engines-python-sdk)
* [Dotnet](https://github.com/factset/analyticsapi-engines-dotnet-sdk)
* [Java](https://github.com/factset/analyticsapi-engines-java-sdk)

## Contents

* **[Open API Specification](openapi-schema.json)** - The [Open API Specification](https://github.com/OAI/OpenAPI-Specification) document of the API
* **[Custom Open API Generator](openapi-generator)** - Dockerized wrapper over [Open API Generator](https://github.com/OpenAPITools/openapi-generator) to support customizations
* **[Languages](languages)** - Directory containing [Open API Generator](https://github.com/OpenAPITools/openapi-generator) configurations `openapi-generator-config.json` and template files `templates\*.mustache` to override default settings for individual languages

## How to Contribute

There are different scenarios that might require changes to this repository. Follow the steps outlined in the below sections based on your requirement.

### To generate new version of the SDKs

1. Clone this repository and create a branch.
2. Replace `openapi-schema.json` with the latest version of API's [Open API Specification](https://github.com/OAI/OpenAPI-Specification) document.
3. Update the package versions in `languages/*/openapi-generator-config.json` files. Modify the rest of the configurations and template files if needed.
4. Raise a pull request with all above mentioned changes. This step will trigger a [GitHub Workflow](https://docs.github.com/en/actions/configuring-and-managing-workflows/configuring-and-managing-workflow-files-and-runs) that'll generate the SDKs and raise a pull request in each individual SDK repositories.
5. Review the SDK pull requests and make changes if needed. Do not manually edit the auto-generated SDK code. Make changes in the Generator pull request (created in step 4) and it'll automatically reflect in the SDK pull requests. Follow these steps until the SDK looks good.

### To configure a new language

1. Check if [Open API Generator](https://github.com/OpenAPITools/openapi-generator) supports the language - [Supported client generator](https://openapi-generator.tech/docs/generators#client-generators)
2. If the language is supported, note the generator name for it. We'll call it {generator-name}
3. Clone this repository and create a branch.
4. Add a new directory `languages/{generator-name}`
5. Create a configuration file `languages/{generator-name}/openapi-generator-config.json`.
6. Add a directory `languages/{generator-name}/templates`
7. (Optional) Add custom templates for your generator. Check [Open API Generator Templates](https://openapi-generator.tech/docs/templating) for more information.

## Local SDK generation for testing purposes

### Prerequisites

* [Docker](https://www.docker.com/)

### Steps

1. Build the Docker image

    ```bash
    docker build --build-arg VERSION=4.2.2 \
        -t openapi-generator-cli-custom \
        -f ./openapi-generator/Dockerfile \
        ./openapi-generator
    ```

2. Run the Docker image to generate SDK. The `languages/*/sdk` directory will contain the generated files. In the below script, replace the {generator-name} with 

    ```bash
    docker run --rm -v ${PWD}:/generator \
        openapi-generator-cli-custom generate \
        --generator-name {generator-name} \
        --input-spec /generator/openapi-schema.json \
        --output /generator/languages/{directory-name}/sdk \
        --config /generator/languages/{directory-name}/openapi-generator-config.json \
        --template-dir /generator/languages/{directory-name}/templates \
        --skip-validate-spec
    ```

**IMPORTANT NOTE:** The gitignore file is configured to ignore the `languages/*/sdk` directories. These are only for local testing purposes and should not be checked in.

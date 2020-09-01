# Generator for Analytics API Engines SDKs

## Introduction

This repository contains all the configurations and customizations required to generate API client libraries (SDKs) for FactSet's Analytics API Engines product. It replies on the API's [OpenAPI Specification](https://github.com/OAI/OpenAPI-Specification) document and uses the [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator) tool for SDK generation.

Follow the below links for generated language specific SDK repositories.

* [Python](https://github.com/afernandes/analyticsapi-engines-python-sdk)
* [Dotnet](https://github.com/afernandes/analyticsapi-engines-dotnet-sdk)
* Java (WIP)

## Contents

* **[OpenAPI Specification](openapi-schema.json)** - The OpenAPI Specification document of the API
* **[Custom OpenAPI Generator](openapi-generator)** - Dockerized wrapper over OpenAPI Generator to support customizations
* **[Languages](languages)** - Directory containing OpenAPI Generator configurations `openapi-generator-config.json` and mustache template files `templates\*.mustache` to override default settings for individual languages

## Overview of the SDK generation process

![API SDK Automation Process Overview](./images/overview.png)
**Note:** The steps highlighted in green are all automated using [GitHub Action Worflows](https://docs.github.com/en/actions/configuring-and-managing-workflows).

## How to Contribute

There are different scenarios that might require changes to this repository. Follow the steps outlined in the below sections based on your requirement.

### To generate new version of the SDKs

1. Clone this repository and create a branch.
2. Replace `openapi-schema.json` with the latest version of API's OpenAPI Specification document.
3. Update the package versions in `languages/*/openapi-generator-config.json` files. Modify the rest of the configurations and template files as needed.
4. Raise a pull request with all above mentioned changes. This step will trigger a [GitHub Workflow](.github/workflows/pull-request.yml) that'll generate the SDKs and raise pull requests in each individual SDK repositories.
5. Review the SDK pull requests and make changes as needed. Do not manually edit the auto-generated SDK code. Modifications should only be made in the pull request created in step 4 and workflow will automatically apply them to the corresponding SDK pull requests. Follow these steps until the SDK looks good.
6. Update the tests and examples projects in the SDK repositories to match the latest SDK version.

### To configure a new language

1. Check if OpenAPI Generator supports the language - [supported client generator](https://openapi-generator.tech/docs/generators#client-generators).
2. If the language is supported, note the generator name for it. We'll call it `<<generator-name>>`.
3. Clone this repository and create a branch.
4. Add a new directory `languages/<<language-name>>`.
5. Create a configuration file `languages/<<language-name>>/openapi-generator-config.json`.
6. Add a directory `languages/<<language-name>>/templates`.
7. (Optional) Add custom templates for your generator. Check [OpenAPI Generator Templates](https://openapi-generator.tech/docs/templating) for more information.
8. (Optional) For most cases, modification to existing mustache template files will suffice but this repository adds a layer of [customization](https://openapi-generator.tech/docs/customization) and introduces custom generators (listed below). These allow you to add custom template files that are not supported by the default OpenAPI generator. For example, in this project the Utility API files `languages/*/utility_api.mustache` and `languages/*/utility_api_doc.mustache` (documentation) are added to each SDK and exposes helpful methods that users can leverage. Similar custom generators can be included in `openapi-generator/codegen/` directory or existing ones can be modified based on requirement.

    * CustomCSharpNetCoreClientCodegen
    * CustomPythonClientCodegen

9. Create the corresponding language SDK repository.
10. Add a new job to the [GitHub Workflow](.github/workflows/pull-request.yml) file as shown below to make the new language SDK generation part of the automated process.

```yml
...
...
env:
    GITHUB_<<language-name>>_SDK_REPO: <<sdk-repository-location>>
    GITHUB_<<language-name>>_SDK_FOLDER: <<sdk-folder-name>>
...
...
jobs:
...
...
    <<language-name>>:
        runs-on: ubuntu-latest

        steps:
        - name: Check out SDK repository
            if: env.GITHUB_<<language-name>>_SDK_REPO
            uses: actions/checkout@v2
            with:
            repository: ${{ env.GITHUB_<<language-name>>_SDK_REPO }}
            path: sdk
            fetch-depth: 0
            token: ${{ env.USER_API_KEY }}

        - name: Check out Generator repository
            if: env.GITHUB_<<language-name>>_SDK_REPO
            uses: actions/checkout@v2
            with:
            path: generator

        - name: Generate SDK
            if: env.GITHUB_<<language-name>>_SDK_REPO
            run: generator/.github/scripts/generate-sdk.sh $OPENAPI_GENERATOR_VERSION <<language-name>> <<generator-name>>

        - name: Raise pull request on SDK repository
            if: env.GITHUB_<<language-name>>_SDK_REPO
            run: generator/.github/scripts/raise-pull-request.sh <<language-name>> $GITHUB_<<language-name>>_SDK_FOLDER
```

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

2. Run the Docker image to generate SDK. The `languages/*/sdk` directory will contain the generated files. In the below script, replace the `<<generator-name>>` with standard OpenAPI generator names or custom ones supported by this repository.

    ```bash
    docker run --rm -v ${PWD}:/generator \
        openapi-generator-cli-custom generate \
        --generator-name <<generator-name>> \
        --input-spec /generator/openapi-schema.json \
        --output /generator/languages/<<directory-name>>/sdk \
        --config /generator/languages/<<directory-name>>/openapi-generator-config.json \
        --template-dir /generator/languages/<<directory-name>>/templates \
        --skip-validate-spec
    ```

**Important Note:** The gitignore file is configured to ignore the `languages/*/sdk` directories. These are only for local testing purposes and should not be checked in.

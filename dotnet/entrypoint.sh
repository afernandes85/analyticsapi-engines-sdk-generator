#!/bin/bash

BASE_PATH=/local/dotnet
PACKAGE_PATH=Schema/fds/protobuf/stach
PROTOFILES_PATH=/local/proto

rm $BASE_PATH/$PACKAGE_PATH/*.g.cs
rm $BASE_PATH/$PACKAGE_PATH/Table/*.g.cs

echo dotnet: Removed old dotnet classes

PROTOFILES=$(find $PROTOFILES_PATH -iname "*.proto")
protoc --proto_path $PROTOFILES_PATH --csharp_out $BASE_PATH/$PACKAGE_PATH --csharp_opt=file_extension=.g.cs,base_namespace=FactSet.Protobuf.Stach $PROTOFILES

echo dotnet: Generated dotnet classes successfully

dotnet run --configuration Release --project $BASE_PATH/Generator

echo dotnet: Built dotnet package
echo dotnet: Updated figures and examples

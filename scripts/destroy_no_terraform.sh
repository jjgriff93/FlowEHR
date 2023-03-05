#!/bin/bash
#  Copyright (c) University College London Hospitals NHS Foundation Trust
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SUFFIX=$(yq '.suffix' "$SCRIPT_DIR/../config.yaml")
ENVIRONMENT=$(yq '.environment' "$SCRIPT_DIR/../config.yaml")

[[ -z "${SUFFIX_OVERRIDE:-}" ]] && NAMING_SUFFIX="$SUFFIX-$ENVIRONMENT" || NAMING_SUFFIX="$SUFFIX_OVERRIDE"

az group list -o table | while read -r line ; do

  if echo "$line" | grep -q "${NAMING_SUFFIX}"; then
    rg_name=$(echo "$line" | awk '{print $1;}')

    # Skip databricks-managed rgs as these are deleted automatically
    if [[ "$line" != rg-dbks* ]]; then
      echo "Deleting ${rg_name}..."
      az group delete --resource-group "$rg_name" --yes
    fi
  fi

done

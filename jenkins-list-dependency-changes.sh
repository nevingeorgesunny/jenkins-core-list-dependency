#!/usr/bin/env bash
set -euo pipefail

# Prompt the user to enter versions
if [[ -z  "${OLD-''}" ]]; then
    read -p "Enter the old version: " OLD
fi
if [[ -z "${NEW-''}" ]]; then
    read -p "Enter the new version: " NEW
fi

# Colors for output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

get_war() {
    local version="${1}"

    echo -e "${CYAN}Running : ${YELLOW}mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion="${version}" -Dtransitive=false${NC}"
    mvn -q dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion="${version}" -Dtransitive=false
}

get_dependencie_list() {
    local version="${1}"

    echo -e "${CYAN}Running : ${YELLOW}jar --list --file [jenkins-war-${version}.war]${NC}"
    jar --list --file ${HOME}/.m2/repository/org/jenkins-ci/main/jenkins-war/${version}/jenkins-war-${version}.war | grep --extended-regexp "WEB-INF/lib/.*\.jar" | sort > ${version}_libs.txt
}

# Download the Jenkins war for old and new.
get_war ${OLD}
get_war ${NEW}
# Getting lists of libs from both versions.
get_dependencie_list ${OLD}
get_dependencie_list ${NEW}

set +e
# Compares the two libs listing.
## Diff commands returnss
##  - 0 when no diff
##  - 1 when there is diff
##  - >1 when there is a problem
diff --unified=0 ${OLD}_libs.txt ${NEW}_libs.txt > lib_diff.txt 2>&1
diff_exit=$?
if [[ $diff_exit -gt 1 ]]; then
  echo -e "Something wrong happened with the diff command"
  exit 1
fi
set -e

# Create compare URLs for Jenkins core
JENKINSCORE_COMPARE_URL="https://github.com/cloudbees/private-jenkins/compare/jenkins-$OLD...jenkins-$NEW"
echo -e "\n${CYAN}Jenkins core compare URL:${YELLOW} $JENKINSCORE_COMPARE_URL${NC}"
echo -e "${CYAN}Refernce for comparison URL for artifacts: ${YELLOW}https://docs.google.com/spreadsheets/d/1GY3yMmW8HsGzTTPIt_lSzZOQQ1UM0JFCswddY3oeuig/edit?usp=sharing${NC}"

# Generate diff and convert to HTML for dependency (optional: for diff2html to work you will need to install Node.js)
diff2html --title "Jenkins core jar compare $OLD VS $NEW" \
    --input file \
    --output stdout \
    --fileContentToggle false \
    -- lib_diff.txt > lib_diff.html

# Cleanup
rm ${OLD}_libs.txt ${NEW}_libs.txt

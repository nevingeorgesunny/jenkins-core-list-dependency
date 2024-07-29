#!/usr/bin/env bash
set -euo pipefail

# Prompt the user to enter versions
if [[ -z  "${VERSION_ONE-''}" ]]; then
    read -p "Enter the old version: " VERSION_ONE
fi
if [[ -z "${VERSION_TWO-''}" ]]; then
    read -p "Enter the new version: " VERSION_TWO
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

    echo -e "${CYAN}Running : ${YELLOW}unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/${version}/jenkins-war-${version}.war -d ${version}${NC}"
    unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/${version}/jenkins-war-${version}.war -d ${version}

    ls -1 ${version}/WEB-INF/lib/ > ${version}_libs.txt
}

# Download the older Jenkins war
get_war ${VERSION_ONE}

# Unzip its contents to VERSION_ONE folder
get_dependencie_list ${VERSION_ONE}

# Download the newer Jenkins war
get_war ${VERSION_TWO}

# Unzip its contents to VERSION_TWO folder
get_dependencie_list ${VERSION_TWO}

diff -u ${VERSION_ONE}_libs.txt ${VERSION_TWO}_libs.txt > lib_diff.txt

# Create compare URLs for Jenkins core
JENKINSCORE_COMPARE_URL="https://github.com/cloudbees/private-jenkins/compare/jenkins-$VERSION_ONE...jenkins-$VERSION_TWO"
echo -e "\n\n${CYAN}Jenkins core compare URL:${YELLOW} $JENKINSCORE_COMPARE_URL${NC}"

echo -e "${CYAN}Refernce for comparison URL for artifacts: ${YELLOW}https://docs.google.com/spreadsheets/d/1GY3yMmW8HsGzTTPIt_lSzZOQQ1UM0JFCswddY3oeuig/edit?usp=sharing${NC}"


# Generate diff and convert to HTML for dependency (optional: for diff2html to work you will need to install Node.js)
diff -u ${VERSION_ONE}_libs.txt ${VERSION_TWO}_libs.txt > diff_libs.txt
diff2html -t "Jenkins core jar compare $VERSION_ONE VS $VERSION_TWO" -i file -- diff_libs.txt > diff_libs.html 

# Cleanup
rm *diff* *version*
rm -rf $VERSION_ONE $VERSION_TWO

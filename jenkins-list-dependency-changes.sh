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

# Download the older Jenkins war
get_war ${VERSION_ONE}

# Unzip its contents to VERSION_ONE folder
echo -e "${CYAN}Running : ${YELLOW}unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_ONE/jenkins-war-$VERSION_ONE.war -d $VERSION_ONE${NC}\n\n"
unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_ONE/jenkins-war-$VERSION_ONE.war -d $VERSION_ONE

# Download the newer Jenkins war
get_war ${VERSION_TWO}

# Unzip its contents to VERSION_TWO folder
echo -e "${CYAN}Running : ${YELLOW}unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_TWO/jenkins-war-$VERSION_TWO.war -d $VERSION_TWO${NC}"
unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_TWO/jenkins-war-$VERSION_TWO.war -d $VERSION_TWO

# List out the jars in /WEB-INF/lib/ for each version and find the diff
ls -1 $VERSION_ONE/WEB-INF/lib/ > version_one_libs.txt
ls -1 $VERSION_TWO/WEB-INF/lib/ > version_two_libs.txt

diff -u version_one_libs.txt version_two_libs.txt > lib_diff.txt

# Output the differences
printf "\n\n\n"

echo -e "${CYAN}$VERSION_ONE ${YELLOW}dependency:${NC}"
cat version_one_libs.txt

printf "\n\n"

echo -e "${CYAN}$VERSION_TWO ${YELLOW}dependency:${NC}"
cat version_two_libs.txt

# Create compare URLs for Jenkins core
JENKINSCORE_COMPARE_URL="https://github.com/cloudbees/private-jenkins/compare/jenkins-$VERSION_ONE...jenkins-$VERSION_TWO"
echo -e "\n\n${CYAN}Jenkins core compare URL:${YELLOW} $JENKINSCORE_COMPARE_URL${NC}"

echo -e "${CYAN}Refernce for comparison URL for artifacts: ${YELLOW}https://docs.google.com/spreadsheets/d/1GY3yMmW8HsGzTTPIt_lSzZOQQ1UM0JFCswddY3oeuig/edit?usp=sharing${NC}"


# Generate diff and convert to HTML for dependency (optional: for diff2html to work you will need to install Node.js)
diff -u version_one_libs.txt version_two_libs.txt > diff_libs.txt
diff2html -t "Jenkins core jar compare $VERSION_ONE VS $VERSION_TWO" -i file -- diff_libs.txt > diff_libs.html 

# Cleanup
rm *diff* *version*
rm -rf $VERSION_ONE $VERSION_TWO

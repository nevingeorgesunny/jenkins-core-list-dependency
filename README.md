# Jenkins Dependencies Comparator
This shell script is designed to list the dependencies of two different versions of Jenkins. It also lists the differences between the two versions and provides URLs and reference documentation containing GitHub comparison links for most of the jars.

## Features
- List all jar in `WEB-INF/lib/*.jar` for each version
- Optinally it will alos do a diff of the above step 
- Lists out a few github compare URLs for easy access for checking jar diff

## How does it work
- Fetches the older jenkins war file with `mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion=$VERSION_ONE -Dtransitive=false`
- Unzips it to a folder `unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_ONE/jenkins-war-$VERSION_ONE.war -d $VERSION_ONE`
- Fetches the newer jenkins war file with `mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion=$VERSION_TWO -Dtransitive=false`
- Unzios the newer one `unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_TWO/jenkins-war-$VERSION_TWO.war -d $VERSION_TWO`
- list out and comare the diff between `/WEB-INF/lib/*`

## Usage 
- clone the code
- cd to the folder
- run these
  ```bash
  chmod +x jenkins-list-dependency-changes.sh
  ./jenkins-list-dependency-changes.sh
  ```
- Follow the prompts to enter the Jenkins versions you want to compare:
  ```bash
  Enter the old version: <older_version>
  Enter the new version: <newer_version>
  ```

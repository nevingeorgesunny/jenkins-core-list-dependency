# jenkins-core-dependencies-list
This shell script is designed to list the dependencies of two different versions of Jenkins, so as to compare the version between each jars

## Features
- List all jar in `WEB-INF/lib/*.jar` for each version
- Optionally it will also do a diff of the above step 
- Lists out a few GitHub compare URLs for easy access for checking jar diff

## How does it work
- Fetches the older Jenkins war file with `mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion=$VERSION_ONE -Dtransitive=false`
- Unzips it to a folder `unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_ONE/jenkins-war-$VERSION_ONE.war -d $VERSION_ONE`
- Fetches the newer Jenkins war file with `mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion=$VERSION_TWO -Dtransitive=false`
- Unzips the newer one `unzip -q ~/.m2/repository/org/jenkins-ci/main/jenkins-war/$VERSION_TWO/jenkins-war-$VERSION_TWO.war -d $VERSION_TWO`
- list out and compare the diff between `/WEB-INF/lib/*`

## Usage 
- clone the code
- cd to the folder
- make sure the `maven` and `unzip` are installed
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
## Sample Output
<img width="879" alt="image" src="https://github.com/user-attachments/assets/d2fc5ba6-925e-4c4f-b5a0-e8353afd6dfd">

## To view the diff (optional Step)
the script also creates a html diff using diff2html. To use diff2html, you need Node.js installed on your system. If diff2html is not installed, the script will just throw a warning. You will need to do the diff on your own

how to do this on mac
```bash
brew install node
npm install diff2html
npm install diff2html-cli
```

how to do this on ubuntu
```bash
apt install -y nodejs
apt install -y npm
npm install diff2html
npm install diff2html-cli
```

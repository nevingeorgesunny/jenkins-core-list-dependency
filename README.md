# Jenkins Core Dependencies List
This shell script is designed to list the dependencies of two different versions of Jenkins, so as to compare the version between each jars

## Features
- List all jar in `WEB-INF/lib/*.jar` for each version
- Optionally it will also do a diff of the above step 
- Lists out a few GitHub compare URLs for easy access for checking jar diff

## How does it work
- Fetches the older Jenkins war file with `mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion=$VERSION_ONE -Dtransitive=false`
- Uses `jar` CLI to list the content of the war
- Fetches the newer Jenkins war file with `mvn dependency:get -DartifactId=jenkins-war -DgroupId=org.jenkins-ci.main -Dpackaging=war -Dversion=$VERSION_TWO -Dtransitive=false`
- List the content of the newest war with `jar` CLI
- list out and compare the diff between `/WEB-INF/lib/*`

## Usage 
- clone the code
- cd to the folder
- make sure the `maven`, `jar`, and `diff2html-cli` are installed
- run these
  ```bash
  OLD=<old_version> NEW=<new_version> bash jenkins-list-dependency-changes.sh
  ```
## Sample Output
![GIF Recording 2024-07-30 at 6 00 20 PM](https://github.com/user-attachments/assets/c490ecd3-b8e2-43ef-b6cc-7315fc1c3cb0)



## To view the diff (optional Step)
the script also creates a html diff using diff2html. To use diff2html, you need Node.js installed on your system. If diff2html is not installed, the script will just throw a warning. You will need to do the diff on your own

how to do this:
```bash
asdf install node stable
npm install -g diff2html-cli
```

#!/bin/sh

# Issue tracking for Bitbucket

# Colors, thanks stackoverflow

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

RED='\033[0;31m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

dir=$(git rev-parse --show-toplevel)
status=$?

get_repo() {
	gitrepo=$(cut -d "/" -f 5 <<< "$url")
	repo=$(cut -d "." -f 1 <<< "$gitrepo")
}

get_owner() {
	owner=$(cut -d "/" -f 4 <<< "$url")
}

get_issues() {
	read -p 'Username: ' username
	url=$(grep "bitbucket" "$dir/.git/config")
	get_owner
	get_repo
	raw_issues=$(curl -s -S --user $username "https://api.bitbucket.org/1.0/repositories/${owner}/${repo}/issues?status=new&responsible=${username}" | jq .issues[]) #  | "\(.title)_sEp_#!%\(.reported_by .username)_sEp_#!%\(.content)_sEp_#!%\(.local_id)_sEp_#!%\(.utc_created_on)"')
	issues=$(echo "$raw_issues" | jq '. | "\(.title)_sEp_#!%\(.reported_by .username)_sEp_#!%\(.content)_sEp_#!%\(.local_id)_sEp_#!%\(.utc_created_on)"')

	OIFS="$IFS"
	IFS=$'\n'
	for issue in $issues
	do
		issue_title=$(echo $issue | awk -F'_sEp_#!%' '{print $1}')
		issue_title=$(echo ${issue_title:1})
		issue_author=$(echo $issue | awk -F'_sEp_#!%' '{print $2}')
		issue_content=$(echo $issue | awk -F'_sEp_#!%' '{print $3}')
		issue_id=$(echo $issue | awk -F'_sEp_#!%' '{print $4}')
		issue_date=$(echo $issue | awk -F'_sEp_#!%' '{print $5}')
		issue_date=$(echo ${issue_date::-1})
		echo
		echo -e "${LIGHT_BLUE}issue #${issue_id}: $issue_title"
		echo -e "${NC}author: ${issue_author}"
		echo -e "${NC}date: ${issue_date}"
		echo
		echo -e "${NC} ${issue_content}"
	done
	IFS="$OIFS"
}

if [ "$status" -eq "0" ]
then 
      get_issues
else
	  echo "Not a git repo"
fi


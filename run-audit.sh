#!/bin/sh

set +e

AUDIT_FILE=/tmp/audit.json

# capture audit to file
pnpm audit --json > $AUDIT_FILE

# get the counts
HIGH_COUNT=$(cat $AUDIT_FILE | jq -r '.metadata.vulnerabilities | .high')
CRITICAL_COUNT=$(cat $AUDIT_FILE | jq -r '.metadata.vulnerabilities | .critical')
COUNT=$((HIGH_COUNT + CRITICAL_COUNT))

# if there are any vulnerabilities, create a branch and PR
if [[ $COUNT -gt 0 ]]; then
  TIMESTAMP=$(date +%s)
  BRANCH_NAME=audit-fixes-$TIMESTAMP
  git config user.name "PNPM Dependabot"
  git config user.email "<>"
  git checkout -b $BRANCH_NAME
  pnpm audit --fix
  pnpm install --no-frozen-lockfile
  git commit -am "fix: pnpm audit errors"
  git push origin $BRANCH_NAME

  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $ACTIONS_RUNTIME_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$GITHUB_REPOSITORY_OWNER/$GITHUB_REPOSITORY/labels \
    -d '{"name":"Security","description":"Audit fixes","color":"ff0000"}'

  PR_TITLE="fix: pnpm audit fixes $(date +"%m/%d/%Y")"
  PR_BODY="This PR fixes the following vulnerabilities:\n\n$(cat $AUDIT_FILE | jq -r '.advisories | to_entries[] | .key + " ###" + .value.module_name + " " + .value.title + "\n\n*References*\n" + .value.references')"
  PR_LABEL="Security"

  #  gh label create "Security" --color "ff0000"
  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $ACTIONS_RUNTIME_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/OWNER/REPO/pulls \
    -d "{\"title\":\"$PR_TITLE\",\"body\":\"$PR_BODY\",\"head\":\"$GITHUB_HEAD_REF\",\"base\":\"$GITHUB_BASE_REF\",\"label\":\"$PR_LABEL\"}"

#  gh pr create \
#    --title "fix: pnpm audit fixes $(date +"%m/%d/%Y")" \
#    --body "This PR fixes the following vulnerabilities:\n\n$(cat $AUDIT_FILE | jq -r '.advisories | to_entries[] | .key + " ###" + .value.module_name + " " + .value.title + "\n\n*References*\n" + .value.references')" \
#    --label "Security"
fi

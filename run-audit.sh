# dont like exit 1 blow up the run
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
  PRETTY_DATE=$(date +"%m/%d/%Y")
  BRANCH_NAME=audit-fixes-$TIMESTAMP
  git config user.name "PNPM Dependabot"
  git config user.email "<>"
  git checkout -b $BRANCH_NAME
  pnpm audit --fix
  pnpm install --no-frozen-lockfile
  git commit -am "fix: pnpm audit errors $PRETTY_DATE"
  git push origin $BRANCH_NAME
  gh label create "Security" --color "ff0000"
  gh pr create \
    --title "fix: pnpm audit fixes $PRETTY_DATE" \
    --body "This PR fixes the following vulnerabilities:\n\n$(cat $AUDIT_FILE | jq -r '.advisories | to_entries[] | .key + " *" + .value.module_name + "* " + .value.title + "\n\n*References*\n" + .value.references')" \
    --label "Security"
fi

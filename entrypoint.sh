#!/bin/sh -l

git config user.name "Automated Publisher"
git config user.email "publish-to-github-action@users.noreply.github.com"

mkdir -p ${1}
# git diff-tree --no-commit-id --name-only -r ${{ github.sha }}
for f in `git  diff-tree --no-commit-id --name-only -r ${{ github.sha }}`; do
	echo "found new file: $f";
	cp --parents  $f ${1};
done

mkdir -p /github/workspace/artifacts

cd /scancode-toolkit
./scancode \
	-clipeu \
	--license-diag \
	--classify \
	--summary \
	--verbose /github/workspace/$1 \
	--processes `expr $(nproc --all) - 1` \
	--json /github/workspace/artifacts/scancode.json \
	--html /github/workspace/artifacts/scancode.html


python /license_check.py -c /github/workspace/.github/license_config.yml -s /github/workspace/artifacts/scancode.json  -f /github/workspace/$1 -o /github/workspace/artifacts/report.txt

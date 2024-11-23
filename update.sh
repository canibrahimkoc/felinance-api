
git_repo=git config --get remote.origin.url
git_url=pwd

cd "$git_url" || return 1

if [ ! -d ".git" ]; then
    git init
fi
git remote set-url origin "$git_repo"

if ! git show-ref --verify --quiet refs/heads/main; then
    echo "Main branch does not exist. Creating it now..."
    git checkout -b main
fi

git config pull.rebase false && git fetch origin
commit_count=$(git rev-list --count HEAD)

if [ $commit_count -eq 0 ]; then
    version="v0.1"
else
    major_version=$((commit_count / 10))
    minor_version=$((commit_count % 10))
    version="v${major_version}.${minor_version}"
fi

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "New version available, pulling updates..."
    git pull origin main --no-edit
else
    echo "You are on the latest version. $git_url $version"
fi

if [[ $(git status --porcelain) ]]; then
    echo "Local changes detected, committing..."
    git add .
    git commit -m "$version"
    git push origin main
    echo "Changes successfully pushed. New version: $git_url $version"
else
    echo "No local changes. Current version: $git_url $version"
fi

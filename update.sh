git-update() {
    # Ask for the git_repo name
    # read -p "Enter the git repository name: " git_repo
    git_repo=felinance-api

    # Check if the directory exists
    if [ ! -d "/opt/$git_repo" ]; then
        echo "Repository $git_repo does not exist in /opt/. Cloning it now..."
        git clone "git@github.com:canibrahimkoc/$git_repo.git" "/opt/$git_repo"
        if [ $? -ne 0 ]; then
            echo "Failed to clone the repository. Please check the repository name and your permissions."
            return 1
        fi
    fi

    # Change to the repository directory
    cd "/opt/$git_repo" || return 1

    # Initialize repository if not already initialized
    if [ ! -d ".git" ]; then
        git init
    fi

    # Set the remote URL
    git remote set-url origin "git@github.com:canibrahimkoc/$git_repo.git"

    # Check if the main branch exists
    if ! git show-ref --verify --quiet refs/heads/main; then
        echo "Main branch does not exist. Creating it now..."
        git checkout -b main
    fi

    # Configure pull strategy
    git config pull.rebase false

    # Fetch from origin
    git fetch origin

    # Calculate version
    commit_count=$(git rev-list --count HEAD)
    if [ $commit_count -eq 0 ]; then
        version="v0.1"
    else
        major_version=$((commit_count / 10))
        minor_version=$((commit_count % 10))
        version="v${major_version}.${minor_version}"
    fi

    # Check for updates
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "New version available, pulling updates..."
        git pull origin main --no-edit
    else
        echo "You are on the latest version. $git_repo $version"
    fi

    # Check for local changes
    if [[ $(git status --porcelain) ]]; then
        echo "Local changes detected, committing..."
        git add .
        git commit -m "$version"
        git push origin main
        echo "Changes successfully pushed. New version: $git_repo $version"
    else
        echo "No local changes. Current version: $git_repo $version"
    fi
}

# Call the function
git-update
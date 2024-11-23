#!/bin/bash

git_repo=$(git config --get remote.origin.url)  # Git reposunun URL'sini al
git_url=$(pwd)  # Geçerli dizinin yolunu al

cd "$git_url" || exit 1  # Git repo dizinine git, hata durumunda çık

if [ ! -d ".git" ]; then
    git init  # Eğer Git repo'su yoksa başlat
fi

git remote set-url origin "$git_repo"  # Uzak repo URL'sini ayarla

if ! git show-ref --verify --quiet refs/heads/main; then
    echo "Main branch does not exist. Creating it now..."
    git checkout -b main  # Main branch yoksa oluştur
fi

git config pull.rebase false && git fetch origin  # Uzak repo'dan verileri çek
commit_count=$(git rev-list --count HEAD)  # Toplam commit sayısını al

if [ $commit_count -eq 0 ]; then
    version="v0.1"  # İlk commitse v0.1
else
    major_version=$((commit_count / 10))
    minor_version=$((commit_count % 10))
    version="v${major_version}.${minor_version}"  # Sürüm numarasını oluştur
fi

LOCAL=$(git rev-parse HEAD)  # Lokal commit ID'sini al 
REMOTE=$(git rev-parse origin/main)  # Uzak main branch commit ID'sini al

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "New version available, pulling updates..."
    git pull origin main --no-edit  # Uzak repo'dan main branch'ı çek
else
    echo "You are on the latest version. $git_url $version"
fi

if [[ $(git status --porcelain) ]]; then
    echo "Local changes detected, committing..."
    git add .  # Yerel değişiklikleri ekle
    git commit -m "$version"  # Commit mesajı olarak sürüm numarasını kullan
    git push origin main  # Değişiklikleri uzak repo'ya gönder
    echo "Changes successfully pushed. New version: $git_url $version"
else
    echo "No local changes. Current version: $git_url $version"
fi

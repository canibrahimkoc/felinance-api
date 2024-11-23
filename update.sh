#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'


log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] HATA: $1${NC}" >&2
    exit 1
}

if [ ! -d ".git" ]; then
    error "Bu dizin bir Git deposu değil."
fi

remote_url=$(git config --get remote.origin.url || echo "")
if [ -z "$remote_url" ]; then
    error "Git remote URL ayarlanmamış. Lütfen 'git remote add origin <URL>' komutunu çalıştırın."
fi

current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
if [ "$current_branch" = "HEAD" ]; then
    current_branch="main"
fi

log "Git deposu güncelleniyor..."

log "Remote değişiklikler kontrol ediliyor..."
if ! git fetch origin $current_branch; then
    error "Uzak depodan veri çekilemedi. Remote URL'yi kontrol edin."
fi

LOCAL=$(git rev-parse HEAD 2>/dev/null || echo "")
REMOTE=$(git rev-parse origin/$current_branch 2>/dev/null || echo "")

if [ -z "$LOCAL" ] || [ -z "$REMOTE" ]; then
    error "Branch bilgileri alınamadı."
fi

if [ "$LOCAL" != "$REMOTE" ]; then
    log "Yeni güncellemeler mevcut, değişiklikler çekiliyor..."
    if ! git pull origin $current_branch; then
        error "Güncellemeler çekilemedi. Lütfen yerel değişiklikleri kontrol edin."
    fi
fi

commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
major_version=$((commit_count / 10))
minor_version=$((commit_count % 10))
version="v${major_version}.${minor_version}"

if [[ $(git status --porcelain) ]]; then
    log "Yerel değişiklikler tespit edildi..."
    
    if ! git config user.name >/dev/null || ! git config user.email >/dev/null; then
        log "Git kullanıcı bilgileri ayarlanıyor..."
        git config user.name "root"
        git config user.email "git@github.com"
    fi

    if ! rm -f .git/index; then
        error "Eski dosyalar silinemedi."
    fi

    if ! git add .; then
        error "Değişiklikler eklenemedi."
    fi
    
    if ! git commit -m "$version"; then
        error "Commit oluşturulamadı."
    fi
    
    if ! git push origin $current_branch; then
        error "Değişiklikler uzak depoya gönderilemedi."
    fi
    
    log "Değişiklikler başarıyla gönderildi. Yeni versiyon: $version"
else
    log "Yerel değişiklik yok. Mevcut versiyon: $version"
fi

log "İşlem başarıyla tamamlandı."
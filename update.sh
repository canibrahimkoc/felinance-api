#!/bin/bash

set -e  # Herhangi bir hata durumunda scripti durdur

# Renkli log mesajları için
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonksiyonlar
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] HATA: $1${NC}" >&2
    exit 1
}

# Git repo kontrolü
if [ ! -d ".git" ]; then
    error "Bu dizin bir Git deposu değil."
fi

# Remote URL'yi kontrol et ve ayarla
remote_url=$(git config --get remote.origin.url || echo "")
if [ -z "$remote_url" ]; then
    error "Git remote URL ayarlanmamış. Lütfen 'git remote add origin <URL>' komutunu çalıştırın."
fi

# Branch kontrolü
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
if [ "$current_branch" = "HEAD" ]; then
    current_branch="main"
fi

log "Git deposu güncelleniyor..."

# Uzak depodan değişiklikleri çek
log "Remote değişiklikler kontrol ediliyor..."
if ! git fetch origin $current_branch; then
    error "Uzak depodan veri çekilemedi. Remote URL'yi kontrol edin."
fi

# Yerel ve uzak commit'leri karşılaştır
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

# Versiyon numarasını oluştur
commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
major_version=$((commit_count / 10))
minor_version=$((commit_count % 10))
version="v${major_version}.${minor_version}"

# Yerel değişiklikleri kontrol et ve gönder
if [[ $(git status --porcelain) ]]; then
    log "Yerel değişiklikler tespit edildi..."
    
    # Git kullanıcı bilgilerini kontrol et
    if ! git config user.name >/dev/null || ! git config user.email >/dev/null; then
        log "Git kullanıcı bilgileri ayarlanıyor..."
        git config user.name "System Updater"
        git config user.email "system@update.local"
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
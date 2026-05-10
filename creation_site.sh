#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           🚀  DEPLOYER PRO  v4.1                             ║
# ║  Tout conteneurisé avec Docker + PM2 universel               ║
# ║  static │ vue │ react │ vite │ next │ node                   ║
# ║  php │ laravel │ symfony                                      ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Palette ────────────────────────────────────────────────────
GREEN='\033[1;32m'; BLUE='\033[1;34m';   YELLOW='\033[1;33m'
RED='\033[1;31m';   PURPLE='\033[1;35m'; CYAN='\033[1;36m'
BOLD='\033[1m';     DIM='\033[2m';       RESET='\033[0m'

# ── État global ────────────────────────────────────────────────
START_TIME=$(date +%s)
STEP_START=$START_TIME
CURRENT_STEP=0
TOTAL_STEPS=13
DEPLOY_SUCCESS=false
BACKUP_PATH=""
WEB_DIR=""
APP_PORT=8080
CONTAINER_PORT=80
PROJECT_TYPE=""

# ══════════════════════════════════════════════════════════════
#  FONCTIONS VISUELLES
# ══════════════════════════════════════════════════════════════

_elapsed_step()  { echo "$(( $(date +%s) - STEP_START ))s"; }
_elapsed_total() {
  local s=$(( $(date +%s) - START_TIME ))
  printf "%dm%02ds" $(( s/60 )) $(( s%60 ))
}

progress_bar() {
  local cur=$1 tot=$2 w=40
  local filled=$(( cur * w / tot ))
  local empty=$(( w - filled ))
  local pct=$(( cur * 100 / tot ))
  printf "  ${GREEN}"
  for ((i=0; i<filled; i++)); do printf "█"; done
  printf "${DIM}"
  for ((i=0; i<empty; i++)); do printf "░"; done
  printf "${RESET}  ${BOLD}%3d%%${RESET}  ${DIM}(%d/%d)${RESET}\n" "$pct" "$cur" "$tot"
}

step() {
  [ "$CURRENT_STEP" -gt 0 ] && \
    printf "  ${DIM}⏱  terminé en %s${RESET}\n" "$(_elapsed_step)"
  CURRENT_STEP=$1; STEP_START=$(date +%s)
  echo ""
  echo -e "${BLUE}╔══════════════════════════════════════════════╗${RESET}"
  printf  "${BLUE}║${RESET}  ${BOLD}[%s/%s]${RESET}  %-38s${BLUE}║${RESET}\n" \
    "$CURRENT_STEP" "$TOTAL_STEPS" "$2"
  echo -e "${BLUE}╚══════════════════════════════════════════════╝${RESET}"
  progress_bar "$CURRENT_STEP" "$TOTAL_STEPS"
  echo ""
}

success() { echo -e "  ${GREEN}✔${RESET}  $1"; }
warning() { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
info()    { echo -e "  ${CYAN}ℹ${RESET}  $1"; }
skip()    { echo -e "  ${DIM}↷${RESET}  ${DIM}Ignoré : $1${RESET}"; }
error()   {
  echo -e "\n  ${RED}╔══════════════════════════════╗${RESET}"
  echo -e   "  ${RED}║  ✖  ERREUR FATALE            ║${RESET}"
  echo -e   "  ${RED}╚══════════════════════════════╝${RESET}"
  echo -e   "  ${RED}$1${RESET}\n"; exit 1
}

spinner() {
  local msg="$1"; shift
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  ("$@") > /tmp/_deploy_out 2>&1 &
  local pid=$! i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}%s${RESET}  %s" "${frames[$i]}" "$msg"
    i=$(( (i+1) % 10 )); sleep 0.1
  done
  wait "$pid"; local rc=$?
  printf "\r%-60s\r" " "
  [ $rc -eq 0 ] && success "$msg" || { cat /tmp/_deploy_out; error "$msg — voir les logs ci-dessus"; }
}

_has() {
  command -v "$1" &>/dev/null \
    || [ -x "/usr/sbin/$1" ] \
    || [ -x "/usr/local/sbin/$1" ]
}

_path() {
  command -v "$1" 2>/dev/null \
    || { [ -x "/usr/sbin/$1"       ] && echo "/usr/sbin/$1"; } \
    || { [ -x "/usr/local/sbin/$1" ] && echo "/usr/local/sbin/$1"; } \
    || echo "(non trouvé)"
}

# ── Sanitize un nom pour l'utiliser comme identifiant DB ──────
# Remplace tout ce qui n'est pas alphanumérique par _
# et force les minuscules
_db_safe() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_' | sed 's/_*$//'
}

# ══════════════════════════════════════════════════════════════
#  ROLLBACK AUTOMATIQUE
# ══════════════════════════════════════════════════════════════
_rollback() {
  if [ "$DEPLOY_SUCCESS" != "true" ] && [ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ]; then
    echo ""
    warning "Déploiement échoué — rollback en cours…"
    sudo rm -rf "$WEB_DIR" 2>/dev/null || true
    sudo mv "$BACKUP_PATH" "$WEB_DIR"
    success "Rollback effectué depuis $BACKUP_PATH"
  fi
}
trap '_rollback' EXIT

# ══════════════════════════════════════════════════════════════
#  GÉNÉRATION DOCKERFILE
# ══════════════════════════════════════════════════════════════
_generate_dockerfile() {
  local type=$1
  info "Génération du Dockerfile pour le type '$type'…"

  case $type in

    static)
      cat > Dockerfile <<'EOF'
FROM nginx:alpine
COPY . /usr/share/nginx/html/
RUN printf 'server{\n  listen 80;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / { try_files $uri $uri/ /index.html; }\n}' \
    > /etc/nginx/conf.d/default.conf
EXPOSE 80
EOF
      ;;

    vue|react|vite)
      cat > Dockerfile <<'EOF'
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html/
RUN printf 'server{\n  listen 80;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / { try_files $uri $uri/ /index.html; }\n  location ~* \.(js|css|png|jpg|svg|ico|woff2)$ { expires 1y; add_header Cache-Control "public,immutable"; }\n}' \
    > /etc/nginx/conf.d/default.conf
EXPOSE 80
EOF
      ;;

    next)
      # Vérifie si le projet a output: 'standalone' dans next.config
      if grep -rq "standalone" "${WEB_DIR}/next.config"* 2>/dev/null; then
        cat > Dockerfile <<'EOF'
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
EOF
      else
        # Sans standalone, on sert avec next start
        cat > Dockerfile <<'EOF'
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/package*.json ./
RUN npm ci --omit=dev
EXPOSE 3000
CMD ["npx", "next", "start"]
EOF
        warning "next.config sans 'standalone' → démarrage via 'next start' (moins optimisé)"
        info "Ajoutez output: 'standalone' dans next.config pour une image plus légère"
      fi
      ;;

    node)
      # Détecte le point d'entrée
      local entry="src/index.js"
      if [ -f "${WEB_DIR}/package.json" ]; then
        local main_field
        main_field=$(grep -oP '"main"\s*:\s*"\K[^"]+' "${WEB_DIR}/package.json" 2>/dev/null || echo "")
        [ -n "$main_field" ] && entry="$main_field"
      fi
      cat > Dockerfile <<EOF
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE $APP_PORT
CMD ["node", "$entry"]
EOF
      ;;

    php)
      cat > Dockerfile <<'EOF'
FROM php:8.2-apache
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql \
    && a2enmod rewrite
COPY . /var/www/html/
EXPOSE 80
EOF
      ;;

    laravel)
      cat > Dockerfile <<'EOF'
FROM php:8.2-apache
RUN apt-get update -qq && apt-get install -y -qq zip unzip curl \
    && docker-php-ext-install pdo pdo_mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && a2enmod rewrite
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader \
    && php artisan key:generate 2>/dev/null || true \
    && chown -R www-data:www-data storage bootstrap/cache
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' \
        /etc/apache2/sites-available/000-default.conf
EXPOSE 80
EOF
      ;;

    symfony)
      cat > Dockerfile <<'EOF'
FROM php:8.2-apache
RUN apt-get update -qq && apt-get install -y -qq zip unzip curl \
    && docker-php-ext-install pdo pdo_pgsql intl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && a2enmod rewrite
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN printf '<Directory /var/www/html/public>\n  AllowOverride All\n  Require all granted\n</Directory>' \
    >> /etc/apache2/apache2.conf \
    && sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' \
        /etc/apache2/sites-available/000-default.conf
EXPOSE 80
EOF
      ;;

  esac
  success "Dockerfile généré"
}

# ══════════════════════════════════════════════════════════════
#  BANNER
# ══════════════════════════════════════════════════════════════
clear
echo -e "${PURPLE}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║        🚀  DEPLOYER PRO  v4.1                ║"
echo "  ║  Tout conteneurisé : Docker + PM2 + Nginx     ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 1 — Dépendances système
# ══════════════════════════════════════════════════════════════
step 1 "Vérification des dépendances système"

MISSING=()
for bin in nginx git certbot curl; do
  if _has "$bin"; then
    success "$bin  ($(_path "$bin"))"
  else
    warning "$bin manquant"
    MISSING+=("$bin")
  fi
done

[ ${#MISSING[@]} -gt 0 ] && \
  error "Paquets manquants : ${MISSING[*]}\nInstallez : sudo apt install ${MISSING[*]}"

if ! _has docker; then
  warning "Docker non installé — installation automatique…"
  spinner "Installation de Docker" bash -c 'curl -fsSL https://get.docker.com | sh'
  sudo usermod -aG docker "$USER"
  info "Docker installé — vous devrez peut-être vous reconnecter pour les droits groupe"
else
  success "docker  ($(_path docker))"
fi

if ! _has pm2; then
  _has npm || error "npm requis pour installer PM2 — installez Node.js d'abord"
  spinner "Installation de PM2" sudo npm install -g pm2
else
  success "pm2  ($(_path pm2))"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 2 — Informations & choix du type
# ══════════════════════════════════════════════════════════════
step 2 "Informations & type de projet"

read -rp "  Nom du projet       : " nameproject
read -rp "  Domaine (ex: a.com) : " fulldomain
read -rp "  URL du dépôt GitHub : " REPO_URL

REPO_PATH="${REPO_URL#*github.com/}"; REPO_PATH="${REPO_PATH%.git}"
info "Analyse du dépôt GitHub…"
API=$(curl -sf "https://api.github.com/repos/$REPO_PATH/contents" 2>/dev/null || echo "")
PKG=$(curl -sf "https://raw.githubusercontent.com/$REPO_PATH/main/package.json" 2>/dev/null || echo "")

if   echo "$API"  | grep -q '"composer.json"' && echo "$PKG" | grep -qi '"laravel"'; then
  AUTO_TYPE="laravel"
elif echo "$API"  | grep -q '"composer.json"' && curl -sf "https://raw.githubusercontent.com/$REPO_PATH/main/composer.json" 2>/dev/null | grep -qi '"symfony"'; then
  AUTO_TYPE="symfony"
elif echo "$API"  | grep -q '"composer.json"'; then
  AUTO_TYPE="php"
elif echo "$PKG" | grep -qi '"next"';  then AUTO_TYPE="next"
elif echo "$PKG" | grep -qi '"react"'; then AUTO_TYPE="react"
elif echo "$PKG" | grep -qi '"vue"';   then AUTO_TYPE="vue"
elif echo "$PKG" | grep -qi '"vite"';  then AUTO_TYPE="vite"
elif echo "$API" | grep -q '"package.json"'; then AUTO_TYPE="node"
else AUTO_TYPE="static"
fi

echo ""
echo -e "  ${BOLD}Type détecté : ${CYAN}$AUTO_TYPE${RESET}"
echo ""
echo -e "  ${BOLD}Choisissez le type :${RESET}"
echo -e "  ${DIM}─── Frontend statique ────────────────────────────${RESET}"
echo -e "  [1] static    HTML/CSS/JS pur → Nginx"
echo -e "  [2] vue       Vue 3 / Nuxt 3 (build) → Nginx"
echo -e "  [3] react     React + Vite/CRA (build) → Nginx"
echo -e "  [4] vite      Vite générique (build) → Nginx"
echo -e "  ${DIM}─── Node.js ───────────────────────────────────────${RESET}"
echo -e "  [5] next      Next.js SSR/SSG → Node"
echo -e "  [6] node      Express / Fastify / API → Node"
echo -e "  ${DIM}─── PHP ───────────────────────────────────────────${RESET}"
echo -e "  [7] php       PHP générique → Apache"
echo -e "  [8] laravel   Laravel → Apache + php-fpm"
echo -e "  [9] symfony   Symfony → Apache + php-fpm"
echo ""

declare -A DEFAULT_PORTS=([static]=8080 [vue]=8080 [react]=8080 [vite]=8080
                          [next]=3000   [node]=3001
                          [php]=8090    [laravel]=8090 [symfony]=8090)
declare -A TYPE_MAP=([1]=static [2]=vue [3]=react [4]=vite
                    [5]=next   [6]=node
                    [7]=php    [8]=laravel [9]=symfony)

DEFAULT_NUM=1
for k in "${!TYPE_MAP[@]}"; do
  [ "${TYPE_MAP[$k]}" = "$AUTO_TYPE" ] && DEFAULT_NUM=$k
done

read -rp "  Votre choix [$DEFAULT_NUM] : " type_choice
type_choice="${type_choice:-$DEFAULT_NUM}"
PROJECT_TYPE="${TYPE_MAP[$type_choice]:-$AUTO_TYPE}"

DEFAULT_PORT="${DEFAULT_PORTS[$PROJECT_TYPE]:-8080}"
read -rp "  Port hôte [$DEFAULT_PORT] : " input_port
APP_PORT="${input_port:-$DEFAULT_PORT}"

case $PROJECT_TYPE in
  next) CONTAINER_PORT=3000 ;;
  node) CONTAINER_PORT=$APP_PORT ;;
  *)    CONTAINER_PORT=80 ;;
esac

echo ""
echo -e "  ${BOLD}Récapitulatif${RESET}"
echo -e "  🏷️  Projet   : ${CYAN}$nameproject${RESET}"
echo -e "  🌐 Domaine   : ${CYAN}$fulldomain${RESET}"
echo -e "  📦 Type      : ${GREEN}${BOLD}$PROJECT_TYPE${RESET}"
echo -e "  🔌 Port hôte : ${CYAN}$APP_PORT${RESET}  →  container :${CYAN}$CONTAINER_PORT${RESET}"
echo ""
read -rp "  Confirmer ? [O/n] : " confirm
[[ "${confirm,,}" == "n" ]] && exit 0

DOCKER_NAME=$(echo "$nameproject" | tr '[:upper:]' '[:lower:]' | tr ' _' '--')

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 3 — Backup
# ══════════════════════════════════════════════════════════════
step 3 "Backup de l'existant"

WEB_DIR="/var/www/html/$fulldomain"

if [ -d "$WEB_DIR" ]; then
  BACKUP_PATH="/var/backups/${fulldomain}_$(date +%Y%m%d_%H%M%S)"
  sudo mkdir -p /var/backups
  spinner "Sauvegarde → $BACKUP_PATH" sudo cp -r "$WEB_DIR" "$BACKUP_PATH"
  info "Rollback automatique disponible si une étape échoue"
else
  skip "Aucun site existant à sauvegarder"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 4 — Base de données
# ══════════════════════════════════════════════════════════════
step 4 "Base de données"

# Nom sécurisé pour DB/user : minuscules, tirets → underscores
# "hack-or-defend" → "hack_or_defend"
DB_SAFE=$(_db_safe "$nameproject")

case $PROJECT_TYPE in

  laravel|php)
    if _has mysql; then
      info "Nom DB/user : ${CYAN}${DB_SAFE}${RESET}"
      read -rsp "  Mot de passe MySQL pour '${DB_SAFE}' : " dbpass; echo ""

      # Exécution en plusieurs appels distincts pour isoler les erreurs
      info "Création de la base de données…"
      if sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_SAFE}\`;" 2>/tmp/_db_err; then
        success "Base '${DB_SAFE}' prête"
      else
        cat /tmp/_db_err
        error "Impossible de créer la base MySQL '${DB_SAFE}'"
      fi

      info "Création de l'utilisateur…"
      # CREATE USER IF NOT EXISTS disponible depuis MySQL 5.7.6
      # On tente CREATE, si ça échoue (user existe) on fait juste ALTER PASSWORD
      if sudo mysql -e "CREATE USER IF NOT EXISTS '${DB_SAFE}'@'localhost' IDENTIFIED BY '${dbpass}';" 2>/tmp/_db_err; then
        success "Utilisateur '${DB_SAFE}' créé"
      elif sudo mysql -e "ALTER USER '${DB_SAFE}'@'localhost' IDENTIFIED BY '${dbpass}';" 2>/tmp/_db_err; then
        success "Utilisateur '${DB_SAFE}' existant — mot de passe mis à jour"
      else
        cat /tmp/_db_err
        error "Impossible de créer/modifier l'utilisateur MySQL '${DB_SAFE}'"
      fi

      info "Attribution des droits…"
      if sudo mysql -e "GRANT ALL PRIVILEGES ON \`${DB_SAFE}\`.* TO '${DB_SAFE}'@'localhost'; FLUSH PRIVILEGES;" 2>/tmp/_db_err; then
        success "Droits accordés"
      else
        cat /tmp/_db_err
        error "Impossible d'accorder les privilèges MySQL"
      fi

      echo ""
      info "Connexion : mysql -u ${DB_SAFE} -p ${DB_SAFE}"
    else
      skip "MySQL non installé — configurez la BDD manuellement"
    fi
    ;;

  symfony|node|next)
    if _has psql; then
      info "Nom DB/user : ${CYAN}${DB_SAFE}${RESET}"
      read -rsp "  Mot de passe PostgreSQL pour '${DB_SAFE}' : " dbpass; echo ""

      # Créer ou mettre à jour l'utilisateur
      info "Création de l'utilisateur…"
      if sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL 2>/tmp/_db_err
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${DB_SAFE}') THEN
    CREATE USER "${DB_SAFE}" WITH PASSWORD '${dbpass}';
  ELSE
    ALTER USER "${DB_SAFE}" WITH PASSWORD '${dbpass}';
  END IF;
END
\$\$;
SQL
      then
        success "Utilisateur '${DB_SAFE}' prêt"
      else
        cat /tmp/_db_err
        error "Impossible de créer l'utilisateur PostgreSQL '${DB_SAFE}'"
      fi

      # CREATE DATABASE doit être hors transaction → appel séparé
      info "Création de la base de données…"
      if sudo -u postgres psql -c "CREATE DATABASE \"${DB_SAFE}\" OWNER \"${DB_SAFE}\";" 2>/tmp/_db_err; then
        success "Base '${DB_SAFE}' créée"
      elif grep -q "already exists" /tmp/_db_err 2>/dev/null; then
        success "Base '${DB_SAFE}' déjà existante — rien à faire"
      else
        cat /tmp/_db_err
        error "Impossible de créer la base PostgreSQL '${DB_SAFE}'"
      fi

      echo ""
      info "Connexion : psql -U ${DB_SAFE} -d ${DB_SAFE} -h localhost"
    else
      skip "PostgreSQL non installé — configurez la BDD manuellement"
    fi
    ;;

  *) skip "Aucune BDD requise pour le type '$PROJECT_TYPE'" ;;
esac

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 5 — Clonage
# ══════════════════════════════════════════════════════════════
step 5 "Clonage du dépôt"

[ -d "$WEB_DIR" ] && sudo rm -rf "$WEB_DIR"
sudo mkdir -p "$WEB_DIR"
sudo chown -R "$USER:$USER" "$WEB_DIR"
cd "$WEB_DIR"

spinner "git clone $REPO_URL" git clone "$REPO_URL" . || {
  warning "Clonage public échoué — dépôt privé ?"
  read -rsp "  Personal Access Token GitHub : " GH_PAT; echo ""
  spinner "git clone (authentifié)" git clone \
    "${REPO_URL/https:\/\//https:\/\/$GH_PAT@}" .
}

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 6 — Dockerfile
# ══════════════════════════════════════════════════════════════
step 6 "Dockerfile"

if [ -f "Dockerfile" ]; then
  success "Dockerfile trouvé dans le dépôt — utilisation directe"
else
  _generate_dockerfile "$PROJECT_TYPE"
fi

if [ ! -f ".dockerignore" ]; then
  cat > .dockerignore <<'EOF'
.git
node_modules
.env
*.log
dist
build
.DS_Store
EOF
  info ".dockerignore créé"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 7 — Build Docker
# ══════════════════════════════════════════════════════════════
step 7 "Build de l'image Docker"

spinner "docker build -t $DOCKER_NAME:latest" \
  sudo docker build -t "$DOCKER_NAME:latest" "$WEB_DIR"

START_SCRIPT="/home/$USER/start-$nameproject.sh"

# --env-file optionnel : si .env absent, on démarre sans
if [ -f "${WEB_DIR}/.env" ]; then
  ENV_FLAG="--env-file ${WEB_DIR}/.env"
else
  ENV_FLAG=""
  warning ".env absent — le container démarrera sans variables d'environnement"
fi

cat > "$START_SCRIPT" <<SH
#!/bin/bash
sudo docker stop  $DOCKER_NAME 2>/dev/null || true
sudo docker rm    $DOCKER_NAME 2>/dev/null || true
sudo docker run \\
  --name $DOCKER_NAME \\
  --restart unless-stopped \\
  -p ${APP_PORT}:${CONTAINER_PORT} \\
  ${ENV_FLAG} \\
  $DOCKER_NAME:latest
SH
chmod +x "$START_SCRIPT"
success "Script de démarrage créé : $START_SCRIPT"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 8 — Nginx
# ══════════════════════════════════════════════════════════════
step 8 "Configuration Nginx (reverse proxy)"

NGINX_CONF="/etc/nginx/sites-available/$fulldomain.conf"

sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $fulldomain www.$fulldomain;

    access_log /var/log/nginx/$fulldomain.access.log;
    error_log  /var/log/nginx/$fulldomain.error.log;

    add_header X-Frame-Options         "SAMEORIGIN"   always;
    add_header X-XSS-Protection        "1; mode=block" always;
    add_header X-Content-Type-Options   "nosniff"      always;
    add_header Referrer-Policy          "strict-origin-when-cross-origin" always;

    location / {
        proxy_pass         http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection 'upgrade';
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 90s;
    }

    location ~ /\.(?!well-known) { deny all; }
}
EOF

success "Config Nginx générée (proxy → 127.0.0.1:$APP_PORT)"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 9 — UFW
# ══════════════════════════════════════════════════════════════
step 9 "Pare-feu (UFW)"

if _has ufw && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
  sudo ufw allow 80/tcp  comment "HTTP"  &>/dev/null
  sudo ufw allow 443/tcp comment "HTTPS" &>/dev/null
  sudo ufw allow OpenSSH                  &>/dev/null
  sudo ufw reload &>/dev/null
  success "Ports 80, 443 et SSH autorisés"
else
  skip "UFW inactif ou non installé"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 10 — Activation Nginx
# ══════════════════════════════════════════════════════════════
step 10 "Activation et test Nginx"

sudo ln -sf "$NGINX_CONF" "/etc/nginx/sites-enabled/$fulldomain.conf"

if sudo nginx -t 2>/dev/null; then
  sudo systemctl reload nginx
  success "Nginx rechargé sans erreur"
else
  sudo nginx -t
  error "Configuration Nginx invalide"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 11 — PM2
# ══════════════════════════════════════════════════════════════
step 11 "PM2 — surveillance du container"

ECO="/home/$USER/ecosystem.$nameproject.config.cjs"
cat > "$ECO" <<JS
module.exports = {
  apps: [{
    name: "$nameproject",
    script: "$START_SCRIPT",
    interpreter: "bash",
    watch: false,
    autorestart: true,
    restart_delay: 3000,
    max_restarts: 10,
    log_date_format: "YYYY-MM-DD HH:mm:ss",
    env: { NODE_ENV: "production" }
  }]
};
JS

pm2 delete "$nameproject" 2>/dev/null || true
pm2 start "$ECO"
pm2 save
pm2 startup 2>/dev/null | grep -E "^sudo" | bash 2>/dev/null || true

success "PM2 démarré — 'pm2 monit' pour le dashboard"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 12 — SSL
# ══════════════════════════════════════════════════════════════
step 12 "Certificat SSL (Let's Encrypt)"

if sudo certbot --nginx \
    -d "$fulldomain" -d "www.$fulldomain" \
    --non-interactive --agree-tos \
    --email "admin@$fulldomain" 2>/dev/null; then
  success "SSL installé (apex + www)"
else
  warning "Échec SSL — le domaine pointe-t-il vers ce serveur ?"
  info    "Réessayez : sudo certbot --nginx -d $fulldomain -d www.$fulldomain"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 13 — Health check
# ══════════════════════════════════════════════════════════════
step 13 "Health check & permissions"

sudo chown -R "$USER:$USER" "$WEB_DIR"
success "Permissions configurées"

sleep 3
HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "https://$fulldomain" 2>/dev/null \
  || curl -sk -o /dev/null -w "%{http_code}" "http://$fulldomain" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" =~ ^(200|301|302)$ ]]; then
  success "Health check OK — HTTP $HTTP_CODE"
else
  warning "Health check : HTTP $HTTP_CODE — vérifiez avec : curl http://$fulldomain"
fi

DEPLOY_SUCCESS=true

if [ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ]; then
  read -rp "  Supprimer le backup ($BACKUP_PATH) ? [o/N] : " del_bkp
  [[ "${del_bkp,,}" == "o" ]] && sudo rm -rf "$BACKUP_PATH" && info "Backup supprimé"
fi

# ══════════════════════════════════════════════════════════════
#  RÉSUMÉ FINAL
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║         ✅  DÉPLOIEMENT RÉUSSI  🎉           ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  🌐 URL           : ${CYAN}https://$fulldomain${RESET}"
echo -e "  📦 Type          : ${BOLD}$PROJECT_TYPE${RESET}"
echo -e "  🐳 Container     : ${DOCKER_NAME} (port $APP_PORT → $CONTAINER_PORT)"
echo -e "  🔁 Health check  : HTTP ${BOLD}$HTTP_CODE${RESET}"
echo -e "  ⏱  Durée totale  : ${BOLD}$(_elapsed_total)${RESET}"
echo ""
echo -e "  ${BOLD}Commandes utiles :${RESET}"
echo -e "  ${DIM}pm2 monit${RESET}                → Dashboard temps réel"
echo -e "  ${DIM}pm2 logs $nameproject${RESET}    → Logs en direct"
echo -e "  ${DIM}pm2 restart $nameproject${RESET} → Redémarrer"
echo -e "  ${DIM}docker logs $DOCKER_NAME${RESET} → Logs du container"
echo ""
echo -e "  ${YELLOW}📋 Conseils :${RESET}"
echo    "  • Pour déployer une nouvelle version :"
echo    "    cd $WEB_DIR && git pull && docker build -t $DOCKER_NAME:latest . && pm2 restart $nameproject"
echo    "  • Renouvellement SSL : sudo certbot renew --dry-run"
[ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ] 2>/dev/null && \
  echo  "  • Backup disponible : $BACKUP_PATH"
echo ""

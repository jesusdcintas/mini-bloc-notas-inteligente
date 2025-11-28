#!/usr/bin/env bash
set -euo pipefail

# Script seguro para:
# 1) Guardar archivos no trackeados en una rama backup
# 2) Commit de cambios
# 3) Traer develop (o main) desde origin y merge en jdcintas
# 4) Manejar "untracked working tree files would be overwritten by merge"
# 5) Push de jdcintas al remoto
#
# Úsalo sólo desde la raíz del repo.

branch="jdcintas"
ts=$(date +%Y%m%d-%H%M%S)
untracked_list="/tmp/jdcintas-untracked-list-$ts.txt"
untracked_backup="/tmp/jdcintas-untracked-backup-$ts"
backup_branch="save-untracked-${branch}-$ts"

echo "1) Verificando rama actual..."
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "$branch" ]; then
  echo "Cambiando a la rama '$branch'..."
  git checkout "$branch"
fi

echo "Guardando lista de archivos no trackeados en: $untracked_list"
git ls-files --others --exclude-standard > "$untracked_list"
echo "Untracked count: $(wc -l < "$untracked_list")"

echo
echo ">>> Recomendación: si hay archivos grandes que NO quieres commitear, edita .gitignore ahora."
read -r -p "Pulsa Enter para continuar (o Ctrl+C para abortar y editar .gitignore)..."

echo
echo "2) Creando rama de backup '$backup_branch' y commiteando TODO (seguible y reversible)..."
git checkout -b "$backup_branch"

# Añadir todo (tracked + untracked) al backup
git add -A

if git diff --cached --quiet; then
  echo "No hay cambios para commitear en la rama backup."
else
  git commit -m "WIP: backup de archivos locales y no trackeados ($backup_branch)"
  echo "Backup commit creado."
fi

echo
echo "3) Volviendo a '$branch' e incorporando el backup (merge seguro)..."
git checkout "$branch"

# Si backup tiene commits, mergealo
if git rev-parse --verify --quiet "$backup_branch" >/dev/null; then
  git merge --no-ff "$backup_branch" -m "Merge: incorporar backup ($backup_branch)" || true
fi

echo
echo "4) Traer referencias remotas y localizar 'develop' (fallback a 'main')..."
git fetch origin --prune

if git show-ref --verify --quiet refs/remotes/origin/develop; then
  upstream_ref="origin/develop"
elif git show-ref --verify --quiet refs/remotes/origin/main; then
  upstream_ref="origin/main"
else
  echo "Error: no se encuentra ni 'origin/develop' ni 'origin/main'. Ajusta el script o crea la rama develop remota." >&2
  exit 1
fi
echo "Usaré: $upstream_ref"

echo
echo "5) Intentando merge de $upstream_ref en $branch..."
# Intentamos merge; capturamos salida en caso de error
if git merge --no-ff "$upstream_ref" -m "Merge $upstream_ref into $branch"; then
  echo "Merge completado correctamente."
else
  echo "Merge falló: comprobando si se trata de archivos no trackeados que bloquearon la operación..."
  # Si hay untracked list, moverlos a backup temporal
  if [ -s "$untracked_list" ]; then
    echo "Moviendo archivos no trackeados a: $untracked_backup"
    mkdir -p "$untracked_backup"
    while IFS= read -r f; do
      # Evitar mover líneas vacías
      if [ -z "$f" ]; then
        continue
      fi
      mkdir -p "$untracked_backup/$(dirname "$f")"
      # mv puede fallar si el archivo ya fue eliminado; ignoramos errores individuales
      mv "$f" "$untracked_backup/$f" 2>/dev/null || true
    done < "$untracked_list"
    echo "Archivos movidos. Reintentando merge..."
    # Reintentar merge
    if git merge --no-ff "$upstream_ref" -m "Merge $upstream_ref into $branch"; then
      echo "Merge completado correctamente después de mover archivos no trackeados."
      echo "Los archivos movidos están en: $untracked_backup"
      echo "Revísalos y restaura manualmente los que quieras (ver instrucciones abajo)."
    else
      echo "Merge aún falla. Abortando merge y restaurando estado."
      git merge --abort || true
      echo "Te recomiendo revisar manualmente la causa. Los no trackeados están en: $untracked_backup"
      exit 1
    fi
  else
    echo "No se detectó lista de archivos no trackeados para mover. Abortando para evitar pérdida de datos."
    git merge --abort || true
    exit 1
  fi
fi

echo
echo "6) (Opcional) Restaurar archivos no trackeados movidos y añadirlos si corresponde."
if [ -d "$untracked_backup" ]; then
  echo "Si quieres restaurar archivos no trackeados movidos, revisa primero:"
  echo "  ls -R $untracked_backup"
  echo "Para restaurar TODOS los archivos (mantén la estructura):"
  echo "  cd $(pwd) && rsync -a \"$untracked_backup/\" ./"
  echo "Luego revisa y añade/commit los que desees:"
  echo "  git add -A && git commit -m \"Añadir archivos restaurados tras merge\""
fi

echo
echo "7) Comprobaciones finales antes de push:"
echo "Estado git:"
git status --short
echo
echo "Log (últimos 20 commits):"
git log --oneline --graph --decorate -n 20

read -r -p "Si todo está bien, pulsa Enter para hacer push de '$branch' a origin (o Ctrl+C para abortar)..."

echo
echo "8) Push al remoto..."
git push origin "$branch"

echo
echo "¡Hecho! Resumen:"
echo " - Backup creado: $backup_branch"
if [ -d "$untracked_backup" ]; then
  echo " - Backup de untracked movidos: $untracked_backup"
fi
echo " - Rama actual: $(git rev-parse --abbrev-ref HEAD)"
echo "Comprueba con 'git status' y 'git log --oneline --graph'."

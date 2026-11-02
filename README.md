# dotfiles

Configuration bash, git et Starship pour Ubuntu (testée sur 26.04, bash 5.3).
Le dépôt est lié dans `$HOME` par des liens symboliques : éditer un fichier
ici, c'est éditer la config en place.

## Installation

```bash
git clone https://github.com/adrien-chinour/dotfiles ~/code/dotfiles
~/code/dotfiles/bootstrap/install-packages.sh   # paquets : apt, snap, nvm/node, rustup, go install
~/code/dotfiles/install.sh                      # liens symboliques vers $HOME
exec bash -l
```

`install.sh` est idempotent et ne supprime jamais rien : un fichier réel qui
existe déjà à l'emplacement d'un lien est déplacé dans
`~/.dotfiles-backup/<horodatage>/` avant d'être remplacé. `--dry-run` affiche
ce qui serait fait.

| Source dans le dépôt     | Cible                        |
|--------------------------|------------------------------|
| `bash/bashrc`            | `~/.bashrc`                  |
| `bash/profile`           | `~/.profile`                 |
| `bash/inputrc`           | `~/.inputrc`                 |
| `git/gitconfig`          | `~/.gitconfig`               |
| `git/ignore`             | `~/.config/git/ignore`       |
| `git/delta.gitconfig`    | `~/.config/git/delta` (si `delta` est installé) |
| `starship/starship.toml` | `~/.config/starship.toml`    |
| `gh/config.yml`          | `~/.config/gh/config.yml`    |
| `htop/htoprc`            | `~/.config/htop/htoprc`      |

## Organisation

```
bash/
  bashrc            source rc.d/00 et 10 (PATH) même en non-interactif, puis rc.d/[2-9]* et ~/.bashrc.local
  profile           POSIX sh, shells de login : source rc.d/00 et 10 puis ~/.bashrc
  inputrc           readline : complétion insensible à la casse, flèches = recherche historique
  rc.d/
    00-env.sh       POSIX : path_prepend/path_append, XDG, EDITOR=nano, ~/.local/bin, bin/ du dépôt
    10-tools.sh     POSIX : go, cargo, deno, bun, pnpm, nvm (chargement paresseux), flutter
    20-shell.sh     historique (100 000 lignes, horodaté, partagé entre terminaux), shopt, less, couleurs
    30-aliases.sh   eza/ls, rm → corbeille, docker compose, git…
    40-functions.sh own, setclip/getclip, gitignore, git-prune-gone, cup, mkcd
    50-completion.sh bash-completion + cache des complétions générées (pnpm, deno, composer, symfony)
    90-prompt.sh    starship, repli sur le PS1 Ubuntu
git/                gitconfig, ignore global, config delta
starship/           starship.toml
gh/, htop/          configs copiées telles quelles
bin/                scripts texte ajoutés au PATH (jamais de binaire dans git)
bootstrap/          install-packages.sh + listes apt.txt, snap.txt, go.txt, npm-global.txt, github-releases.txt
```

Règle : `profile`, `00-env.sh` et `10-tools.sh` restent POSIX sh (ils sont lus
par les shells de login, dont `sh`). Les autres fichiers sont du bash.

## Personnalisation locale

- `~/.bashrc.local` : alias et variables propres à la machine, sourcé en dernier.
  Créé vide par `install.sh`, jamais versionné.
- `~/.gitconfig.local` : identité ou options git propres à la machine (inclus par `gitconfig`).

## Outils installés par `bootstrap/`

`install-packages.sh [--only apt,snap,node,rust,go,github] [--dry-run]`

- **apt** : `apt.txt`. Les paquets dont le dépôt n'est pas configuré sont
  ignorés avec un avertissement. Dépôts tiers à ajouter à la main avant :
  [Docker](https://docs.docker.com/engine/install/ubuntu/),
  [HashiCorp](https://developer.hashicorp.com/terraform/install),
  [Google Cloud CLI](https://cloud.google.com/sdk/docs/install),
  [Symfony CLI](https://symfony.com/download).
- **snap** : `snap.txt` (`code --classic`, firefox, thunderbird, spotify).
- **node** : nvm (version épinglée dans le script), Node 24 par défaut, puis `npm-global.txt`.
- **rust** : rustup (`--no-modify-path`, le PATH est géré par `10-tools.sh`).
- **go** : `go install` de chaque ligne de `go.txt` (ctop, hey, goimports).
  Go lui-même s'installe depuis l'archive officielle dans `/usr/local/go`.
- **github** : `github-releases.txt`, binaires téléchargés avec `gh release download`
  dans `~/.local/bin` (ctop, dont le go.mod empêche `go install`).

## Prompt (Starship)

`starship.toml` reproduit l'ancien thème powerline de liquidprompt :
utilisateur toujours affiché, hôte seulement en ssh, chemin tronqué, branche et
état git, jobs en arrière-plan, batterie sous 75 %, code de retour en erreur.
Pas d'équivalent pour la charge CPU et la température. Les séparateurs
demandent une police powerline (`fonts-powerline` est dans `apt.txt`).
`starship explain` détaille le prompt courant.

## Alias et fonctions

| Commande | Effet |
|---|---|
| `ll`, `la`, `lt` | `eza` long, tout, arbre (repli sur `ls`) |
| `rm` | `gio trash` (corbeille) ; `command rm` pour le vrai rm |
| `dcu`, `dcd`, `dcl`, `doco` | `docker compose up -d` / `down` / `logs -f` / `compose` |
| `dps`, `dkc`, `dki`, `dkv`, `dkn`, `dks` | raccourcis `docker …` |
| `gs`, `gl` | `git status`, log graphique |
| `reload` | recharge `~/.bashrc` |
| `myip`, `port`, `dev`, `bat` | IP publique, ports en écoute, `cd ~/code`, `batcat` |
| `own [chemin]` | `chown -R` vers l'utilisateur courant |
| `setclip`, `getclip` (`pbcopy`, `pbpaste`) | presse-papiers (wl-clipboard ou xclip) |
| `gitignore node python` | génère un `.gitignore` |
| `git-prune-gone` | supprime les branches locales dont la distante a disparu |
| `cup projet [args]` | `docker compose` sur `~/code/projet` (ex : `cup blog up -d`), complète les noms de projets |
| `mkcd dir` | `mkdir -p` puis `cd` |
| `completion-refresh` | régénère le cache des complétions |

## Vérifier et développer

```bash
make lint      # bash -n + shellcheck (sh pour profile/00/10, bash pour le reste)
make dry-run   # install.sh --dry-run
make test      # installation à blanc dans un conteneur ubuntu:26.04
```

## Pièges connus

- `~/.bashrc` étant un lien vers le dépôt, les installeurs qui « ajoutent une
  ligne à ~/.bashrc » (nvm, pnpm, bun, rustup…) modifient `bash/bashrc` :
  ça apparaît dans `git diff`. Le PATH de ces outils est déjà géré par
  `10-tools.sh`, il suffit de rejeter la modification.
- `htop` réécrit `htoprc` à travers le lien quand on change un réglage dans
  l'interface : commiter ou rejeter selon le cas.
- `rm` envoie à la corbeille GNOME ; sur un serveur sans `gio`, utiliser `command rm`.

## Licence

MIT.

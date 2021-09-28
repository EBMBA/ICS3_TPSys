# TP 3 - Gestion des paquets 

## Exercice 1. Commandes de base

1. **Commencez par mettre à jour votre système avec les commandes vues dans le cours.**
```
sudo apt-get update && sudo apt-get upgrade -y
```

2. **Créez un alias “maj” de la ou des commande(s) de la question précédente. Où faut-il enregistrer cet alias pour qu’il ne soit pas perdu au prochain redémarrage ?**

```
alias maj="sudo apt-get update && sudo apt-get upgrade -y"
Il faut l'ajouter dans .bashrc avec : 
echo alias maj='"sudo apt-get update && sudo apt-get upgrade -y"' >> ~/.bashrc && source ~/.bashrc
```

3. **Utilisez le fichier /var/log/dpkg.log pour obtenir les 5 derniers paquets installés sur votre machine.**
```
serveur@uservermetral:~/scripts/ICS3_TPSys/TP3$ tail -n 5 /var/log/dpkg.log


2021-09-27 06:51:41 status half-configured mime-support:all 3.64ubuntu1
2021-09-27 06:51:41 status installed mime-support:all 3.64ubuntu1
2021-09-27 06:51:41 trigproc initramfs-tools:all 0.136ubuntu6.6 <none>
2021-09-27 06:51:41 status half-configured initramfs-tools:all 0.136ubuntu6.6
2021-09-27 06:52:13 status installed initramfs-tools:all 0.136ubuntu6.6
```

4. **Listez les derniers paquets qui ont été installés explicitement avec la commande apt install**
```
apt list --installed 
```

5. **Utilisez les commandes dpkg et apt pour compter de deux manières différentes le nombre de total de paquets installés sur la machine (ne pas hésiter à consulter le manuel !). Comment explique-t-on la (petite) différence de comptage ? Pourquoi ne peut-on pas utiliser directement le fichier dpkg.log ?**
```
 1. apt list --installed | wc -l
    Resultat : 1228
 2. sudo dpkg --list | grep "^ii" | wc -l
    Resultat : 1232

Le fichier dpkg.log ne contient pas tous les paquets mais seulement les dernières manipulations effectué. 
```

6. **Combien de paquets sont disponibles en téléchargement sur les dépôts Ubuntu ?**
```

```

7.** A quoi servent les paquets glances, tldr et hollywood ? Installez-les et testez-les.**
```
apt show glances tldr hollywood
Glances : Permet de controller les performances de son poste
tldr : Sert à simplifier les manuels des commandes
hollywood : Sert à spliter la console en plusieurs panneaux pour faire comme les geek "mélodramatique" d'hollywood

sudo apt install glances tldr hollywood -y
```

8. **Quels paquets proposent de jouer au sudoku ?**

```
Les paquets qui proposent de jouer au sudoku sont :
- sudoku
- ksudoku
- gnome-sudoku
- sudoku-solver
```

## Exercice 2.

**A partir de quel paquet est installée la commande ls ? Comment obtenir cette information en une seule commande, pour n’importe quel programme ? Utilisez la réponse à cette question pour écrire un script appelé origine-commande (sans l’extension .sh) prenant en argument le nom d’une commande, et indiquant quel paquet l’a installée.**

Commande : <br>
```bash
which -a ls | tail -1 | xargs dpkg -S
```
Script : <br>
```bash
#!/bin/bash
which -a $1 | tail -1 | xargs dpkg -S
```
Ensuite faire : <br>
`echo alias origine-commande='"bash ~/scripts/ICS3_TPSys/TP3/origine-commande.sh"' >> ~/.bashrc && source ~/.bashrc`
<br>

## Exercice 3.
**Ecrire une commande qui aﬀiche “INSTALLÉ” ou “NON INSTALLÉ” selon le nom et le statut du package spécifié dans cette commande.**

Commande : <br>
```bash
dpkg -l "coreutils" | grep "^ii" > /dev/null && echo "installé" || echo "non installé"
```
Script : <br>
```bash
#!/bin/bash
#!/bin/bash
while (("$#")) 
do
    (dpkg -l "$1" | grep "^ii") 1>/dev/null 2>&1 && echo "$1 installé" || echo "$1 non installé"
    shift
done
```
***Exemple :  isinstall coreutil coreutils***<br>
***coreutil non installé***<br>
***coreutils installé***<br>

Ensuite faire : <br>
`echo alias isinstall='"bash ~/scripts/ICS3_TPSys/TP3/isinstall.sh"' >> ~/.bashrc && source ~/.bashrc`
<br>

## Exercice 4.
**Lister les programmes livrés avec coreutils. En particulier, on remarque que l’un deux se nomme [. De
quoi s’agit-il?**

```bash
 apt show coreutils
 ```
 <br>
 [ est le meme que le programme "test".

## Exercice 5. aptitude
**Installez les paquets emacs et lynx à l’aide de la version graphique d’aptitude (et prenez deux minutes
pour vous renseigner et tester ces paquets).**

## Exercice 6. Installation d’un paquet par PPA
**Certains logiciels ne figurent pas dans les dépôts oﬀiciels. C’est le cas par exemple de la version ”oﬀicielle”
de Java depuis qu’elle est développée par Oracle. Dans ces cas, on peut parfois se tourner vers un ”dépôt
personnel” ou PPA.**
1. Installer la version Oracle de Java (avec l’ajout des PPA)
```bash
sudo add-apt-repository ppa:linuxuprising/java
sudo apt update
sudo apt install oracle-java17-installer
```
2. Vérifiez qu’un nouveau fichier a été créé dans /etc/apt/sources.list.d. Que contient-il?

```bash
ls /etc/apt/sources.list.d/
linuxuprising-ubuntu-java-bionic.list
```
Il s'agit du nouveau depot que nous avons ajoute 

## Exercice 7. Installation d’un logiciel à partir du code source
**Lorsqu’un logiciel n’est disponible ni dans les dépôts oﬀiciels, ni dans un PPA, ou encore parce qu’on
souhaite n’installer qu’une partie de ses fonctionnalités, on peut se tourner vers la compilation du code source.
C’est ce que nous allons faire ici, avec le programme cbonsai (https://gitlab.com/jallbrit/cbonsai)**
1. Commencez par cloner le dépôt git suivant :
```bash
git clone https://gitlab.com/jallbrit/cbonsai
```
***Ceci permet de récupérer en local le code source du logiciel cbonsai.***<br>

2. Rendez vous dans le dossier cbonsai. Un fichier README.md est livré avec les sources, et vous explique
comment compiler le programme (vous pouvez installer un lecteur de Markdown pour Bash, comme
mdless pour vous faciliter la lecture de ce type de fichiers).
```bash
sudo apt install ruby
sudo gem install mdless
mdless cbonsai/README.md
```
Un fichier **Makefile** est également présent. Un **Makefile** est un fichier utilisé par l’outil make, et
contient toutes les directives de compilation d’un logiciel. Un **Makefile** définit un certain nombre de
règles permettant de construire des cibles. Les cibles les plus communes étant install (pour la com-
pilation et l’installation du logiciel) et clean (pour sa suppression).
En suivant les consignes du fichier README.md, et en installant les éventuels paquets manquants, com-
pilez ce programme et installez le en local.

```bash 
sudo apt install libncursesw5-dev make gcc pkg-config scdoc
cd cbonsai

# installation en local
make install PREFIX=~/.local

Erreur :
scdoc <cbonsai.scd >cbonsai.1
mkdir -p /home/serveur/.local/bin
mkdir -p /home/serveur/.local/share/man/man1
install -m 0755 cbonsai /home/serveur/.local/bin/cbonsai
[ ! -f cbonsai.1 ] || install -m 0644 cbonsai.1 /home/serveur/.local/share/man/man1/cbonsai.1
```

3. Malheureusement, cette installation “à la main” fait qu’on ne dispose pas des bénéfices de la gestion
de paquets apportés par dpkg ou apt. Heureusement, il est possible de transformer un logiciel installé
“à la main” en un paquet, et de le gérer ensuite avec apt ; c’est ce que permet par exemple l’outil
checkinstall.
4. Recommencez la compilation à l’aide de checkinstall :
sudo checkinstall
Un paquet a été créé (fichier xxx.deb), et le logiciel est à présent installé (tapez cbonsai depuis n’importe
quel dossier pour vous en assurer); on peut vérifier par exemple avec aptitude qu’il provient bien du paquet
qu’on a créé avec checkinstall.
Vous pouvez à présent profiter d’un instant de zenitude avant de passer au dernier exercice.

## Exercice 8. Création de dépôt personnalisé
**Dans cet exercice, vous allez créer vos propres paquets et dépôts, ce qui vous permettra de gérer les
programmes que vous écrivez comme s’ils provenaient de dépôts oﬀiciels.**
### Création d’un paquet Debian avec dpkg-deb
1. Dans le dossier scripts créé lors du TP 2, créez un sous-dossier origine-commande où vous créerez un
sous-dossier DEBIAN, ainsi que l’arborescence usr/local/bin où vous placerez le script écrit à l’exercice
2
```bash
mkdir -p origine-commande/DEBIAN origine-commande/usr/local/bin
cp origine-commande.sh origine-commande/usr/local/bin/
```
2. Dans le dossier DEBIAN, créez un fichier control avec les champs suivants :

```
Package: origine-commande #nom du paquet
Version: 0.1 #numéro de version
Maintainer: Foo Bar #votre nom
Architecture: all #les architectures cibles de notre paquet (i386, amd64...)
Description: Cherche l'origine d'une commande
Section: utils #notre programme est un utilitaire
Priority: optional #ce n'est pas un paquet indispendable
```
3. Revenez dans le dossier parent de origine-commande (normalement, c’est votre $HOME) et tapez la
commande suivante pour construire le paquet :
```bash
dpkg-deb --build origine-commande
```
Félicitations! Vous avez créé votre propre paquet!
### Création du dépôt personnel avec reprepro
1. Dans votre dossier personnel, commencez par créer un dossier repo-cpe. Ce sera la racine de votre
dépôt
```
mkdir repo-cpe
```
2. Ajoutez-y deux sous-dossiers : conf (qui contiendra la configuration du dépôt) et packages (qui contien-
dra nos paquets)
```
mkdir -p repo-cpe/conf repo-cpe/packages
```
3. Dans conf, créez le fichier distributions suivant :
```
Origin: Un nom, une URL, ou tout texte expliquant la provenance du dépôt
Label: Nom du dépôt
// Suite: stable
Codename: focal #!! A MODIFIER selon la distribution cible !!
Architectures: i386 amd64 #(architectures cibles)
Components: universe #(correspond à notre cas)
Description: Une description du dépôt
```
4. Dans le dossier repo-cpe, générez l’arborescence du dépôt avec la commande
```
reprepro -b . export
```
5. Copiez le paquet origine-commande.deb créé précédemment dans le dossier packages du dépôt, puis, à la racine du dépôt, exécutez la commande
```bash 
cp origine-commande.deb repo-cpe/packages/
reprepro -b . includedeb focal packages/origine-commande.deb
```
afin que votre paquet soit inscrit dans le dépôt.
6. Il faut à présent indiquer à apt qu’il existe un nouveau dépôt dans lequel il peut trouver des logiciels.
Pour cela, créez (avec sudo) dans le dossier /etc/apt/sources.list.d le fichier repo-cpe.list
contenant :
```bash
sudo echo deb file:/home/emile/repo-cpe focal multiverse > /etc/apt/sources.list.d/repo-cpe.list
```
(cette ligne reprend la configuration du dépôt, elle est à adapter au besoin)<br>

7. Lancez la commande sudo apt update.
Féliciations! Votre dépôt est désormais pris en compte! ... Enfin, pas tout à fait... Si vous regardez
la sortie d’apt update, il est précidé que le dépôt ne peut être pris en compte car il n’est pas signé.
La signature permet de vérifier qu’un paquet provient bien du bon dépôt. On doit donc signer notre
dépôt.
### Signature du dépôt avec GPG
GPG est la version GNU du protocole PGP (Pretty Good Privacy), qui permet d’échanger des données de manière sécurisée. Ce système repose sur la notion de clés de chiffrement asymétriques (une clé publique et
une clé privée)
1. Commencez par créer une nouvelle paire de clés avec la commande
```
gpg --gen-key
```
***Attention! N’oubliez pas votre passphrase!!!***<br>

2. Ajoutez à la configuration du dépôt (fichier distributions la ligne suivante :<br>
`SignWith: yes`
3. Ajoutez la clé à votre dépôt :
```
reprepro --ask-passphrase -b . export
```
***Attention! Cette méthode n’est pas sécurisée et obsolète; dans un contexte professionnel, on utiliserait
plutot un gpg-agent.***<br>

4. Ajoutez votre clé publique à votre dépôt avec la commande
`gpg --export -a "auteur" > public.key`
```
gpg --export -a "emile" > public.key
```
5. Enfin, ajoutez cette clé à la liste des clés fiables connues de apt :
```
sudo apt-key add public.key
```
<br>
Félicitations! La configuration est (enfin) terminée! Vérifiez que vous pouvez installer votre paquet comme
n’importe quel autre paquet.
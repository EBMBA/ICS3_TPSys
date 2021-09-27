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

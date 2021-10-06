# TP 4 - Utilisateurs, groupes et permissions
***Emile METRAL ICS 3***<br>
***Ecrit avec un clavier en qwerty il se peut qu'il manque des accents***
## Exercice 1. Gestion des utilisateurs et des groupes

1. Utilisez la commande `groupadd` pour créer deux groupes dev et infra
```bash
sudo groupadd dev; sudo groupadd infra

Vérification : 
cat /etc/group| grep -w 'dev\|infra'
```

2. Créez ensuite 4 utilisateurs alice, bob, charlie, dave avec la commande `useradd`, en demandant la création de leur dossier personnel et avec bash pour shell
```bash
sudo useradd bob --create-home --shel /bin/bash; sudo useradd alice --create-home --shel /bin/bash; sudo useradd charlie --create-home --shel /bin/bash; sudo useradd dave --create-home --shel /bin/bash; 

Vérification : 
cat /etc/passwd | grep 'alice\|bob\|charlie\|dave'
```

3. Ajoutez les utilisateurs dans les groupes créés :
- alice, bob, dave dans dev
- bob, charlie, dave dans infra

```bash
sudo usermod -a -G dev,infra bob | sudo usermod -a -G dev,infra dave | sudo usermod -a -G dev alice | sudo usermod -a -G infra charlie 

Vérification : 
cat /etc/group| grep -w 'dev\|infra' 
```

4. Donnez deux moyens d’aﬀicher les membres de `infra`
```bash
cat /etc/group| grep -w 'infra' | cut -d: -f4
OU 
grep "infra" /etc/group | cut -d: -f4
```

5. Faites de `dev` le groupe propriétaire des répertoires `/home/alice` et `/home/bob` et de `infra` le groupe propriétaire de `/home/charlie` et `/home/dave`
```bash
sudo chgrp -R dev /home/alice ; sudo chgrp -R dev /home/bob ; sudo chgrp -R infra /home/charlie ; sudo chgrp -R infra /home/dave ; 

Vérification : 
stat -c "User:%U Group:%G Directory:%N" /home/*
```

6. Remplacez le groupe primaire des utilisateurs :
- dev pour alice et bob
- infra pour charlie et dave

```bash
sudo usermod alice -g dev; sudo usermod bob -g dev; sudo usermod charlie -g infra; sudo usermod dave -g infra
```

7. Créez deux répertoires /home/dev et /home/infra pour le contenu commun aux membres de chaque groupe, et mettez en place les permissions leur permettant d’écrire dans ces dossiers. 
```bash 
sudo mkdir -p /home/dev /home/infra ; sudo chgrp -R dev /home/dev; sudo chgrp -R infra /home/infra ; sudo chmod -R g+w /home/dev ; sudo chmod -R g+w /home/infra

Vérification : 
stat -c "Rights:%A User:%U Group:%G Directory:%N " /home/dev /home/infra
``` 
8. Comment faire pour que, dans ces dossiers, seul le propriétaire d’un fichier ait le droit de renommer ou supprimer ce fichier?
```bash 
sudo chmod +t /home/dev

Vérification : 
stat -c "Rights:%A User:%U Group:%G Directory:%N " /home/dev 
```
9. Pouvez-vous ouvrir une session en tant que alice ? Pourquoi?<br>
`Non parce qu'elle n'a pas de mot de passe elle n'est donc pas activé.`
```bash 
serveur@uservermetral:/home/dev$ su alice
Password: 
su: Authentication failure
```
10. Activez le compte de l’utilisateur alice et vérifiez que vous pouvez désormais vous connecter avec son compte.
```bash
serveur@uservermetral:/home/dev$ sudo passwd alice
New password: 
Retype new password:
passwd: password updated successfully
serveur@uservermetral:/home/dev$ su alice
Password: 
alice@uservermetral:/home/dev$ 
```
11. Comment obtenir l’uid et le gid de alice ?
```bash 
id -u alice
```
12. Quelle commande permet de retrouver l’utilisateur dont l’uid est 1003 ?
```bash 
cat /etc/passwd | cut -d: -f1,3 | grep 1003
```
13. Quel est l’id du groupe dev ?
```bash
cat /etc/group | cut -d: -f1,3 | grep -w 'dev'
```
14. Quel groupe a pour gid 1002? ( *** /!\ *** Rien n’empêche d’avoir un groupe dont le nom serait 1002...)
```bash 
cat /etc/group | cut -d: -f1,3 | grep  ':1002'
```
15. Retirez l’utilisateur charlie du groupe infra. Que se passe-t-il? Expliquez.

```bash
sudo gpasswd -d charlie infra

id charlie ==> 
uid=1003(charlie) gid=1005(charlie) groups=1005(charlie)

Le groupe primaire de charlie a changé pour le groupe Charlie qui a été créé après la supression car un utilisateur ne peut pas être sans groupe. 
```

16. Modifiez le compte de dave de sorte que :
- il expire au 1er juin 2022 `-E MM/DD/YYYY`
- il faut changer de mot de passe avant 90 jours `-M nbr de jour`
- il faut attendre 5 jours pour modifier un mot de passe `-m nbr de jour`
- l’utilisateur est averti 14 jours avant l’expiration de son mot de passe `-W nbr de jour`
- le compte sera bloqué 30 jours après expiration du mot de passe `-I nbr de jour`
```bash 
sudo chage -E 06/22/2022 -m 5 -M 90 -I 30 dave 

Vérification : 
sudo chage -l dave
```

17.  Quel est l’interpréteur de commandes (Shell) de l’utilisateur root ?
```bash 
cut -d: -f1,7 /etc/passwd | grep -w "root"
root:/bin/bash ==> root utilise donc le Shell bash. 
```
18.  Si vous regardez la liste des comptes présents sur la machine, vous verrez qu’il en existe un nommé nobody. A quoi correspond-il?
```
Le compte nobody est utilisé par certains démons pour limiter les dommages qu'ils pourraient faire si ils sont utilisés par un programme malveillant.
```

19.  Par défaut, combien de temps la commande sudo conserve-t-elle votre mot de passe en mémoire? Quelle commande permet de forcer sudo à oublier votre mot de passe?

```bash 
Le mot de passe est mémorisé par défaut pour une durée de 15 minutes.
Pour oublier le mot de passe directement après la commande on peut utiliser le paramètre -k :
sudo -k 
```

## Exercice 2. Gestion des permissions
1. Dans votre $HOME, créez un dossier test, et dans ce dossier un fichier fichier contenant quelques
lignes de texte. Quels sont les droits sur test et fichier ?
```bash 
mkdir ~/test | touch ~/test/fichier | ll ~/test/

-rw-r--r-- 1 emile emile    0 Oct  3 11:40 fichier
-rwxrwxrwx ==> read write execute
```
2. Retirez tous les droits sur ce fichier (même pour vous), puis essayez de le modifier et de l’aﬀicher en
tant que root. Conclusion?
```bash
chmod 000 ~/test/fichier

Modification : 
sudo echo 'modification' > ~/test/fichier
-bash: /home/emile/test/fichier: Permission denied

sudo nano ~/test/fichier
>> ssss

Afficher : 
sudo cat ~/test/fichier
>> ssss

Il est possible de le modifier avec un editeur de texte et de l'afficher.  
```
3. Redonnez vous les droits en écriture et exécution sur fichier puis exécutez la commande echo "echo
Hello" > fichier. On a vu lors des TP précédents que cette commande remplace le contenu d’un
fichier s’il existe déjà. Que peut-on dire au sujet des droits?
```bash 
sudo chmod 300 ~/test/fichier

echo "echo Hello" > fichier

L'utilisateur root a toujours les droits sur tous les fichiers. 
```

4. Essayez d’exécuter le fichier. Est-ce que cela fonctionne? Et avec sudo? Expliquez.
```bash 
Droits :
--wx------ 1 emile emile    5 Oct  3 12:20 fichier

bash ~/test/fichier 
>> bash: /home/emile/test/fichier: Permission denied

sudo bash ~/test/fichier 
>> Hello

Je ne peux pas lire le fichier je ne peux donc pas l'executer.
```
5. Placez-vous dans le répertoire test, et retirez-vous le droit en lecture pour ce répertoire. Listez le
contenu du répertoire, puis exécutez ou aﬀichez le contenu du fichier fichier. Qu’en déduisez-vous?
Rétablissez le droit en lecture sur test.
```bash 
cd ~/test ; ls ; bash fichier 
>> fichier
>> bash: fichier: Permission denied

chmod -R u+r ~/test
cd ~/test ; ls ; bash fichier 
>> fichier
>> Hello

Pour executer un script on a besoin d'avoir les droits de lecture sur celui-ci
```

6. Créez dans test un fichier nouveau ainsi qu’un répertoire sstest. Retirez au fichier nouveau et au
répertoire test le droit en écriture. Tentez de modifier le fichier nouveau. Rétablissez ensuite le droit
en écriture au répertoire test. Tentez de modifier le fichier nouveau, puis de le supprimer. Que pouvez-
vous déduire de toutes ces manipulations?
```bash 
touch ~/test/nouveau; mkdir ~/test/sstest ;  chmod u-w ~/test/nouveau ~/test ; echo "echo Hello" > ~/test/nouveau
>> -bash: /home/emile/test/nouveau: Permission denied


chmod u+w ~/test ; echo "echo Hello" > ~/test/nouveau; rm ~/test/nouveau
>> -bash: /home/emile/test/nouveau: Permission denied
>> rm: remove write-protected regular empty file '/home/emile/test/nouveau'? yes

Pas besoin des d'ecriture pour pouvoir supprimer un fichier. 
```
7. Positionnez vous dans votre répertoire personnel, puis retirez le droit en exécution du répertoire test.
Tentez de créer, supprimer, ou modifier un fichier dans le répertoire test, de vous y déplacer, d’en
lister le contenu, etc...Qu’en déduisez vous quant au sens du droit en exécution pour les répertoires?
```bash 
cd ~; chmod u-x test; touch ~/test/nouveau; 
>> touch: cannot touch '/home/emile/test/nouveau': Permission denied

cd test
>> -bash: cd: test: Permission denied

ls ~/test/
>> ls: cannot access '/home/emile/test/fichier': Permission denied
>> ls: cannot access '/home/emile/test/sstest': Permission denied
>> fichier  sstest

Executer un repertoire signifie pouvoir y rentrer. Sans ce droit on peut toujours lire le contenu mais pas modifier, creer ou supprimer les fichiers ou repertoire qui y sont. 
```
8. Rétablissez le droit en exécution du répertoire test. Positionnez vous dans ce répertoire et retirez lui
à nouveau le droit d’exécution. Essayez de créer, supprimer et modifier un fichier dans le répertoire
test, de vous déplacer dans ssrep, de lister son contenu. Qu’en concluez-vous quant à l’influence des
droits que l’on possède sur le répertoire courant? Peut-on retourner dans le répertoire parent avec ”cd
..”? Pouvez-vous donner une explication?
```bash 
chmod u+x ~/test; cd ~/test; chmod u-x ~/test; touch nouveau
>> touch: cannot touch 'nouveau': Permission denied

cd sstest; ls 
>> -bash: cd: sstest: Permission denied

cd ..; cd test/
>> -bash: cd: test/: Permission denied

Nous ne sommes pas sorti du dossier sur lequel nous n'avons plus de droits mais on ne peut plus le manipuler et si on en sort on ne plus y retourner. 
```
9. Rétablissez le droit en exécution du répertoire test. Attribuez au fichier fichier les droits suﬀisants
pour qu’une autre personne de votre groupe puisse y accéder en lecture, mais pas en écriture.
```bash 
chmod u+x ~/test; chmod g+r ~/test/fichier; 
```
10. Définissez un `umask` très restrictif qui interdit à quiconque à part vous l’accès en lecture ou en écriture,
ainsi que la traversée de vos répertoires. Testez sur un nouveau fichier et un nouveau répertoire.
```bash 
umasp par defaut :
umask -p
>> umask 0022

Fichier : 666 - 022 = 644 ==> rw-r--r--
Repertoire : 777 - 022 = 755 => rwxr-xr-x

Les droits que nous voulous enlever : 
    Fichiers : umask 066
    Dossiers : umask 044

mkdir ~/dossier1; touch ~/fichier1; stat -c "Rights:%A  Directory:%N " ~/dossier1/ ~/fichier1
>> Rights:drwx-wx-wx  Directory:'/home/emile/dossier1/' 
>> Rights:-rw--w--w-  Directory:'/home/emile/fichier1'
```
11. Définissez un `umask` très permissif qui autorise tout le monde à lire vos fichiers et traverser vos réper-
toires, mais n’autorise que vous à écrire. Testez sur un nouveau fichier et un nouveau répertoire.
```bash 
Les droits que nous voulous enlever : 
    Fichiers : umask 033
    Dossiers : umask 022

mkdir ~/dossier2; touch ~/fichier2; stat -c "Rights:%A  Directory:%N " ~/dossier2/ ~/fichier2
>> Rights:drwxr-xr-x  Directory:'/home/emile/dossier2/' 
>> Rights:-rw-r--r--  Directory:'/home/emile/fichier2'
```
12. Définissez un `umask` équilibré qui vous autorise un accès complet et autorise un accès en lecture aux
membres de votre groupe. Testez sur un nouveau fichier et un nouveau répertoire.
```bash 
Les droits que nous voulous enlever : 
    Fichiers : umask 036
    Dossiers : umask 027

mkdir ~/dossier3; touch ~/fichier3; stat -c "Rights:%A  Directory:%N " ~/dossier3/ ~/fichier3
>> Rights:drwxr-x---  Directory:'/home/emile/dossier3/' 
>> Rights:-rw-r-----  Directory:'/home/emile/fichier3'
```
13. Transcrivez les commandes suivantes de la notation classique à la notation octale ou vice-versa (vous
pourrez vous aider de la commande stat pour valider vos réponses) :
- chmod u=rx,g=wx,o=r fic
```bash 
chmod 534 fic
```
- chmod uo+w,g-rx fic en sachant que les droits initiaux de fic sont r--r-x---
```bash 
chmod 602 fic
```
- chmod 653 fic en sachant que les droits initiaux de fic sont 711
```bash 
chmod u-x,g+r,o+w fic
```
- chmod u+x,g=w,o-r fic en sachant que les droits initiaux de fic sont r--r-x---
```bash 
chmod 520 fic
```

14.  Aﬀichez les droits sur le programme passwd. Que remarquez-vous? En aﬀichant les droits du fichier
/etc/passwd, pouvez-vous justifier les permissions sur le programme passwd ?
```bash
which passwd | xargs /usr/bin/stat -c "Rights:%A  Directory:%N "
>> Rights:-rwsr-xr-x  Directory:'/usr/bin/passwd'
Le 's' indique que le programme passwd est execute avec les droits de son proprietaire. 

stat -c "Rights:%A  Directory:%N " /etc/passwd
>> Rights:-rw-r--r--  Directory:'/etc/passwd' 
On voit ici que seul le proprietaire du fichier peut modifier les informations dedans. On peut voir que c'est les memes droits pour le fichier /etc/shadow :' 

stat -c "Rights:%A  Directory:%N " /etc/shadow
>> Rights:-rw-r-----  Directory:'/etc/shadow' 
```
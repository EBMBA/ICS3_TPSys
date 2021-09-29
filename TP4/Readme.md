# TP 4 - Utilisateurs, groupes et permissions
*** Emile METRAL ICS 3 ***

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

Vérification : 

```

7. Créez deux répertoires /home/dev et /home/infra pour le contenu commun aux membres de chaque groupe, et mettez en place les permissions leur permettant d’écrire dans ces dossiers. 

8. Comment faire pour que, dans ces dossiers, seul le propriétaire d’un fichier ait le droit de renommer ou supprimer ce fichier?

9. Pouvez-vous ouvrir une session en tant que alice ? Pourquoi?

10. Activez le compte de l’utilisateur alice et vérifiez que vous pouvez désormais vous connecter avec son compte.

11. Comment obtenir l’uid et le gid de alice ?

12. Quelle commande permet de retrouver l’utilisateur dont l’uid est 1003 ?

13. Quel est l’id du groupe dev ?

14. Quel groupe a pour gid 1002? ( *** /!\ *** Rien n’empêche d’avoir un groupe dont le nom serait 1002...)

15. Retirez l’utilisateur charlie du groupe infra. Que se passe-t-il? Expliquez.

16. Modifiez le compte de dave de sorte que :
— il expire au 1er juin 2021
— il faut changer de mot de passe avant 90 jours
— il faut attendre 5 jours pour modifier un mot de passe
— l’utilisateur est averti 14 jours avant l’expiration de son mot de passe
— le compte sera bloqué 30 jours après expiration du mot de passe

17. Quel est l’interpréteur de commandes (Shell) de l’utilisateur root ?

18. Si vous regardez la liste des comptes présents sur la machine, vous verrez qu’il en existe un nommé nobody. A quoi correspond-il?

19. Par défaut, combien de temps la commande sudo conserve-t-elle votre mot de passe en mémoire? Quelle commande permet de forcer sudo à oublier votre mot de passe?
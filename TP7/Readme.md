## TP 7 - Boot, services et processus / Tâches d’administration

## Exercice 1. Personnalisation de GRUB
GRUB est considérablement paramétrable : résolution, langue, fond d’écran, thème, disposition du clavier....
***GRUB se configure via un fichier de paramètres (/etc/default/grub), mais aussi par des scripts situés dans /etc/grub.d ; ces scripts commencent tous par un numéro et sont traités dans l’ordre. <br>
 Evidemment, seuls les scripts exécutables sont pris en compte.<br>
 Sous Ubuntu Server, GRUB prend aussi en compte les fichiers d’extension .cfg présents dans **/etc/default/grub.d**. En particulier, sur les versions récentes, le fichier de configuration **50-curtin-settings.cfg** donne à la variable GRUB_TERMINAL la valeur console, ce qui désactive tous les paramètres liés aux fonds d’écran, thèmes, certaines résolutions, etc.
 https://doc.ubuntu-fr.org/tutoriel/grub2_parametrage_manuel
 ***



1. Commencez par changer l’extension du fichier /etc/default/grub.d/50-curtin-settings.cfg s’il est présent dans votre environnement (vous pouvez aussi commenter son contenu).

```bash
sudo test -f /etc/default/grub.d/50-curtin-settings.cfg && sudo mv /etc/default/grub.d/50-curtin-settings.cfg /etc/default/grub.d/50-curtin-settings.bak || echo "existe pas"

```

2. Modifiez le fichier /etc/default/grub pour que le menu de GRUB s’aﬀiche pendant 10 secondes; passé ce délai, le premier OS du menu doit être lancé automatiquement.
```bash
sudo sed -i -e 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/g'  /etc/default/grub
sudo sed -i -e 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=10/g'  /etc/default/grub
```
3. Lancez la commande update-grub
```bash
sudo update-grub
```

***Cette commande fait appel au script grub-mkconfig qui construit le fichier de configuration ”final” de GRUB (/boot/grub/grub.cfg) à partir du fichier de paramètres et des scripts.***

4. Redémarrez votre VM pour valider que les changements ont bien été pris en compte

***Pensez à lancer la commande update-grub après chaque modification de la configuration de GRUB!***

5. On va augmenter la résolution de GRUB et de notre VM. Cherchez sur Internet le ou les paramètres à rajouter au fichier grub.
```bash 
sudo sed -i -e "s/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1280x1024,640x480/g" /etc/default/grub && sudo update-grub
```
6. On va à présent ajouter un fond d’écran. Il existe un paquet en proposant quelques uns : grub2-splashimages (après installation, celles-ci sont disponibles dans /usr/share/images/grub).
```bash 
sudo apt install grub2-splashimages 
sudo apt install imagemagick 
convert /usr/share/images/grub/050817-N-3488C-028.tga -resize 1280x1024! -depth 16 ~/"00_image_de_fond.tga"
sudo mv ~/"00_image_de_fond.tga" /boot/grub/.
echo "GRUB_BACKGROUND=\"/boot/grub/00_image_de_fond.tga\"" | sudo tee -a /etc/default/grub && sudo update-grub
```

7. Il est également possible de configurer des thèmes. On en trouve quelques uns dans les dépôts (grub2-themes-*).Installez-en un.
```bash 
sudo apt install grub2-themes-ubuntu-mate
echo "GRUB_THEME=\"/boot/grub/themes/ubuntu-mate/theme.txt\"" | sudo tee -a /etc/default/grub && sudo update-grub
```

8. Ajoutez une entrée permettant d’arrêter la machine, et une autre permettant de la redémarrer.
```bash 
echo "
menuentry 'Arrêt du système' {
	halt
}
menuentry 'Redémarrage du système' {
	reboot
}
" | sudo tee -a /etc/grub.d/40_custom && sudo update-grub
```
9. Configurez GRUB pour que le clavier soit en français ( n’a plus l’air de fonctionner sur Ubuntu ≥ 19.04)
```bash 
echo "
# Clavier en francais 
LANG=fr_FR
GRUB_TERMINAL_INPUT=at_keyboard
" sudo tee -a /etc/grub.d/40_custom && sudo update-grub
``` 
### Exercice 2. Noyau
Dans cet exercice, on va créer et installer un module pour le noyau.
1. Commencez par installer le paquet build-essential, qui contient tous les outils nécessaires (compilateurs, bibliothèques) à la compilation de programmes en C (entre autres).
```bash 
sudo apt install build-essential
```
2. Créez un fichier hello.c contenant le code suivant :
```C
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENCE("GPL");
MODULE_AUTHOR("John Doe");
MODULE_DESCRIPTION("Module hello world");
MODULE_VERSION("Version 1.00");

int init_module(void)
{
    printk(KERN_INFO "[Hello world] - La fonction init_module() est appelée.\n");
    return 0;
}

void cleanup_module(void)
{
    printk(KERN_INFO "[Hello world] - La fonction cleanup_module() est appelée.\n");
}
```
3. Créez également un fichier Makefile :

```Makefile 
obj-m += hello.o

all:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

install:
    cp ./hello.ko /lib/modules/$(shell uname -r)/kernel/drivers/misc
```

```bash 
mkdir ~/kernelProject

echo '#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENCE("GPL");
MODULE_AUTHOR("John Doe");
MODULE_DESCRIPTION("Module hello world");
MODULE_VERSION("Version 1.00");

int init_module(void)
{
    printk(KERN_INFO "[Hello world] - La fonction init_module() est appelée.\n");
    return 0;
}

void cleanup_module(void)
{
    printk(KERN_INFO "[Hello world] - La fonction cleanup_module() est appelée.\n");
}
' > ~/kernelProject/hello.c

echo 'obj-m += hello.o

all:
        make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
        make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

install:
        cp ./hello.ko /lib/modules/$(shell uname -r)/kernel/drivers/misc
' > ~/kernelProject/Makefile

```
4. Compilez le module à l’aide de la commande make, puis installez-le à l’aide de la commande make
install.
```bash 
cd ~/kernelProject && make
make install 
```
***Le module est installé dans le dossier spécifié à la ligne 10.***

```
make -C /lib/modules/4.15.0-159-generic/build M=/home/serveur/kernelProject modules
make[1]: Entering directory '/usr/src/linux-headers-4.15.0-159-generic'
  CC [M]  /home/serveur/kernelProject/hello.o
/home/serveur/kernelProject/hello.c:4:16: error: expected declaration specifiers or ‘...’ before string constant
 MODULE_LICENCE("GPL");
                ^~~~~
scripts/Makefile.build:340: recipe for target '/home/serveur/kernelProject/hello.o' failed
make[2]: *** [/home/serveur/kernelProject/hello.o] Error 1
Makefile:1590: recipe for target '_module_/home/serveur/kernelProject' failed
make[1]: *** [_module_/home/serveur/kernelProject] Error 2
make[1]: Leaving directory '/usr/src/linux-headers-4.15.0-159-generic'
Makefile:4: recipe for target 'all' failed
make: *** [all] Error 2
```

5. Chargez le module; vérifiez dans le journal du noyau que le message “La fonction init_module() est
appelée” a bien été inscrit, synonyme que le module a été chargé; confirmez avec la commande lsmod.

6. Utilisez la commande modinfo pour obtenir des informations sur le module hello.ko ; vous devriez
notamment voir les informations figurant dans le fichier C.

7. Déchargez le module; vérifiez dans le journal du noyau que le message “La fonction cleanup_module()
est appelée” a bien été inscrit, synonyme que le module a été déchargé; confirmez avec la commande
lsmod.

8. Pour que le module soit chargé automatiquement au démarrage du système, il faut l’inscrire dans le
fichier /etc/modules. Essayez, et vérifiez avec la commande lsmod après redémarrage de la machine.

### Exercice 3. Interception de signaux
La commande interne trap permet de redéfinir des gestionnaires pour les signaux reçus par un processus.
Un cas d’utilisation typique est la suppression des fichiers temporaires créés par un script lorsque celui-ci est
interrompu.
1. Commencez par écrire un script qui recopie dans un fichier tmp.txt chaque ligne saisie au clavier par
l’utilisateur

2. Lancez votre script et appuyez sur CTRL+Z. Que se passe-t-il? Comment faire pour que le script pour-
suive son exécution?

3. Toujours pendant l’exécution du script, appuyez sur CTRL+C. Que se passe-t-il?

4. Modifiez votre script pour redéfinir les actions à effectuer quand le script reçoit les signaux SIGTSTP
(= CTRL+Z) et SIGINT (= CTRL+C) : dans le premier cas, il doit aﬀicher “Impossible de me placer en
arrière-plan”, et dans le second cas, il doit aﬀicher “OK, je fais un peu de ménage avant” avant de
supprimer le fichier temporaire et terminer le script.

5. Testez le nouveau comportement de votre script en utilisant d’une part les raccourcis clavier, d’autre
part la commande kill

6. Relancez votre script et faites immédiatement un CTRL+C : vous obtenez un message d’erreur vous
indiquant que le fichier tmp.txt n’existe pas. A l’aide de la commande interne test, corrigez votre
script pour que ce message n’apparaisse plus.
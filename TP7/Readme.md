## TP 7 - Boot, services et processus / Tâches d’administration

## Exercice 1. Personnalisation de GRUB
GRUB est considérablement paramétrable : résolution, langue, fond d’écran, thème, disposition du clavier....
***GRUB se configure via un fichier de paramètres (/etc/default/grub), mais aussi par des scripts situés dans /etc/grub.d ; ces scripts commencent tous par un numéro et sont traités dans l’ordre. <br>
 Evidemment, seuls les scripts exécutables sont pris en compte.<br>
 Sous Ubuntu Server, GRUB prend aussi en compte les fichiers d’extension .cfg présents dans **/etc/default/grub.d**. En particulier, sur les versions récentes, le fichier de configuration **50-curtin-settings.cfg** donne à la variable GRUB_TERMINAL la valeur console, ce qui désactive tous les paramètres liés aux fonds d’écran, thèmes, certaines résolutions, etc.***



1. Commencez par changer l’extension du fichier /etc/default/grub.d/50-curtin-settings.cfg s’il est présent dans votre environnement (vous pouvez aussi commenter son contenu).
2. Modifiez le fichier /etc/default/grub pour que le menu de GRUB s’aﬀiche pendant 10 secondes;
passé ce délai, le premier OS du menu doit être lancé automatiquement.
3. Lancez la commande update-grub
 Cette commande fait appel au script grub-mkconfig qui construit le fichier de configuration
”final” de GRUB (/boot/grub/grub.cfg) à partir du fichier de paramètres et des scripts.
4. Redémarrez votre VM pour valider que les changements ont bien été pris en compte
 Pensez à lancer la commande update-grub après chaque modification de la configuration de
GRUB!
5. On va augmenter la résolution de GRUB et de notre VM. Cherchez sur Internet le ou les paramètres
à rajouter au fichier grub.
6. On va à présent ajouter un fond d’écran. Il existe un paquet en proposant quelques uns : grub2-splashimages
(après installation, celles-ci sont disponibles dans /usr/share/images/grub).
7. Il est également possible de configurer des thèmes. On en trouve quelques uns dans les dépôts (grub2-themes-*).
Installez-en un.
8. Ajoutez une entrée permettant d’arrêter la machine, et une autre permettant de la redémarrer.
9. Configurez GRUB pour que le clavier soit en français ( n’a plus l’air de fonctionner sur Ubuntu ≥
19.04)
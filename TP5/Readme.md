# TP5 - Systèmes de fichiers, partitions et disques
***Emile METRAL ICS 3***<br>
***Ecrit avec un clavier en qwerty il se peut qu'il manque des accents***
<br>
Dans ce cinquième TP, nous allons manipuler divers outils de gestion des disques et partitions, ainsi que le partitionnement
LVM. Nous verrons comment créer des points de montage et monter des partitions.
<br>
## Exercice 1. Disques et partitions

1. Dans l’interface de configuration de votre VM, créez un second disque dur, de 5 Go dynamiquement alloués; puis démarrez la VM

2. Vérifiez que ce nouveau disque dur est bien détecté par le système
```bash
lsblk | grep -w 'disk'
>> sda                         8:0    0   20G  0 disk
>> sdb                         8:16   0    5G  0 disk
```
3. Partitionnez ce disque en utilisant fdisk : créez une première partition de 2 Go de type Linux (n°83), et une seconde partition de 3 Go en NTFS (n°7)
```bash
sudo echo "n
p
1

+2G
t
83
n
p



t
2
7

w
" | sudo fdisk /dev/sdb
```
4. A ce stade, les partitions ont été créées, mais elles n’ont pas été formatées avec leur système de fichiers.
A l’aide de la commande mkfs, formatez vos deux partitions (pensez à consulter le manuel!)
```bash
sudo mkfs.ntfs /dev/sdb2; sudo mkfs.ext4 /dev/sdb1
```

5. Pourquoi la commande df -T, qui aﬀiche le type de système de fichier des partitions, ne fonctionne-t- elle pas sur notre disque?
   
<br>`Les partitions ne sont pas montées.`<br>


6. Faites en sorte que les deux partitions créées soient montées automatiquement au démarrage de la machine, respectivement dans les points de montage /data et /win (vous pourrez vous passer des UUID en raison de l’impossibilité d’effectuer des copier-coller)
```bash 
ls -l /dev/disk/by-uuid/ | cut -d: -f2 | grep "sdb"
sudo mkdir -p /data /win 
echo "
UUID=231602572603EE0A             /win           ext4   defaults        0 0
UUID=325e6f7c-a9b9-4657-b689-b7d6667ba002              /data             ntfs      defaults       0 0
" | sudo tee -a /etc/fstab
sudo mount -a
```
7. Utilisez la commande mount puis redémarrez votre VM pour valider la configuration

## Exercice 2. Partitionnement LVM
***Dans cet exercice, nous allons aborder le partitionnement LVM, beaucoup plus flexible pour manipuler les disques et les partitions.***
1. On va réutiliser le disque de 5 Gio de l’exercice précédent. Commencez par démonter les systèmes de fichiers montés dans /data et /win s’ils sont encore montés, et supprimez les lignes correspondantes du fichier /etc/fstab
```bash
sudo umount /data; sudo umount /win
``` 

2. Supprimez les deux partitions du disque, et créez une patition unique de type LVM
```bash
sudo echo "d
1
d
w
" | sudo fdisk /dev/sdb
```

***La création d’une partition LVM n’est pas indispensable, mais vivement recommandée quand on utilise LVM sur un disque entier. En effet, elle permet d’indiquer à d’autres OS ou logiciels de gestion de disques (qui ne reconnaissent pas forcément le format LVM) qu’il y a des données sur ce disque.
Attention à ne pas supprimer la partition système!***

3. A l’aide de la commande pvcreate, créez un volume physique LVM. Validez qu’il est bien créé, en utilisant la commande pvdisplay.
```bash
sudo pvcreate --force /dev/sdb

Vérification : 
sudo pvdisplay

  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               TlQniZ-5P4E-qh0w-TejB-hftm-004g-u37mIf
```
<br>

***Toutes les commandes concernant les volumes physiques commencent par pv. Celles concernant les groupes de volumes commencent par vg, et celles concernant les volumes logiques par lv.***


4. A l’aide de la commande vgcreate, créez un groupe de volumes, qui pour l’instant ne contiendra que le volume physique créé à l’étape précédente. Vérifiez à l’aide de la commande vgdisplay.
```bash
sudo vgcreate vg00 /dev/sdb; sudo vgdisplay
```
<br>

***Par convention, on nomme généralement les groupes de volumes vgxx (où xx représente l’indice du groupe de volume, en commençant par 00, puis 01...)***

5. Créez un volume logique appelé lvData occupant l’intégralité de l’espace disque disponible.
```bash
sudo lvcreate -n lvData -l 100%FREE vg00 -y; sudo lvdisplay

Pour supprimer : 
sudo lvremove /dev/vg00/lvData -y
```

***On peut renseigner la taille d’un volume logique soit de manière absolue avec l’option -L (par exemple -L 10G pour créer un volume de 10 Gio), soit de manière relative avec l’option -l : -l 60%VG pour utiliser 60% de l’espace total du groupe de volumes, ou encore -l 100%FREE pour utiliser la totalité de l’espace libre.***

6. Dans ce volume logique, créez une partition que vous formaterez en ext4, puis procédez comme dans l’exercice 1 pour qu’elle soit montée automatiquement, au démarrage de la machine, dans /data.
```bash
sudo mkfs -t ext4 /dev/vg00/lvData; 
echo "/dev/vg00/lvData    /data   ext4    defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
```

***A ce stade, l’utilité de LVM peut paraître limitée. Il trouve tout son intérêt quand on veut par exemple agrandir une partition à l’aide d’un nouveau disque.***

7. Eteignez la VM pour ajouter un second disque (peu importe la taille pour cet exercice). Redémarrez la VM, vérifiez que le disque est bien présent. Puis, répétez les questions 2 et 3 sur ce nouveau disque.
```bash
sudo pvcreate --force /dev/sdc

Vérification : 
sudo pvdisplay

  "/dev/sdc" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdc
  VG Name
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               NaHCij-DmVC-5HfI-6BB4-atnR-okEg-oskDlE

```

8. Utilisez la commande vgextend <nom_vg> <nom_pv> pour ajouter le nouveau disque au groupe de volumes
```bash
sudo vgextend vg00 /dev/sdc
```
9. Utilisez la commande lvresize (ou lvextend) pour agrandir le volume logique. Enfin, il ne faut pas oublier de redimensionner le système de fichiers à l’aide de la commande resize2fs.
```bash
sudo lvextend /dev/vg00/lvData /dev/sdc; sudo resize2fs
```
***Il est possible d’aller beaucoup plus loin avec LVM, par exemple en créant des volumes par bandes (l’équivalent du RAID 0) ou du mirroring (RAID 1). Le but de cet exercice n’était que de présenter les fonctionnalités de base.***
# Palm für Azure

Das Repo hier ist eine Sammlung an Skripten, mit denen wir testen ob PALM effizient und sicher in Azure verwendet werden kann.
Zusätzlich zum Aufsetzen von PALM vom lokalen Rechner aus besteht die Möglichkeit sich auf den Azure-VMs per ssh einzuloggen und direkt dort PALM zu starten und Parameteränderungen auszuprobieren. So muss nicht immer eine neue Maschine erstellt werden.

Es ist zu beachten dass die Maschinen Geld kosten, wenn man sie nicht manuell wieder frei gibt.

Die Skripte sind zweigeteilt:

 * lokale Skripte, die auf dem lokalen Rechner aufgerufen werden und Azure-Cli verwenden.
 * VM Skripte, die auf den Azure Machinen ausgeführt werden.

Die _lokalen Skripte_ befinden sich im Ordner `azure_cli_scripts`. Sie bauen die Umgebung in Azure auf:

 * Account
 * Netzwerk
 * Shared Storage
 * Pool
 * Starten von Jobs, u.a. PALM.

Die _VM Skripte_ befinden sich im Ordner `vm_scripts`. Sie laufen direkt in der VM:

 * Update and Upgrade VM
 * Install missing Software
 * Compile and install PALM
 * Start PALM simulations

## Manuelle Anpassungen
Wir sind jetzt im Laufe der Übergabe noch auf ein paar Dinge gestoßen:
PALM sollte im shared directory laufen, das basis directory ist jetzt:
    /mnt/batch/tasks/fsmounts/shared/

Dort sind wir jetzt übergegangen, den "execute_command" nicht im "palmrun" skript, sondern in der palm.config. umzustellen. Das muss derzeit noch manuell geschehen!
Die Anpassungen sollten (im Standard Setup) sich auf "--host 10.0.0.4:1,10.0.0.5:1" beschränken, je nach Setup kann sich das aber auch ändern.

## Start Pool und PALM
Die Skripte hier sind genauso aufgebaut, wie das originale Beispiel von Kai. Es gibt benötigt eine "variables.sh" mit einigen Parametern,
man logt man sich mit

    az login

in Azure im Terminal in Azure ein, und führt die dann Skripte 1 bis 5 aus.

### variables.sh
Ich hab mal eine Rohdatei für variables.sh angelegt, darin könnt ihr die entsprechenden Parameter benennen. Schaut im Zweifel nochmal in [Kai's Repo](https://github.com/kaneuffe/azure-batch-workshop), dort findet ihr in der Readme auch nochmal Hinweise, wie die heißen könnten.


### 01_create_account.sh
Das Skript erstellt eigentlich Keyvault, Storage und den Batchaccount. Storage und Keyvault erstellen sind kein Problem, beim setzen der Policies für den Keyvault gibts aber Probleme mit den Rechten. Im Zweifel nutzt ihr hier den Keyvault, den es in der Ressourcengruppe schon gibt, da ist bereits alles eingestellt.

Desweiteren könnt ihr keinen neuen Batchaccount erstellen (zumindest Dirk nicht), deswegen würd ich auch hier raten, ihr nehmt den BatchAccount, der bereits in der Ressourcengruppe vorhanden ist. Der Login am Ende des Skript sollte damit funktionieren.

Falls es da Probleme gibt, müsst ihr euch mit Willem unterhalten, dass er euch einen eigenen BatchAccount in der Ressourcengruppe einrichtet.

### 02_create_network.sh
Erstellt die ganzen Netzwerk-Sachen. Hat bei mir bisher noch nie Probleme gemacht.


### 03_create_shared_storage.sh
Erstellt einen shared storage, den man theoretisch auf den VMs später mounten kann. Hab ich bisher noch nicht gemacht, Skript läuft aber einwandfrei.


### 04_create_pool.sh
Erstellt zuerst eine ${pool_id}.json Datei, mit dieser wird dann der Pool erstellt. Die bisherigen Einstellungen sind recht simpel, 2 Maschinen mit der kleinen "F2_v2" Größe (2 Kerne, 8GB RAM oder so). Desweiteren wird Ubuntu auf den VMs installiert.

Wichtig sind hier insbesondere:
* Die Start-Task, was also passiert, wenn die Maschienen hochgefahren, bzw neu gestartet werden. Hier wird das Skript "startup_tasks.sh" ausgeführt. Das aktualisiert Ubuntu und installiert PALM dann im Verzeichnis "/palmbase/palm/"
* Die Einstellungen:
    * "maxTasksPerNode": 1,
    * "taskSchedulingPolicy": {
        "nodeFillType": "Pack"
       }
    * Diese definieren das Verhalten von MPI und das Verteilen von mpi-Jobs. Eventuell muss man da etwas rumspielen.

Man kann einen Pool aber auch über den BatchExplorer oder direkt in Azure im BatchAccount unter "Pools" erstellen. Dabei ist dann wichtig, dass man die "enableInterNodeCommunication" auf True setzt, sowie eben maxTasksperNode und nodeFilleType UND die starttask.


### 05_start_palm.sh
Erstellt wieder eine json-Datei (palm_run.json), mit der der eigentliche Job erstellt wird. Das MUSS in dem Fall über die json laufen, da man hier Parameter ansprechen kann, die über den BatchExplorer nicht gehen (v.a. NetzwerkParameter). Für jeden neuen Run müsst in 05_start_palm.sh den Paramter "run_id" anpassen.

Der eigentlich Job lädt derzeit die Datei "palm_tests_palm_installed.sh" herunter und führt sie aus. Derzeit wird einfach nur "example_cbl" simuliert. Auskommentiert sind meine Versuche, das "palmrun" Skript so anzupassen, dass MPI die Tasks auf beide Machinen verteilt, leider war ich bisher nicht erfolgreich/hatte keine Zeit.


### 06_delete_pool.sh
Löscht den Pool wieder, wodurch die Kosten wegfallen.

**Wichtig**: Beide StorageAccounts, die erstellt werden verursachen Kosten, wenn man sie nicht manuel in Azure entfernt.


## Skripte für Azure
Ich hab noch ein paar "legacy" Skripte in dem Repo, die wichtigen sind:
* startup_tasks.sh
* palm_tests_palm_installed.sh

### startup_tasks.sh
Aktualisiert Ubuntu und installiert alle Software-Abhängigkeiten für PALM, dann Palm in den Ordner "/palmbase/palm".
**Wichtig**: Muss als Admin/mit sudo Rechten ausgeführt werden. In der JSON funktioniert das automatisch, in Azure / Batchexplorer muss man dafür ein entsprechendes Häckchen setzen.

### palm_test_palm_installed.sh
Echod n Haufen Parameter und Netzwerksachen am Anfang, versucht dann "example_cbl" zu starten:

    ./bin/palmrun -a "d3#" -X 2 -r example_cbl

Hier könntet ihr dann rumspielen mit verschiedenen Kernanzahlen, etc.

Auskommentiert findet ihr hier auch meinen ersten Versuch, "palmrun" anzupassen, so dass der mpi-Befehl die Jobs auf die verschiedenen Machienen verteilt:

    #sed -i "2142 i # added comment" /palmbase/palm/bin/palmrun
    #sed -i "2143 i \ \ \ \ size=\${#execute_command}" /palmbase/palm/bin/palmrun
    #sed -i "2144 i \ \ \ \ printf \"\n  \"$size\" \n\"" /palmbase/palm/bin/palmrun
    #sed -i "2145 i \ \ \ \ execute_command=\$(echo \${execute_command:0:6} ${command_option}\${execute_command:7:\${size}})" /palmbase/palm/bin/palmrun
    #sed -i "2146 i \ \ \ \ printf \"\n  \"$execute_command\" \n\"" /palmbase/palm/bin/palmrun

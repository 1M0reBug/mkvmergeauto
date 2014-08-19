#Petit script pour pouvoir incruster les sous-titres
#!/bin/bash
################################################################################
# Pour utiliser ce script il suffit de saisir:                                 #
# ./MKVMerge_auto                                                              #
# $1 correspond au numéro de saison                                            #
# $2 correspond au répertoire contenant l'épisode et les sous-titres           #
# $3 est le nom du repertoire contenant les sous-titres                        #
# $4 est le répertoire de sortie des fichiers muxés                            # 
# $5 est le nombre d'épisodes de la saison                                     #
# $6 est l'extension des fichiers vidéo                                        #
################################################################################
echo -e "Mkvmerge - Remux"
repertoire=$2
soustitres=$3
sortie=$4
echo -e "Saison : $1"
echo -e "Repertoire general : $2"
echo -e "Repertoire sous-titres: $3"
echo -e "Repertoire de sortie $4"
echo -e "nombres d'episodes : $5"
echo -e "extensions : $6"
echo -e ""
str=""
for ((i=1;i<=$5;i++))
do
if test "$i" -lt 10
then
str+="American.Dad.S0$1E0$i "
else
str+="American.Dad.S0$1E$i "
fi
done
for i in $str
do
namefile="$i"
media_entrant="$repertoire/$namefile.$6"
media_sortant="$repertoire/$sortie/$namefile.mkv"
en_srt="$repertoire/$soustitres/$namefile.srt"
echo -e "Media sortant: $media_sortant"
echo -e "EN SRT: $en_srt"
mkdir "$OUTPUT_FOLDER"
mkvmerge -v -o "$media_sortant"  "--language" "0:eng" "--forced-track" "0:no" "--language" "1:eng" "--forced-track" "1:no" "-a" "1" "-d" "0" "-S" "-T" "--no-global-tags" "--no-chapters" "(" "$media_entrant" ")" "--forced-track" "0:no" "-s" "0" "-D" "-A" "-T" "--no-global-tags" "--no-chapters" "(" "$en_srt" ")" "--track-order" "0:0,0:1,1:0"
echo -e "" 
done
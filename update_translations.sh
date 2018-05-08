#!/bin/bash
#
# update translation file content
for FILE in i18n/kodimote_*.ts
do
    lupdate -recursive . -ts ${FILE} -no-obsolete
done

# release
lrelease i18n/kodimote_*.ts

cd i18n

QRC=translations.qrc
echo "<RCC>" > $QRC
echo "    <qresource prefix=\"/\">" >> $QRC

for i in `ls *.qm`; do
    echo "        <file>$i</file>" >> $QRC
done

echo "    </qresource>" >> $QRC
echo "</RCC>" >> $QRC

#!/bin/bash
# ============================================================
#  Configura_Konica_Mac — App macOS per a docents i centres educatius
#  Generalitat de Catalunya — ajimen49
# ============================================================

RESOURCES="$(dirname "$0")/../Resources"
INSTALL_DIR="$HOME/PaperCut-Konica"
PPD_NAME="KOC364SX.ppd"
PRINTER_NAME="KONICA-MINOLTA"
SERVER_PORT="9191"
PRINT_USER="impressio"
PRINT_PWD="Impr3ss10"

# ── Funció: diàleg natiu macOS ────────────────────────────
dialog() {
    osascript -e "$1"
}

# ── Pantalla de benvinguda ────────────────────────────────
dialog '
tell application "System Events"
    activate
    set resultado to button returned of (display dialog "Benvingut/da a l'\''instal·lador de la impressora Konica Minolta per a docents i centres educatius de la Generalitat de Catalunya.

Aquest assistent configurarà automàticament la impressora i el client de PaperCut al teu Mac en menys d'\''un minut.

Necessitaràs:
  • La IP del servidor PaperCut del centre (10.241.XXX.XXX)
  • El codi del teu centre (8 dígits)" ¬
        with title "Instal·la Konica Minolta" ¬
        buttons {"Cancel·la", "Continua →"} ¬
        default button "Continua →" ¬
        with icon note)
end tell
return resultado
'
WELCOME_RESULT=$?
if [ $WELCOME_RESULT -ne 0 ]; then exit 0; fi

# ── Demanar IP del servidor ───────────────────────────────
while true; do
    SERVER_IP=$(osascript << 'EOF'
tell application "System Events"
    activate
    set r to text returned of (display dialog "Introdueix la IP del servidor PaperCut del centre:

(per exemple: 10.241.XXX.XX)" ¬
        with title "Instal·lador Konica Minolta — Pas 1 de 2" ¬
        default answer "" ¬
        buttons {"← Enrere", "Següent →"} ¬
        default button "Següent →")
end tell
return r
EOF
)
    # Si l'usuari cancel·la (Enrere), sortir
    if [ $? -ne 0 ]; then exit 0; fi

    # Validar format IP
    if [[ "$SERVER_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        break
    else
        osascript -e 'tell application "System Events" to activate' \
                  -e 'display alert "Format incorrecte d'\''IP." message "Introdueix una IP vàlida (p. ex.: 10.241.XXX.XXX)." as warning'
    fi
done

# ── Demanar codi de centre ────────────────────────────────
while true; do
    CENTRE_CODE=$(osascript << 'EOF'
tell application "System Events"
    activate
    set r to text returned of (display dialog "Introdueix el codi del teu centre educatiu:

(8 dígits, p. ex.: 08XXXXXX o 17XXXXXX)" ¬
        with title "Instal·lador Konica Minolta — Pas 2 de 2" ¬
        default answer "" ¬
        buttons {"← Enrere", "Instal·la!"} ¬
        default button "Instal·la!")
end tell
return r
EOF
)
    if [ $? -ne 0 ]; then exit 0; fi

    if [[ "$CENTRE_CODE" =~ ^[0-9]{8}$ ]]; then
        SERVER_NAME="SS${CENTRE_CODE}"
        break
    else
        osascript -e 'tell application "System Events" to activate' \
                  -e 'display alert "Codi de centre incorrecte." message "El codi ha de tenir exactament 8 dígits numèrics." as warning'
    fi
done

# ── Confirmació abans d'instal·lar ────────────────────────
CONFIRM=$(osascript << EOF
tell application "System Events"
    activate
    set r to button returned of (display dialog "Revisa la configuració:

  Servidor:     ${SERVER_IP}:${SERVER_PORT}
  Nom servidor: ${SERVER_NAME}
  Impressora:   KONICA-MINOLTA

S'instal·larà el driver i es configurarà la cua d'impressió automàticament." ¬
        with title "Instal·lador Konica Minolta — Confirmació" ¬
        buttons {"Cancel·la", "Instal·la ara!"} ¬
        default button "Instal·la ara!" ¬
        with icon caution)
end tell
return r
EOF
)
if [ $? -ne 0 ] || [ "$CONFIRM" = "Cancel·la" ]; then exit 0; fi

# ── Instal·lació (en segon pla, sense terminal visible) ───

# 1. Crear directori d'instal·lació
mkdir -p "$INSTALL_DIR"

# 2. Copiar fitxers
cp -r "$RESOURCES/lib"            "$INSTALL_DIR/"
cp    "$RESOURCES/pc-client-mac.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/pc-client-mac.sh"

# 3. Generar config.properties
cat > "$INSTALL_DIR/config.properties" << CONF
#Bootstrap configuration - Generat per Configura_Konica_Mac.app
server-ip=${SERVER_IP}
server-port=${SERVER_PORT}
server-name=${SERVER_NAME}
CONF

# 4. Instal·lar Java si cal
if ! command -v java &>/dev/null; then
    if ! command -v brew &>/dev/null; then
        # Instal·lar Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > "$INSTALL_DIR/install.log" 2>&1
        [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew install --cask temurin >> "$INSTALL_DIR/install.log" 2>&1
fi

# 5. Instal·lar PPD (necessita sudo → demanem contrasenya amb diàleg natiu)
SUDO_CMD="do shell script \"cp '$RESOURCES/$PPD_NAME' '/Library/Printers/PPDs/Contents/Resources/'\" with administrator privileges"
osascript -e "$SUDO_CMD" 2>/dev/null

# 6. Esborrar impressora anterior si existia
lpstat -p "$PRINTER_NAME" &>/dev/null 2>&1 && \
    osascript -e "do shell script \"lpadmin -x '$PRINTER_NAME'\" with administrator privileges" 2>/dev/null || true

# 7. Afegir impressora SMB
LPADMIN_CMD="lpadmin -p '$PRINTER_NAME' \
  -v 'smb://${PRINT_USER}:${PRINT_PWD}@${SERVER_IP}/konica%20minolta%20virtual' \
  -P '/Library/Printers/PPDs/Contents/Resources/$PPD_NAME' \
  -E \
  -D 'Konica Minolta - PaperCut CISE (${SERVER_NAME})'"
osascript -e "do shell script \"$LPADMIN_CMD\" with administrator privileges" 2>/dev/null

# 8. Escala de grisos + activar
lpoptions -p "$PRINTER_NAME" -o ColorModel=Gray 2>/dev/null || true
osascript -e "do shell script \"lpadmin -p '$PRINTER_NAME' -o ColorModel=Gray && cupsenable '$PRINTER_NAME' && cupsaccept '$PRINTER_NAME'\" with administrator privileges" 2>/dev/null

# 9. Configurar inici automàtic (LaunchAgent)
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$LAUNCH_AGENTS_DIR/cat.cise.papercut-konica.plist"
mkdir -p "$LAUNCH_AGENTS_DIR"

cat > "$PLIST_FILE" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>cat.cise.papercut-konica</string>
    <key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}/pc-client-mac.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>${INSTALL_DIR}/papercut.log</string>
    <key>StandardErrorPath</key>
    <string>${INSTALL_DIR}/papercut-error.log</string>
</dict>
</plist>
PLIST

launchctl load "$PLIST_FILE" 2>/dev/null || true

# 10. Accés directe a l'Escriptori
cat > "$HOME/Desktop/PaperCut Konica.command" << CMD
#!/bin/bash
pkill -f "biz.papercut" 2>/dev/null || true
sleep 1
cd "${INSTALL_DIR}"
./pc-client-mac.sh
CMD
chmod +x "$HOME/Desktop/PaperCut Konica.command"

# ── Missatge final d'èxit ─────────────────────────────────
osascript << 'EOF'
tell application "System Events"
    activate
    display dialog "✅ La impressora Konica Minolta ha estat instal·lada correctament!

La impressora ja està disponible al teu Mac. El client PaperCut s'iniciarà automàticament cada vegada que obris sessió.

Tanca la sessió i torna a entrar per activar-ho." ¬
        with title "Instal·lació completada" ¬
        buttons {"D'acord"} ¬
        default button "D'acord" ¬
        with icon note
end tell
EOF

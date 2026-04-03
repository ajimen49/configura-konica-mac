# 🖨️ Configura_Konica_Mac

[![Versió](https://img.shields.io/badge/versió-1.0-blue.svg)](https://github.com/ajimen49/configura-konica-mac/releases)
[![macOS](https://img.shields.io/badge/macOS-12%2B-black.svg?logo=apple)](https://github.com/ajimen49/configura-konica-mac)
[![Llicència](https://img.shields.io/badge/llicència-MIT-green.svg)](LICENSE)
[![Comunitat](https://img.shields.io/badge/per_a-docents_de_Catalunya-orange.svg)](https://github.com/ajimen49/configura-konica-mac)

Instal·lador gràfic per a macOS que configura automàticament la impressora **Konica Minolta** amb **PaperCut MF** als centres educatius de la **Generalitat de Catalunya** (infraestructura CISE).

Sense terminal. Sense configuració manual. En menys d'un minut.

---

## ✨ Què fa

- ✅ Instal·la el driver PPD de la Konica Minolta
- ✅ Configura la cua d'impressió `KONICA-MINOLTA` via SMB
- ✅ Genera el fitxer `config.properties` amb les dades del centre
- ✅ Configura el client PaperCut MF 20.1.4
- ✅ Activa l'inici automàtic del client PaperCut en cada sessió
- ✅ Crea un accés directe a l'Escriptori per re-llançar manualment

---

## 💻 Compatibilitat

| | Suportat |
|---|---|
| macOS 12 Monterey | ✅ |
| macOS 13 Ventura | ✅ |
| macOS 14 Sonoma | ✅ |
| macOS 15 Sequoia | ✅ |
| Apple Silicon (M1/M2/M3/M4) | ✅ |
| Intel | ✅ |

---

## 📋 Requisits previs

Abans d'executar l'instal·lador necessitaràs:

| Dada | Exemple | On trobar-la |
|---|---|---|
| IP del servidor PaperCut | `10.241.XXX.XXX` | Coordinador TIC del centre |
| Codi del centre educatiu | `08062869` | Intranet XTEC o coordinador TIC |
| Contrasenya d'administrador del Mac | — | La teva pròpia |

---

## 🚀 Instal·lació

### 1. Descarrega el paquet

Ves a [**Releases**](https://github.com/ajimen49/configura-konica-mac/releases) i descarrega `Configura_Konica_Mac-v1.0.zip`

### 2. Elimina la quarantena de macOS (recomanat)

Obre el Terminal i executa:

```bash
cd ~/Downloads
unzip Configura_Konica_Mac-v1.0.zip
xattr -cr "Configura_Konica_Mac.app"
```

> Si saltes aquest pas, macOS mostrarà un avís la primera vegada.
> Solució: **clic dret → Obrir → Obrir igualment**

O bé fes doble clic a **`Elimina-Quarantena.command`** que trobaràs al paquet.

### 3. Genera el DMG (opcional, per distribuir als companys)

Des del Terminal del teu Mac:

```bash
hdiutil create \
  -volname "Configura Konica Mac" \
  -srcfolder Configura_Konica_Mac-v1.0/ \
  -ov -format UDZO \
  -o Configura_Konica_Mac-v1.0.dmg
```

### 4. Executa l'instal·lador

Fes doble clic a **`Configura_Konica_Mac.app`** i segueix els passos:

```
┌─────────────────────────────────────────┐
│  Benvingut/da a l'instal·lador...       │
│  [ Cancel·la ]        [ Continua → ]    │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  IP del servidor PaperCut:              │
│  [ 10.241.XXX.XXX         ]             │
│  [ ← Enrere ]    [ Següent → ]          │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  Codi del centre (8 dígits):            │
│  [ 08XXXXXX              ]              │
│  [ ← Enrere ]    [ Instal·la! ]         │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  ✅ La impressora Konica Minolta ha     │
│     estat instal·lada correctament!     │
│                        [ D'acord ]      │
└─────────────────────────────────────────┘
```

---

## ⚠️ Avisos de macOS (normals i esperats)

### 1. "No es pot obrir perquè prové d'un desenvolupador no identificat"
> L'app no està signada amb un certificat Apple de pagament.

**Solució:** Clic dret sobre l'app → **Obrir** → **Obrir igualment**
Només apareix la **primera vegada**. O executa `Elimina-Quarantena.command` del paquet.

### 2. "Vol fer canvis. Introdueix la teva contrasenya"
> Necessari per instal·lar el driver PPD al sistema.

**Solució:** Introdueix la contrasenya d'administrador del Mac. Normal en qualsevol instal·lador.

### 3. "Vol controlar System Events. Permetre-ho?"
> Necessari per mostrar els diàlegs de configuració.

**Solució:** Clica **D'acord**. Apareix una **sola vegada**.
Si ho denegues per error: **Configuració del Sistema → Privacitat i Seguretat → Automatització → activa Configura_Konica_Mac**

---

## 🗂️ Estructura del repositori

```
configura-konica-mac/
├── README.md
├── LICENSE
├── .gitignore
├── src/
│   └── Configura_Konica_Mac.sh     # Script principal (codi font)
└── releases/
    └── Configura_Konica_Mac-v1.0.zip
```

---

## 🔧 Detalls tècnics

El paquet inclou:
- **Driver PPD:** `KOC364SX.ppd` (Konica Minolta genèric CISE)
- **Client PaperCut:** MF 20.1.4 (build 57927) — llibreries Java pures
- **Connexió:** SMB → `smb://impressio@[IP]/konica minolta virtual`
- **LaunchAgent:** `cat.cise.papercut-konica.plist` (inici automàtic de sessió)
- **Config:** `server-ip`, `server-port=9191`, `server-name=SS[codi centre]`

---

## 🤝 Contribucions

Les contribucions són benvingudes! Si tens millores o ho has provat en un centre diferent:

1. Fes un **Fork** del repositori
2. Crea una branca: `git checkout -b millora/descripcio`
3. Commit: `git commit -m 'Afegeix millora X'`
4. **Pull Request**

Si trobes un error o tens un suggeriment, obre un [**Issue**](https://github.com/ajimen49/configura-konica-mac/issues).

---

## 📄 Llicència

Distribuït sota llicència [MIT](LICENSE). Lliure per usar, modificar i redistribuir.

---

## 🙏 Crèdits

- Basat en la documentació CISE de la **Generalitat de Catalunya**
- Creat per **[@ajimen49](https://github.com/ajimen49)** per a la comunitat docent
- Client PaperCut MF © PaperCut Software International Pty Ltd

---

*Fet amb ❤️ per la comunitat docent de Catalunya*

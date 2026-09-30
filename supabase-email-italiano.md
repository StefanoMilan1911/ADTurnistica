# Email di Supabase — SMTP e testi in italiano

Nessuna query SQL: è tutta configurazione dentro il pannello Supabase.

---

## PARTE 1 — Collegare la tua casella Gmail

### Passo 1: prepara l'account Google
1. Crea la casella dedicata (es. `adturnistica.noreply@gmail.com`)
2. Attiva la **verifica in due passaggi** — senza, il passo dopo non esiste
3. Vai su https://myaccount.google.com/apppasswords
4. Crea una **password per le app**: ti dà 16 caratteri tipo `abcd efgh ijkl mnop`
5. Copiala subito, non te la rimostra più

> Nota: NON usare la password normale dell'account. Solo quella generata qui.

### Passo 2: inseriscila in Supabase
Dashboard → **Authentication → Emails → SMTP Settings** → attiva *Enable Custom SMTP*

| Campo | Valore |
|---|---|
| Sender email | l'indirizzo Gmail creato sopra |
| Sender name | `ADTurnistica` |
| Host | `smtp.gmail.com` |
| Port | `465` |
| Username | lo stesso indirizzo Gmail |
| Password | la password per le app (16 caratteri, senza spazi) |

Salva. Poi in **Rate Limits** puoi alzare il numero di email all'ora.

### Passo 3: verifica
Fai un "Hai dimenticato la password?" da un indirizzo qualsiasi.
Se la mail arriva, è fatta. Controlla anche lo spam la prima volta.

---

## PARTE 2 — Testi in italiano

Dashboard → **Authentication → Emails → Templates**
Per ogni template cambia l'oggetto e incolla l'HTML.

---

### Template "Reset Password"

**Subject:** `Reimposta la password — ADTurnistica`

```html
<div style="font-family:system-ui,-apple-system,'Segoe UI',sans-serif;max-width:480px;margin:0 auto;padding:24px;color:#1C2B39;">
  <h2 style="margin:0 0 4px;font-size:20px;">Reimposta la password</h2>
  <p style="margin:0 0 20px;color:#5C6B72;font-size:14px;">ADTurnistica — gestione turni</p>

  <p style="font-size:15px;line-height:1.5;">
    Abbiamo ricevuto una richiesta di reimpostare la password del tuo account.
    Tocca il pulsante qui sotto per sceglierne una nuova.
  </p>

  <p style="margin:26px 0;">
    <a href="{{ .ConfirmationURL }}"
       style="background:#1C2B39;color:#EEF1EF;text-decoration:none;
              padding:12px 22px;border-radius:8px;display:inline-block;
              font-size:15px;">
      Scegli una nuova password
    </a>
  </p>

  <p style="font-size:13px;color:#5C6B72;line-height:1.5;">
    Se non hai richiesto tu il cambio, ignora questo messaggio:
    la tua password resta quella di prima.
  </p>

  <p style="font-size:12px;color:#8B9A96;margin-top:24px;
            border-top:1px solid #CBD3CF;padding-top:14px;">
    Il link vale per un'ora sola.
  </p>
</div>
```

---

### Template "Confirm signup"

**Subject:** `Conferma il tuo indirizzo — ADTurnistica`

```html
<div style="font-family:system-ui,-apple-system,'Segoe UI',sans-serif;max-width:480px;margin:0 auto;padding:24px;color:#1C2B39;">
  <h2 style="margin:0 0 4px;font-size:20px;">Benvenuto</h2>
  <p style="margin:0 0 20px;color:#5C6B72;font-size:14px;">ADTurnistica — gestione turni</p>

  <p style="font-size:15px;line-height:1.5;">
    Manca solo un passaggio: conferma che questo indirizzo è tuo
    e potrai iniziare a usare l'app.
  </p>

  <p style="margin:26px 0;">
    <a href="{{ .ConfirmationURL }}"
       style="background:#1C2B39;color:#EEF1EF;text-decoration:none;
              padding:12px 22px;border-radius:8px;display:inline-block;
              font-size:15px;">
      Conferma indirizzo
    </a>
  </p>

  <p style="font-size:13px;color:#5C6B72;line-height:1.5;">
    Se non ti sei registrato tu, puoi ignorare questo messaggio.
  </p>
</div>
```

---

### Template "Magic Link"

**Subject:** `Il tuo link di accesso — ADTurnistica`

```html
<div style="font-family:system-ui,-apple-system,'Segoe UI',sans-serif;max-width:480px;margin:0 auto;padding:24px;color:#1C2B39;">
  <h2 style="margin:0 0 4px;font-size:20px;">Accedi senza password</h2>
  <p style="margin:0 0 20px;color:#5C6B72;font-size:14px;">ADTurnistica — gestione turni</p>

  <p style="font-size:15px;line-height:1.5;">
    Tocca il pulsante per entrare. Non serve digitare nulla.
  </p>

  <p style="margin:26px 0;">
    <a href="{{ .ConfirmationURL }}"
       style="background:#1C2B39;color:#EEF1EF;text-decoration:none;
              padding:12px 22px;border-radius:8px;display:inline-block;
              font-size:15px;">
      Entra nell'app
    </a>
  </p>

  <p style="font-size:13px;color:#5C6B72;line-height:1.5;">
    Se non hai chiesto tu di accedere, ignora questo messaggio.
  </p>
</div>
```

---

### Template "Change Email Address"

**Subject:** `Conferma il nuovo indirizzo — ADTurnistica`

```html
<div style="font-family:system-ui,-apple-system,'Segoe UI',sans-serif;max-width:480px;margin:0 auto;padding:24px;color:#1C2B39;">
  <h2 style="margin:0 0 4px;font-size:20px;">Nuovo indirizzo email</h2>
  <p style="margin:0 0 20px;color:#5C6B72;font-size:14px;">ADTurnistica — gestione turni</p>

  <p style="font-size:15px;line-height:1.5;">
    Hai chiesto di usare questo indirizzo per il tuo account.
    Confermalo per renderlo attivo.
  </p>

  <p style="margin:26px 0;">
    <a href="{{ .ConfirmationURL }}"
       style="background:#1C2B39;color:#EEF1EF;text-decoration:none;
              padding:12px 22px;border-radius:8px;display:inline-block;
              font-size:15px;">
      Conferma nuovo indirizzo
    </a>
  </p>

  <p style="font-size:13px;color:#5C6B72;line-height:1.5;">
    Se non sei stato tu, ignora questo messaggio e avvisa chi gestisce l'app.
  </p>
</div>
```

---

## Cose da NON toccare

- `{{ .ConfirmationURL }}` va lasciato esattamente così: è il segnaposto
  che Supabase sostituisce col link vero. Se lo cambi, il link non funziona.
- In **Authentication → URL Configuration** devono esserci:
  - Site URL: `https://stefanomilan1911.github.io/ADTurnistica/`
  - Redirect URLs: lo stesso indirizzo

---

## Se le mail finiscono in spam

Mandando da un `@gmail.com` capita. Rimedi, in ordine di fatica:
1. Di' ai colleghi di segnare la prima mail come "non spam"
2. Se in futuro prendi un dominio tuo, passa a un servizio tipo Brevo o
   Resend e configuralo con quel dominio: la deliverabilità migliora molto

## Limiti di Gmail
Circa 500 email al giorno. Per un gruppo di 15 persone è abbondante:
le mail partono solo a registrazione o recupero password, non ogni giorno.

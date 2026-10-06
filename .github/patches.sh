#!/usr/bin/env bash
# Source patches applied after the zip is extracted (the zip itself is left untouched)
python3 - <<'PY'
import glob

matches = glob.glob('teleplay/**/ui/player/PlayerViewModel.kt', recursive=True)
if not matches:
    print('PATCH MISS: PlayerViewModel.kt not found')
    raise SystemExit(0)
path = matches[0]
s = open(path, encoding='utf-8', newline='').read()
crlf = '\r\n' in s
if crlf:
    s = s.replace('\r\n', '\n')

old = '''        val serverUrl = settingsRepository.getServerUrl()
        val subtitleUri = Uri.parse("$serverUrl/api/stream/${subtitle.id}")
        applyExternalSubtitle(
            uri = subtitleUri,
            label = subtitle.fileName,
            language = null,
            mimeType = subtitleMimeType(subtitle.fileName),
            externalId = subtitle.id.toString()
        )
'''
new = '''        viewModelScope.launch {
            val serverUrl = settingsRepository.getServerUrl()
            val subtitleUri = Uri.parse("$serverUrl/api/stream/${subtitle.id}")
            applyExternalSubtitle(
                uri = subtitleUri,
                label = subtitle.fileName,
                language = null,
                mimeType = subtitleMimeType(subtitle.fileName),
                externalId = subtitle.id.toString()
            )
        }
'''

if old in s:
    s = s.replace(old, new, 1)
    if crlf:
        s = s.replace('\n', '\r\n')
    open(path, 'w', encoding='utf-8', newline='').write(s)
    print('PATCH OK: addExternalSubtitle wrapped in viewModelScope.launch')
else:
    print('PATCH MISS: addExternalSubtitle block not found')
PY

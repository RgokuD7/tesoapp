
import os

file_path = '/Users/richardgoku/Documents/FlutterApps/tesoapp/lib/pages/role_selection_page.dart'

with open(file_path, 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
occurrences_found = 0

qr_code_block = """                                            // Bloque QR Activado
                                            if (_group != null)
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                child: SizedBox(
                                                  width: 180,
                                                  height: 180,
                                                  child: QrImageView(
                                                    data: _group!.code,
                                                    version: QrVersions.auto,
                                                    backgroundColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 24),
                                            const Text(
                                              "Comparte este código o escanea el QR para invitar a nuevos miembros",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromRGBO(100, 116, 139, 1),
                                              ),
                                            ),
"""

for line in lines:
    if "/* Container(" in line and "// Contenedor futuro para QR" in lines[lines.index(line)-1]:
         # Starts comment block logic handled by skip
         continue
    
    if "// Contenedor futuro para QR" in line:
        occurrences_found += 1
        # Ya parcheamos la primera (Admin). Si encontramos la segunda (Member)...
        # O si el usuario revirtió...
        
        # Vamos a parchear SIEMPRE que encontremos la marca, excepto si ya parece parcheado
        # Pero mi script anterior dejo la marca "// Contenedor futuro para QR" AL FINAL del bloque insertado?
        # No, mi script anterior reemplazó la linea de marca por el bloque + marca al final?
        # Veamos el script anterior:
        # new_lines.append(qr_code_block) ... new_lines no incluia la marca original al inicio, 
        # pero el qr_code_block NO incluia la marca al final en el string python (o si? check step 719). 
        # step 719 string did NOT have the comment at the end. It had `const Text(...)`.
        pass

    # Detectar inicio de bloque comentado antiguo
    if "// Contenedor futuro para QR" in line:
         # Esto identifica el anchor.
         # Reemplazamos el anchor y el bloque siguiente.
         new_lines.append(qr_code_block)
         skip = True
         continue
    
    if skip:
        if "*/" in line:
            skip = False
        continue
    
    new_lines.append(line)

# WAIT. My logic is flawed because the FIRST occurrence is already patched and DOES NOT have "// Contenedor futuro para QR" anymore?
# Let's check the file content first.

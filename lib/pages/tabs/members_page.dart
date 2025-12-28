import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../models/group.dart';
import '../../utils/formatters.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  List<User> _membersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  // Cargar info de usuarios
  Future<void> _loadMembers() async {
    final group = ref.read(groupProvider);
    if (group == null) return;

    final userNotifier = ref.read(userProvider.notifier);
    final List<User> loadedMembers = [];

    // Cargar en paralelo para mayor velocidad
    // Nota: Firestore tiene límites de lecturas simultáneas pero para <100 usuarios suele ir bien en paralelo o batches pequeños.
    // Usaremos un mapeo simple de futuros.
    final futures = group.members.map((id) => userNotifier.getUser(id));
    final results = await Future.wait(futures);

    for (var u in results) {
      if (u != null) loadedMembers.add(u);
    }

    if (mounted) {
      setState(() {
        _membersList = loadedMembers;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSubAdmin(String userId, bool isPromoting) async {
    final group = ref.read(groupProvider);
    if (group == null) return;

    List<String> newSubAdmins = List.from(group.subAdmins);

    if (isPromoting) {
      if (!newSubAdmins.contains(userId)) {
        newSubAdmins.add(userId);
      }
    } else {
      newSubAdmins.remove(userId);
    }

    final updatedGroup = group.copyWith(subAdmins: newSubAdmins);

    // Actualizar usando el notifier, que actualiza DB y Estado local
    await ref.read(groupProvider.notifier).updateGroup(updatedGroup);

    setState(() {}); // Refrescar UI
  }

  void _showMemberOptions(User user, bool isSubAdmin, bool isGroupAdmin) {
    if (!isGroupAdmin) return; // Solo el admin principal puede gestionar roles

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  isSubAdmin
                      ? Icons.remove_moderator_rounded
                      : Icons.add_moderator_rounded,
                  color: isSubAdmin ? Colors.red : Colors.blue,
                ),
                title: Text(
                  isSubAdmin
                      ? "Quitar rol de Administrador"
                      : "Hacer Administrador",
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _toggleSubAdmin(user.id, !isSubAdmin);
                },
              ),
              // Más opciones como "Eliminar" se pueden agregar aquí
            ],
          ),
        );
      },
    );
  }

  void _showInviteDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Invitar miembros",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Comparte este código con tus amigos para que se unan al grupo:",
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Código copiado!")),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "O escanea este código QR:",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (code.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Código QR no disponible",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider);
    final currentUser = ref.watch(userProvider);

    if (group == null || currentUser == null)
      return const Center(child: CircularProgressIndicator());

    final isGroupAdmin = group.admin == currentUser.id;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gestión de Miembros",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Administra los miembros de tu grupo",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: _membersList.length,
                      itemBuilder: (context, index) {
                        final mUser = _membersList[index];
                        final isOwner = group.admin == mUser.id;
                        final isSubAdmin = group.subAdmins.contains(mUser.id);
                        final isMe = mUser.id == currentUser.id;

                        // Badge Widget
                        Widget? badge;
                        if (isOwner) {
                          badge = _RoleBadge(
                            label: "Admin",
                            color: const Color(0xFF2563EB),
                          ); // Azul
                        } else if (isSubAdmin) {
                          badge = _RoleBadge(
                            label: "Admin",
                            color: const Color(0xFF2563EB),
                          ); // Azul
                        } else {
                          badge = _RoleBadge(
                            label: "Activo",
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            textColor: const Color(0xFF10B981),
                          ); // Verde
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: (isGroupAdmin && !isOwner)
                                ? () => _showMemberOptions(
                                    mUser,
                                    isSubAdmin,
                                    isGroupAdmin,
                                  )
                                : null,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isOwner || isSubAdmin
                                      ? const Color(0xFF2563EB)
                                      : const Color(
                                          0xFFF59E0B,
                                        ), // Azul admins, Amarillo miembros
                                  child: Text(
                                    Formatters.initials(
                                      mUser.firstName,
                                      mUser.lastName,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${Formatters.firstNameAndLastName(mUser.firstName, mUser.lastName)}${isMe ? ' (Tú)' : ''}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isOwner
                                            ? "Administrador Principal"
                                            : (isSubAdmin
                                                  ? "Administrador"
                                                  : "Miembro activo"),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (badge != null) badge,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _showInviteDialog(group.code),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
              elevation: 0,
              side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Invitar más miembros",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const _RoleBadge({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: textColor != null
            ? color
            : color, // Si textColor es null, usa color como fondo sólido (admin style)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

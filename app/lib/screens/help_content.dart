import 'package:flutter/material.dart';
import '../constants.dart';

class HelpContent extends StatefulWidget {
  const HelpContent({super.key});

  @override
  _HelpContentState createState() => _HelpContentState();
}

class _HelpContentState extends State<HelpContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSections = [];

  // Lista de secciones de ayuda con íconos minimalistas
  final List<Map<String, dynamic>> _helpSections = [
    {
      'title': AppStrings.registerTabletTitle,
      'steps': AppStrings.registerTabletSteps,
      'icon': Icons.tablet_android,
    },
    {
      'title': AppStrings.historyTitle,
      'steps': AppStrings.historySteps,
      'icon': Icons.history,
    },
    {
      'title': AppStrings.supportTitle,
      'steps': AppStrings.supportSteps,
      'icon': Icons.help_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredSections = _helpSections;
    _searchController.addListener(_filterSections);
  }

  void _filterSections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSections = _helpSections.where((section) {
        final title = section['title'].toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de búsqueda minimalista
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textSecondary),
            decoration: InputDecoration(
              hintText: 'Buscar en ayuda...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _filteredSections
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildHelpSection(
                      index: entry.key,
                      title: entry.value['title'],
                      steps: entry.value['steps'],
                      icon: entry.value['icon'],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection({
    required int index,
    required String title,
    required List<String> steps,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent, // Elimina líneas divisorias
          ),
          child: ExpansionTile(
            leading: Icon(
              icon,
              color: AppColors.cfeGreen,
              size: 24,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.cfeDarkGreen,
              ),
            ),
            iconColor: AppColors.cfeGreen,
            collapsedIconColor: AppColors.textSecondary,
            backgroundColor: Colors.white, // Fondo blanco al expandir
            collapsedBackgroundColor: Colors.white, // Fondo blanco al colapsar
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: steps
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(
                            color: AppColors.cfeGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/add_skill_view_model.dart';
import 'skill_item.dart';

class AddSkillScreen extends StatelessWidget {
  const AddSkillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddSkillViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add Skill',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Design',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: vm.searchTerm.isNotEmpty
                      ? IconButton(icon: Icon(Icons.close), onPressed: ()=> vm.setSearchTerm(''))
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: vm.setSearchTerm,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: vm.filteredSkills.length,
                  itemBuilder: (context, index) {
                    final skill = vm.filteredSkills[index];
                    final selected = vm.selectedSkills.contains(skill);
                    return GestureDetector(
                      onTap: () => vm.toggleSkill(skill),
                      child: SkillItem(
                        skill: skill,
                        selected: selected,
                      ),
                    );
                  },
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

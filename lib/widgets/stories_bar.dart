import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'story_view_dialog.dart';

class StoriesBar extends StatelessWidget {
  final List<StoryItem> stories;
  final VoidCallback? onAddStory;
  final bool isAdmin;

  const StoriesBar({
    super.key,
    required this.stories,
    this.onAddStory,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: stories.length + (isAdmin ? 1 : 0),
        itemBuilder: (context, index) {
          if (isAdmin && index == 0) {
            return _buildAddStoryButton(context);
          }

          final storyIndex = isAdmin ? index - 1 : index;
          final story = stories[storyIndex];

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                builder: (context) => StoryViewDialog(story: story),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: story.isRead
                            ? [Colors.grey.shade400, Colors.grey.shade500]
                            : [
                                AppColors.primaryBlue,
                                AppColors.primaryGreen,
                                Colors.amber,
                              ],
                      ),
                      boxShadow: [
                        if (!story.isRead)
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          story.icon,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 68,
                    child: Text(
                      story.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddStoryButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddStory,
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primaryBlue,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Icon(Icons.add, color: AppColors.primaryBlue, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '+ Qo\'shish',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

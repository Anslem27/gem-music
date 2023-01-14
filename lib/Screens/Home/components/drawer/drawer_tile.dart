import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final bool isCollapsed;
  final IconData icon;
  final String title;
  final Function()? ontap;

  const CustomListTile({
    Key? key,
    required this.isCollapsed,
    required this.icon,
    required this.title,
    this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: isCollapsed ? 300 : 80,
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              if (isCollapsed) const SizedBox(width: 10),
              if (isCollapsed)
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              if (isCollapsed) const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره برنامه')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.savings,
                  color: Color(0xFF2E7D32), size: 42),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'مدیریت هزینه ها',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'نسخه ۱.۰.۰',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Text(
              'مدیریت هزینه ها یک اپلیکیشن کامل برای مدیریت مالی شخصی است که به شما کمک می کند درآمدها، هزینه ها، بودجه و اهداف مالی خود را به سادگی پیگیری کنید. تمام اطلاعات شما به صورت کاملا آفلاین و بر روی دستگاه شما ذخیره می شود.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حریم خصوصی',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'هیچ داده ای از دستگاه شما به سرور ارسال نمی شود. تمام اطلاعات به صورت محلی روی گوشی شما نگهداری می شود.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

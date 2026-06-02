import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'write_post_page.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("커뮤니티 "),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('posts')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false)
            .map((data) => List<Map<String, dynamic>>.from(data)),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return Center(
              child: Text(
                "아직 글이 없습니다. 첫 글을 써보세요!",
                style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
              ),
            );
          }

          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostItem(post, isDark);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePostPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
      },
      child: Container(
        
        color: Theme.of(context).cardColor, 
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: _supabase
              .from('profiles')
              .select()
              .eq('id', post['user_id'])
              .maybeSingle(),
          builder: (context, AsyncSnapshot profileSnap) {
            Map<String, dynamic> postWithProfile = Map.from(post);
            if (profileSnap.hasData && profileSnap.data != null) {
              postWithProfile['profiles'] = profileSnap.data;
            } else {
              postWithProfile['profiles'] = {'nickname': '로딩중...'};
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(post: postWithProfile),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['content'],
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: isDark
                                ? Colors.white
                                : Colors.black87, 
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              postWithProfile['profiles']['nickname'] ?? '익명',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(post['created_at']),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (post['image_url'] != null)
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post['image_url']),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "방금 전";
    if (diff.inHours < 1) return "${diff.inMinutes}분 전";
    if (diff.inDays < 1) return "${diff.inHours}시간 전";
    return DateFormat('MM.dd').format(date);
  }
}

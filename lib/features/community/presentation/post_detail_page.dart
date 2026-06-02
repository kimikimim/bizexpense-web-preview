import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'write_post_page.dart'; 

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post; 

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _supabase = Supabase.instance.client;
  final _commentController = TextEditingController();
  
  bool _isLiked = false;
  int _likeCount = 0;
  String? _myId;

  @override
  void initState() {
    super.initState();
    _myId = _supabase.auth.currentUser?.id;
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final postId = widget.post['id'];
    
    final myLike = await _supabase
        .from('post_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', _myId!)
        .maybeSingle();

    final count = await _supabase
        .from('post_likes')
        .count(CountOption.exact) 
        .eq('post_id', postId);

    if (mounted) {
      setState(() {
        _isLiked = myLike != null;
        _likeCount = count; 
      });
    }
  }

  Future<void> _toggleLike() async {
    final postId = widget.post['id'];
    if (_isLiked) {
      await _supabase.from('post_likes').delete().eq('post_id', postId).eq('user_id', _myId!);
      setState(() { _isLiked = false; _likeCount--; });
    } else {
      await _supabase.from('post_likes').insert({'post_id': postId, 'user_id': _myId!});
      setState(() { _isLiked = true; _likeCount++; });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await _supabase.from('comments').insert({
      'post_id': widget.post['id'],
      'user_id': _myId,
      'content': _commentController.text.trim(),
    });
    _commentController.clear();
    FocusScope.of(context).unfocus(); 
  }

  Future<void> _deleteComment(String commentId) async {
    await _supabase.from('comments').delete().eq('id', commentId);
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("삭제"), content: const Text("정말 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("삭제", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _supabase.from('posts').delete().eq('id', widget.post['id']);
      if (mounted) Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyPost = widget.post['user_id'] == _myId;
    final createdDate = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(widget.post['created_at']));

    return Scaffold(
      appBar: AppBar(
        title: const Text("게시글"),
        actions: [
          if (isMyPost)
            PopupMenuButton(
              onSelected: (value) async {
                if (value == 'edit') {
                  
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => WritePostPage(initialPost: widget.post)));
                  if (result == true) Navigator.pop(context, true); 
                } else if (value == 'delete') {
                  _deletePost();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("수정")),
                const PopupMenuItem(value: 'delete', child: Text("삭제")),
              ],
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.post['profiles']['nickname'] ?? '익명', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(createdDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(widget.post['content'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                
                if (widget.post['image_url'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(widget.post['image_url']),
                  ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey
                      ),
                      label: Text("공감 $_likeCount"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isLiked ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),

                const Text("댓글", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _supabase.from('comments')
                      .stream(primaryKey: ['id'])
                      .eq('post_id', widget.post['id'])
                      .order('created_at', ascending: true)
                      .map((data) => List<Map<String, dynamic>>.from(data)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final comments = snapshot.data!;
                    
                    return ListView.separated(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(), 
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final isMyComment = comment['user_id'] == _myId;
                        
                        return FutureBuilder(
                          
                          future: _supabase.from('profiles').select('nickname').eq('id', comment['user_id']).maybeSingle(),
                          builder: (context, snap) {
                            String nick = "익명";
                            if (snap.hasData && snap.data != null) nick = snap.data!['nickname'] ?? "익명";
                            
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(radius: 12, backgroundColor: Colors.grey[200], child: const Icon(Icons.person, size: 16, color: Colors.grey)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(nick, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          if (isMyComment)
                                            GestureDetector(
                                              onTap: () => _deleteComment(comment['id']),
                                              child: const Icon(Icons.close, size: 16, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(comment['content']),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
          
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "따뜻한 댓글을 남겨주세요",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send, color: Colors.blueGrey),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

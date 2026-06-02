import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WritePostPage extends StatefulWidget {
  
  final Map<String, dynamic>? initialPost; 

  const WritePostPage({super.key, this.initialPost});

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final _contentController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  
  XFile? _imageFile;
  bool _isLoading = false;
  String? _existingImageUrl; 

  @override
  void initState() {
    super.initState();
    
    if (widget.initialPost != null) {
      _contentController.text = widget.initialPost!['content'];
      _existingImageUrl = widget.initialPost!['image_url'];
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = picked);
  }

  Future<void> _savePost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_post.jpg';
        await _supabase.storage.from('community').uploadBinary(
          fileName, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg')
        );
        imageUrl = _supabase.storage.from('community').getPublicUrl(fileName);
      }

      if (widget.initialPost != null) {
        
        await _supabase.from('posts').update({
          'content': _contentController.text,
          'image_url': imageUrl,
        }).eq('id', widget.initialPost!['id']);
      } else {
        
        await _supabase.from('posts').insert({
          'user_id': userId,
          'content': _contentController.text,
          'image_url': imageUrl,
        });
      }

      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("저장 실패")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialPost != null ? "글 수정" : "글쓰기"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePost,
            child: const Text("완료", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null, 
                expands: true,
                decoration: const InputDecoration(
                  hintText: "사장님들과 나누고 싶은 이야기를 적어보세요.\n(질문, 고민, 홍보 등)",
                  border: InputBorder.none,
                ),
              ),
            ),
            
            if (_imageFile != null)
              SizedBox(height: 100, child: Image.network(_imageFile!.path, fit: BoxFit.cover)) 
            else if (_existingImageUrl != null)
              SizedBox(height: 100, child: Image.network(_existingImageUrl!, fit: BoxFit.cover)),
            
            const Divider(),
            
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt, color: Colors.blueGrey),
                ),
                const Text("사진 추가"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

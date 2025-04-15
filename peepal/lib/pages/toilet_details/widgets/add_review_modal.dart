import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class AddReviewModal extends StatefulWidget {
  final PPToilet toilet;
  final double height;
  final FutureOr<void> Function({
    required int rating,
    required String comment,
    File? image,
  }) onConfirm;

  const AddReviewModal({
    super.key,
    required this.toilet,
    required this.height,
    required this.onConfirm,
  });

  @override
  State<AddReviewModal> createState() => _AddReviewModalState();
}

class _AddReviewModalState extends State<AddReviewModal> {
  final _commentController = TextEditingController();
  final _picker = ImagePicker();

  int _selectedRating = 3;
  bool _isLoading = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0),
      height: widget.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Column(children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 10.0),
                child: Text(
                  'Add Review',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ]),
          ),
          Text(
            "Thank you for your contribution!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          _buildRating(),
          const SizedBox(height: 10.0),
          _buildComment(),
          const SizedBox(height: 20.0),
          _buildImagePicker(),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PPButton("Cancel",
                        width: constraints.maxWidth * 0.49,
                        outline: true,
                        onPressed: () => Navigator.pop(context)),
                    PPButton("Confirm",
                        width: constraints.maxWidth * 0.49,
                        isLoading: _isLoading, onPressed: () async {
                      setState(() => _isLoading = true);

                      final BuildContext current = context;
                      try {
                        await widget.onConfirm(
                          rating: _selectedRating,
                          comment: _commentController.text,
                          image: _selectedImage,
                        );
                        setState(() => _isLoading = false);
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (current.mounted) {
                          ScaffoldMessenger.of(current).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to submit review'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }

                      if (current.mounted) {
                        Navigator.pop(current);
                      }
                    }),
                  ]),
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _selectedRating
                ? Icons.star
                : index + 0.5 == _selectedRating
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 32.0,
          ),
          onPressed: () => setState(() => _selectedRating = index + 1),
        );
      }),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImage != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  _selectedImage!,
                  height: 120.0,
                  width: 120.0,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildComment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        TextField(
          maxLines: 3,
          controller: _commentController,
          textInputAction: TextInputAction.done,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

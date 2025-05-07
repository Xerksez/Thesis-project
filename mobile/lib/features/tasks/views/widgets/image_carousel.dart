import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<File> images;
  final Function(int) onRemoveImage;

  const ImageCarousel({
    super.key,
    required this.images,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
      ),
      items: images.asMap().entries.map((entry) {
        int index = entry.key;
        File image = entry.value;

        // Log the image path for debugging
        print('Displaying Image: ${image.path}');
        print('Image Exists: ${image.existsSync()}');

        return Stack(
          children: [
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: Image.file(image, fit: BoxFit.cover),
                ),
              ),
              child: Image.file(image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Failed to load image'));
              }),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  print('Removing image at index: $index');
                  onRemoveImage(index);
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
/// Carousel to display network images fetched from API
class DisplayImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const DisplayImageCarousel({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrls.isEmpty
        ? const Center(
            child: Text(
              'No photo to display',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : CarouselSlider(
            options: CarouselOptions(
              height: 200,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
            ),
            items: imageUrls.map((url) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 80, color: Colors.white54),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          );
  }
}

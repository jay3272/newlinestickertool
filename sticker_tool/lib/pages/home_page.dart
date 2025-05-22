import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import '../services/sticker_api_service.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  late final StickerApiService _apiService;
  
  XFile? _selectedImage;
  Uint8List? _processedImageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  // 裁剪框相關狀態
  double _cropX = 0;
  double _cropY = 0;
  double _cropWidth = 100;
  double _cropHeight = 100;
  bool _isDragging = false;
  Offset? _dragStartPosition;
  Offset? _currentPosition;

  // 原始圖片尺寸
  ui.Image? _originalImage;
  double _originalImageWidth = 0;
  double _originalImageHeight = 0;

  // 顯示圖片尺寸 (在 BoxFit.contain 下的實際尺寸)
  Size? _displayedImageSize;

  // 縮放參數
  final TextEditingController _resizeWidthController = TextEditingController(text: '200');
  final TextEditingController _resizeHeightController = TextEditingController(text: '200');

  @override
  void initState() {
    super.initState();
    _apiService = StickerApiService();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        _originalImage = frame.image;

        setState(() {
          _selectedImage = image;
          _processedImageBytes = null;
          _errorMessage = null;
          _originalImageWidth = _originalImage!.width.toDouble();
          _originalImageHeight = _originalImage!.height.toDouble();
          _displayedImageSize = null;
          // 重置裁剪框位置
          _cropX = 0;
          _cropY = 0;
          _cropWidth = 100;
          _cropHeight = 100;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '選擇圖片時發生錯誤：$e';
      });
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImage == null || _originalImage == null || _displayedImageSize == null || _displayedImageSize!.isEmpty) {
      setState(() {
        _errorMessage = '請先選擇圖片並等待圖片載入';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 計算比例
      final double scaleX = _originalImageWidth / _displayedImageSize!.width;
      final double scaleY = _originalImageHeight / _displayedImageSize!.height;

      // 根據比例調整裁剪座標和尺寸
      final int cropX = (_cropX * scaleX).round();
      final int cropY = (_cropY * scaleY).round();
      final int cropWidth = (_cropWidth * scaleX).round();
      final int cropHeight = (_cropHeight * scaleY).round();

      final croppedImageBytes = await _apiService.cropImage(
        _selectedImage!,
        cropX,
        cropY,
        cropWidth,
        cropHeight,
      );

      setState(() {
        _processedImageBytes = croppedImageBytes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resizeImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = '請先選擇圖片';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final resizedImageBytes = await _apiService.resizeImage(
        _selectedImage!,
        int.parse(_resizeWidthController.text),
        int.parse(_resizeHeightController.text),
      );

      setState(() {
        _processedImageBytes = resizedImageBytes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImagePreview(XFile image) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
               // 獲取 Image 在 BoxFit.contain 下的實際渲染尺寸
               final originalWidth = _originalImageWidth;
               final originalHeight = _originalImageHeight;
               final maxConstraintsWidth = constraints.maxWidth;
               final maxConstraintsHeight = 300.0; // 與 Image.memory 的 height 相同

               final fittedSizes = applyBoxFit(
                 BoxFit.contain,
                 Size(originalWidth, originalHeight),
                 Size(maxConstraintsWidth, maxConstraintsHeight),
               );

               WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (_displayedImageSize != fittedSizes.destination) {
                    setState(() {
                      _displayedImageSize = fittedSizes.destination;
                      // 根據新的顯示尺寸調整裁剪框位置，確保不超出邊界
                      _cropX = _cropX.clamp(0.0, _displayedImageSize!.width - _cropWidth);
                      _cropY = _cropY.clamp(0.0, _displayedImageSize!.height - _cropHeight);
                      _cropWidth = _cropWidth.clamp(50.0, _displayedImageSize!.width - _cropX);
                      _cropHeight = _cropHeight.clamp(50.0, _displayedImageSize!.height - _cropY);
                    });
                 }
               });

              return Stack(
                children: [
                  Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                    height: 300, // 限制顯示高度
                  ),
                  if (_displayedImageSize != null) // 確保顯示尺寸已計算
                    Positioned(
                      left: _cropX,
                      top: _cropY,
                      child: GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            _isDragging = true;
                            _dragStartPosition = details.localPosition;
                            _currentPosition = Offset(_cropX, _cropY);
                          });
                        },
                        onPanUpdate: (details) {
                          if (_dragStartPosition != null && _currentPosition != null && _displayedImageSize != null) {
                            setState(() {
                              _cropX = (_currentPosition!.dx + details.localPosition.dx - _dragStartPosition!.dx).clamp(0.0, _displayedImageSize!.width - _cropWidth);
                              _cropY = (_currentPosition!.dy + details.localPosition.dy - _dragStartPosition!.dy).clamp(0.0, _displayedImageSize!.height - _cropHeight);
                            });
                          }
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _isDragging = false;
                            _dragStartPosition = null;
                            _currentPosition = null;
                          });
                        },
                        child: Container(
                          width: _cropWidth,
                          height: _cropHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            color: Colors.red.withOpacity(0.1),
                          ),
                          child: Stack(
                            children: [
                              // 調整大小的控制點
                              Positioned(
                                right: -5,
                                bottom: -5,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    if (_displayedImageSize != null) {
                                      setState(() {
                                        _cropWidth = (_cropWidth + details.delta.dx).clamp(50.0, _displayedImageSize!.width - _cropX);
                                        _cropHeight = (_cropHeight + details.delta.dy).clamp(50.0, _displayedImageSize!.height - _cropY);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('載入圖片失敗：${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildProcessedImage() {
    if (_processedImageBytes != null) {
      return Image.memory(
        _processedImageBytes!,
        fit: BoxFit.contain,
        height: 300,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('貼圖工具'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('選擇圖片'),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('原始圖片', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildImagePreview(_selectedImage!),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_processedImageBytes != null)
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('處理結果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _buildProcessedImage(),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('裁剪功能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _cropImage,
                        child: Text(_isLoading ? '處理中...' : '裁剪'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('縮放功能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _resizeWidthController,
                              decoration: const InputDecoration(labelText: '寬度'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _resizeHeightController,
                              decoration: const InputDecoration(labelText: '高度'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _resizeImage,
                        child: Text(_isLoading ? '處理中...' : '縮放'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiService.dispose();
    _resizeWidthController.dispose();
    _resizeHeightController.dispose();
    super.dispose();
  }
} 
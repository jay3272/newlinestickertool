import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/sticker_api_service.dart';

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

  // 裁剪參數控制器
  final TextEditingController _cropXController = TextEditingController(text: '0');
  final TextEditingController _cropYController = TextEditingController(text: '0');
  final TextEditingController _cropWidthController = TextEditingController(text: '100');
  final TextEditingController _cropHeightController = TextEditingController(text: '100');

  // 縮放參數
  final TextEditingController _resizeWidthController = TextEditingController(text: '200');
  final TextEditingController _resizeHeightController = TextEditingController(text: '200');

  @override
  void initState() {
    super.initState();
    _apiService = StickerApiService();
    _cropXController.addListener(_updateCropFromControllers);
    _cropYController.addListener(_updateCropFromControllers);
    _cropWidthController.addListener(_updateCropFromControllers);
    _cropHeightController.addListener(_updateCropFromControllers);
  }

  void _updateCropFromControllers() {
    if (!_isDragging) {
      setState(() {
        _cropX = double.tryParse(_cropXController.text) ?? 0;
        _cropY = double.tryParse(_cropYController.text) ?? 0;
        _cropWidth = double.tryParse(_cropWidthController.text) ?? 100;
        _cropHeight = double.tryParse(_cropHeightController.text) ?? 100;
      });
    }
  }

  void _updateControllersFromCrop() {
    _cropXController.text = _cropX.round().toString();
    _cropYController.text = _cropY.round().toString();
    _cropWidthController.text = _cropWidth.round().toString();
    _cropHeightController.text = _cropHeight.round().toString();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _processedImageBytes = null;
          _errorMessage = null;
          // 重置裁剪框位置
          _cropX = 0;
          _cropY = 0;
          _cropWidth = 100;
          _cropHeight = 100;
          _updateControllersFromCrop();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '選擇圖片時發生錯誤：$e';
      });
    }
  }

  Future<void> _cropImage() async {
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
      final croppedImageBytes = await _apiService.cropImage(
        _selectedImage!,
        _cropX.round(),
        _cropY.round(),
        _cropWidth.round(),
        _cropHeight.round(),
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
          return Stack(
            children: [
              Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
                height: 300,
              ),
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
                    if (_dragStartPosition != null && _currentPosition != null) {
                      setState(() {
                        _cropX = _currentPosition!.dx + details.localPosition.dx - _dragStartPosition!.dx;
                        _cropY = _currentPosition!.dy + details.localPosition.dy - _dragStartPosition!.dy;
                        _updateControllersFromCrop();
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
                              setState(() {
                                _cropWidth = (_cropWidth + details.delta.dx).clamp(50.0, 300.0);
                                _cropHeight = (_cropHeight + details.delta.dy).clamp(50.0, 300.0);
                                _updateControllersFromCrop();
                              });
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cropXController,
                              decoration: const InputDecoration(labelText: 'X 座標'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _cropYController,
                              decoration: const InputDecoration(labelText: 'Y 座標'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cropWidthController,
                              decoration: const InputDecoration(labelText: '寬度'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _cropHeightController,
                              decoration: const InputDecoration(labelText: '高度'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
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
    _cropXController.dispose();
    _cropYController.dispose();
    _cropWidthController.dispose();
    _cropHeightController.dispose();
    _resizeWidthController.dispose();
    _resizeHeightController.dispose();
    super.dispose();
  }
} 
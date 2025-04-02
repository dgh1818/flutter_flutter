part of dart.ui;

class SetHdr {
  SetHdr({this.hdr = 0, this.is_image = true});

  static void setHdrMode({int hdr = 0, bool is_image = true}) {
    _SetHdr.setHdrMode(hdr:hdr,is_image:is_image);
  }

  static void enableHdr({bool enable_hdr = true}) {
    _SetHdr.enableHdr(enable_hdr:enable_hdr);
  }

  int hdr = 0;
  bool is_image = true;
}

base class _SetHdr extends NativeFieldWrapperClass1 {
  _SetHdr({required this.hdr, required this.is_image});

  static void setHdrMode({required int hdr, required bool is_image}) {
    _initSetHdr(hdr, is_image);
  }

  static void enableHdr({required bool enable_hdr}) {
    _enableHdr(enable_hdr);
  }

  int hdr = 0;
  bool is_image = true;

  @Native<Void Function(Int32, Bool)>(symbol: 'SetHdr::initSetHdr')
  external static void _initSetHdr(int hdr, bool is_image);

  @Native<Void Function(Bool)>(symbol: 'SetHdr::enableHdr')
  external static void _enableHdr(bool enable_hdr);

  @Native<Void Function(Handle)>(symbol: 'SetHdr::Create')
  external void _constructor();
}
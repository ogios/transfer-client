class DFile {
  DFile(
      {Function? onInit,
      Function? onProgress,
      Function? onSuccess,
      Function? onError}) {
    if (onInit != null) this._onInit = onInit;
    if (onProgress != null) this._onProcess = onProgress;
    if (onSuccess != null) this._onSuccess = onSuccess;
    if (onError != null) this._onError = onError;
  }
  Function _onInit = () {};
  Function _onProcess = () {};
  Function _onSuccess = () {};
  Function _onError = () {};

  set onInit(Function value) {
    _onInit = value;
  }

  set onProcess(Function value) {
    _onProcess = value;
  }

  set onSuccess(Function value) {
    _onSuccess = value;
  }

  set onError(Function value) {
    _onError = value;
  }

  void clearCallback() {
    _onInit = (){};
    _onProcess = (){};
    _onSuccess = (){};
    _onError = (){};
  }


  //  0 - not init
  //  1 - processing
  //  2 - success done
  // -1 - error
  int state = STATE_INIT;

  late final String _filename;
  String get filename => _filename;
  set filename(String value) {
    _filename = value;
  }

  late final int _size;
  int get size => _size;
  set size(int value) {
    _size = value;
    this.state = STATE_PROCESS;
    _onInit();
  }

  int _current = 0;
  int get current => _current;
  set current(int value) {
    _current = value;
    _onProcess();
  }

  bool _done = false;
  bool get done => _done;
  set done(bool value) {
    _done = value;
    this.state = STATE_SUCCESS;
    _onSuccess();
  }

  bool _error = false;
  bool get error => _error;
  set error(bool value) {
    _error = value;
    this.state = STATE_ERROR;
    _onError();
  }

  String errText = "";
}

const STATE_ERROR = -1;
const STATE_INIT = 0;
const STATE_PROCESS = 1;
const STATE_SUCCESS = 2;

HTML Memo — Native macOS
========================

이 프로젝트는 업로드된 HTML_Memo.html을 WKWebView 안에서 실행하는 실제 macOS AppKit 앱입니다.
Chrome/Edge/Brave 같은 브라우저를 호출하지 않습니다.

주요 변경:
- HTML 편집기/이미지 임베드/이미지 크기조절/자르기/HTML 소스 모드는 원본 유지
- 파일 열기: macOS NSOpenPanel
- 저장/다른 이름으로 저장: macOS NSSavePanel
- Command+O / Command+S / Shift+Command+S 지원
- HTML 문서를 macOS에서 연결 가능한 앱으로 등록
- 앱 내부 Resources에 HTML_Memo.html 포함

빌드 방법 (macOS + Xcode):
1. HTML_Memo.xcodeproj를 Xcode로 엽니다.
2. Scheme이 "HTML Memo"인지 확인합니다.
3. Run 또는 Product > Archive/Build를 실행합니다.
4. 또는 터미널에서 ./build_mac.sh 실행합니다.

주의:
- 현재 실행 환경은 Linux라서 Apple macOS SDK/WebKit 프레임워크를 이용한 최종 .app 바이너리를 여기서 직접 컴파일할 수 없습니다.
- 따라서 이 압축파일은 Mac에서 바로 빌드 가능한 네이티브 Xcode 프로젝트입니다.
- 코드 서명/Apple 공증은 사용자의 Apple Developer 계정 및 Mac 환경에서 별도로 할 수 있습니다.

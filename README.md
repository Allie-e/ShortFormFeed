# ShortFormFeed
- API를 활용한 소셜미디어 피드
### 개발 환경
- 프로그램 <img src="https://img.shields.io/badge/xcode-v14.3-white?logo=xcode&logoColor=skyblue"/>
- 언어 <img src="https://img.shields.io/badge/Swift-v5-white?style=round-square&logo=swift&logoColor=orange"/>
- 도구 <img src="https://img.shields.io/badge/CocoaPods-F15148?style=round-square">
- Deployment Target <img src="https://img.shields.io/badge/iOS-14.0-white">
- 라이브러리
    - <img src="https://img.shields.io/badge/Alamofire-5.6.2-red">
    - <img src="https://img.shields.io/badge/RxSwift-6.5.0-orange">
    - <img src="https://img.shields.io/badge/SnapKit-5.6.0-skyblue">


### 구현 화면
|사진|더보기|영상|
|---|---|---|
|<img src="https://github.com/Allie-e/ShortFormFeed/assets/83864058/2685e510-5dbd-4e89-9a8d-cb8f4d6d580d" width="300">|<img src="https://github.com/Allie-e/ShortFormFeed/assets/83864058/c9aafd17-baa0-498a-b565-cd9c0f587eb4" width="300">|<img src="https://github.com/Allie-e/ShortFormFeed/assets/83864058/5cb99456-eba7-40a4-b530-f8dcb7cff48b" width="300">|

|동작 화면|
|:---:|
|<img src="https://i.imgur.com/MKKPND4.gif" width="300">|

### 구현 내용
- **UICollectionViewDiffableDataSource**
    - 데이터 변화에 따른 자연스러운 변화를 위해 적용했습니다.
- **CellReusable 프로토콜**
    - 프로토콜 기본구현을 통해 Cell의 등록과 재사용 과정을 간편하게 만들었습니다.
    - 기존 메서드에서의 String타입의 identifier없이 Cell의 class 명으로 identifier의 역할을 할 수 있도록 구현했습니다.
- **메모리 관리**
- ![](https://github.com/Allie-e/ShortFormFeed/assets/83864058/1bbf4372-7e3b-407d-be3a-d63f48db4ce2)
    - 동영상이 재생되고 다음 영상으로 넘어갈수록 메모리가 점점 올라가는 것을 방지하기 위한 메서드`cleanup()`를 구현했습니다.
- **MVVM**
    - MVVM 패턴을 적용하여 각 타입들의 역할을 명확히했습니다.
- **컨텐츠 가로스크롤**
    - 여러 컨텐츠가 포함된 포스트를 가로스크롤 하기위해 CollectionView를 사용했습니다.
- **상태에 따른 에러처리**
    - API 에러가 발생하는 경우, 다시 시도하기 버튼을 구현하여 재호출 하도록 했습니다.
    - 페이지네이션에 실패하는 경우 토스트 메세지를 이용하여 에러발생을 알리도록 했습니다.

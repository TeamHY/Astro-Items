local Descriptions = {}

Descriptions.collectibles = {
    [1] = {
        { text = "15초마다 빛줄기 10개 소환" },
        { text = "<warning>피격 시 20초간 효과 중지" },
    },
    [2] = {
        { text = "모든 변신세트 <color=0xFF3BF745>+1" },
        { text = "적에게 준 피해의 10%를 방 안의 모든 적에게 부여" },
    },
    [3] = {
        { text = "소울하트 <color=0xFF3BF745>+3" },
        { text = "피격 시 그 방에서 받는 피해량을 절반으로 감량" },
        { text = "2분마다 <color=0xFFC9FF00>I - 마술사?<color=0xFFFFFFFF> 발동" },
    },
    [4] = {
        { text = "공격에 독 효과 적용" },
        { text = "적 명중 시 30% 확률로 아군 독 파리 소환 <color=0xFFb9d27d>(행운 비례)" },
    },
    [5] = {
        { text = "연사 배율 <color=0xFF3BF745>x1.2" },
        { text = "공격력 <color=0xFF3BF745>+1.5" },
        { text = "악마/천사방/천체관 확률 <color=0xFF3BF745>증가" },
        { text = "악마방 구조 강화" },
        { text = "8층에서 천체관 등장 가능" },
    },
    [6] = {
        { text = "부정 알약 사용 시 공격력 <color=0xFF3BF745>+0.6<color=0xFFFFFFFF> 또는 블랙하트 1개 드롭" },
        { text = "피격 시 피해를 무시하고 10초간 무적" },
        { text = "<arrow><color=0xFF808080>(쿨타임 5초)" },
    },
    [7] = {
        { text = "장애물 파괴 가능, 바위 10개마다 스택이 누적됨" },
        { text = "<arrow>공격키를 2번 눌러 누적된 스택만큼 후두 충격파 발사" },
        { text = "방 입장 시 50% 확률로 적들이 석화됨" },
    },
    [8] = {
        { text = "빠른 속도로 적과 접촉 시 피격 없이 25의 접촉피해를 입힘" },
        { text = "보스방 입장 시 능력치가 증가하거나 공격이 적에 유도됨" },
    },
    [9] = {
        { text = "모든 적을 석화시키고 빛줄기를 남기는 돌진 가능" },
        { text = "<arrow>돌진 후 3초간 공격 불능 무적" },
    },
    [10] = {
        { text = "캐릭터가 공격력 x0.66의 피해를 주는 눈물 장판을 남김" },
        { text = "공격을 명중한 적에게서 눈물이 뿜어져 나옴" },
    },
    [11] = {
        { text = "랜덤 황금 장신구와 <color=0xFFC9FF00>꿀꺽!<color=0xFFFFFFFF> 드롭" },
        { text = "다음 게임에 랜덤 황금 장신구 1개 생성" },
    },
    [12] = {
        { text = "10초마다 <color=0xFFC9FF00>죽은 새<color=0xFFFFFFFF> 14마리 소환" },
        { text = "다음 게임에 <color=0xFFC9FF00>이브의 영혼<color=0xFFFFFFFF> 생성" },
    },
    [13] = {
        { text = "메가 사탄 체력 <color=0xFF3BF745>-10%" },
        { text = "그 외 모든 적 체력 <color=0xFF3BF745>-20%" },
    },
    [14] = {
        { text = "금이 간 열쇠 1개 드롭" },
        { text = "맵에 특급 비밀방 위치 표시" },
    },
    [15] = {
        { text = "연사 <color=0xFF3BF745>+0.5" },
        { text = "넉백 증가 더블 샷" },
        { text = "공격이 5% 확률로 일반 몬스터를 즉시 처치 <color=0xFFb9d27d>(행운 비례)" },
    },
    [16] = {
        { text = "<color=0xFFC9FF00>검은 거울<color=0xFFFFFFFF> 장신구 드롭" },
        { text = "적들을 쫓아 공격력 x1 +65의 접촉피해를 입히는 패밀리어" },
        { text = "방 입장 시 소지한 패밀리어 복제" },
    },
    [18] = {
        { text = "공격력 배율 <color=0xFF3BF745>x1.35" },
        { text = "<warning>항상 어둠의 저주에 걸림" },
        { text = "모든 모닥불 소화" },
    },
    [19] = {
        { text = "<warning>일회용" },
        { text = "보스방 보상으로 소지중인 아이템 1개와 천사방 아이템 2개(양자택일) 소환" },
    },
    [20] = {
        { text = "방 클리어 시:" },
        { text = "<indent>연사 <color=0xFF3BF745>+0.02" },
        { text = "<indent>공격력 <color=0xFF3BF745>+0.02" },
    },
    [21] = {
        { text = "25% 확률로 눈물에 초당 60의 피해를 주는 오라 생성" },
    },
    [22] = {
        { text = "<color=0xFFC9FF00>실종 포스터<color=0xFFFFFFFF> 장신구 드롭" },
        { text = "다음 게임에 하얀 모닥불 생성" },
    },
    [23] = {
        { text = "다음 게임에서 애프터버스 변종 스테이지 미등장" },
        { text = "<arrow>챔피언 적이 받는 피해량 1.3배" },
    },
    [24] = {
        { text = "획득 시 <color=0xFFC9FF00>책가방<color=0xFFFFFFFF>/<color=0xFFC9FF00>배꼽<color=0xFFFFFFFF>/<color=0xFFC9FF00>다지증<color=0xFFFFFFFF> 중 1개 선택 가능" },
        { text = "다음 게임에 <color=0xFFC9FF00>안수즈<color=0xFFFFFFFF> 생성" },
    },
    [25] = {
        { text = "공격력 배율 <color=0xFF3BF745>x1.25" },
        { text = "50% 확률로 공격이 적에게 유도됨" },
    },
    [26] = {
        { text = "QuickPick 사거리 무제한" },
    },
    [27] = {
        { text = "<warning>소지중인 천체관 아이템을 모두 제거하고 제거한 만큼 랜덤 천체관 아이템 소환" },
    },
    [28] = {
        { text = "눈물 주위에 공격력 x0.5의 작은 눈물이 공전" },
    },
    [29] = {
        { text = "연사(+상한) <color=0xFF3BF745>+0.7" },
    },
    [30] = {
        { text = "<color=0xFFC9FF00>검은 룬<color=0xFFFFFFFF> 1개 드롭" },
        { text = "사용 시 <color=0xFFC9FF00>검은 룬<color=0xFFFFFFFF> 효과 발동" },
    },
    [32] = {
        { text = "0~1퀄리티 아이템 미등장" },
    },
    [33] = {
        { text = "<warning>보스방 클리어 시 <color=0xFFFFFF87>정신<color=0xFFFFFFFF>, <color=0xFFFF8080>신체<color=0xFFFFFFFF>, <color=0xFFC8C8FF>영혼<color=0xFFFFFFFF> 제거" },
        { text = "<warning>스테이지 진입 시 소지 아이템 1개 제거 후 제거된 아이템/<color=0xFFFFFF87>정신<color=0xFFFFFFFF>/<color=0xFFFF8080>신체<color=0xFFFFFFFF>/<color=0xFFC8C8FF>영혼<color=0xFFFFFFFF> 중 택1" },
    },
    [34] = {
        { text = "블랙하트 <color=0xFF3BF745>+1" },
        { text = "방 입장 시 12.5% 확률로 적들을 출혈시킴 <color=0xFFb9d27d>(행운 비례)" },
    },
    [35] = {
        { text = "적 명중 시 10% 확률로 빛줄기 소환 <color=0xFFb9d27d>(행운 비례)" },
    },
    [36] = {
        { text = "방에 입장 시 적들을 8초간 둔화" },
    },
    [37] = {
        { text = "목숨 <color=0xFF3BF745>+1" },
        { text = "부활 시 모든 능력치 <color=0xFF3BF745>x1.1" },
        { text = "다음 게임에 랜덤 부활 아이템 1개 생성" },
    },
    [38] = {
        { text = "확률적으로 접착 눈물 발사 <color=0xFFb9d27d>(행운 비례)" },
    },
    [39] = {
        { text = "<warning>일회용" },
        { text = "사용 시 천체관으로 순간이동" },
        { text = "<arrow>천체관에는 글리치 머신과 <color=0xFFC9FF00>망원경 렌즈<color=0xFFFFFFFF> 존재" },
    },
    [40] = {
        { text = "소지중인 공격 방식 교체형 아이템을 모두 제거 및 드롭" },
    },
    [41] = {
        { text = "행운 <color=0xFF3BF745>+1" },
        { text = "행운 1당 공격력 <color=0xFF3BF745>+1%p" },
    },
    [42] = {
        { text = "보스가 받는 피해량 1.3배" },
    },
    [43] = {
        { text = "맵에 랜덤 방 2개의 위치 표시 <color=0xFFb9d27d>(행운 비례)" },
    },
    [44] = {
        { text = "적에게 준 피해의 10%만큼 방 안의 모든 몬스터에게 부여" },
    },
    [45] = {
        { text = "적 처치 시 블랙홀 소환" },
        { text = "<arrow><color=0xFFC8C8C8>방당 1회 한정" },
        { text = "방 클리어 시 10초간 무적" },
    },
    [46] = {
        { text = "사용 시 방 안의 모든 아이템/픽업을 리롤" },
        { text = "<arrow>아이템은 랜덤 배열로 리롤" },
    },
    [47] = {
        { text = "<warning>스테이지 진입 시 소지 아이템 1개와 모든 오브 아이템을 제거하고 제거된 아이템과 랜덤 오브 아이템 양자택일" },
    },
    [48] = {
        { text = "공격이 적을 관통함" },
        { text = "<arrow>관통한 눈물은 적에게 유도됨" },
        { text = "적들이 받는 피해량 1.2배 <color=0xFFb9d27d>(행운 비례)" },
    },
    [49] = {
        { text = "사용 시 그 다음 방까지 <color=0xFFC9FF00>탐험가 모자<color=0xFFFFFFFF>/<color=0xFFC9FF00>보라 양초<color=0xFFFFFFFF> 효과 부여" },
    },
    [50] = {
        { text = "공격력 <color=0xFF3BF745>+3.5" },
    },
    [51] = {
        { text = "공격력 <color=0xFF3BF745>+0.35" },
        { text = "9개의 방마다 랜덤 능력치 <color=0xFF3BF745>+0.35" },
    },
    [52] = {
        { text = "상자 등장 시 33% 확률로 1개 더 등장" },
    },
    [53] = {
        { text = "방 클리어 시 그 스테이지에서 랜덤 능력치 <color=0xFF3BF745>+0.7<color=0xFFC8C8C8> (최대 10회)" },
    },
    [54] = {
        { text = "열쇠 1개당 공격력 <color=0xFF3BF745>+0.16" },
    },
    [55] = {
        { text = "폭탄 1개당 공격력 <color=0xFF3BF745>+0.16" },
    },
    [56] = {
        { text = "<warning>일회용" },
        { text = "사용 시 30% 확률로 그 방의 아이템 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow>실패 시 브로큰하트 <color=0xFFF7513B>+3" },
    },
    [57] = {
        { text = "모든 알약이 <color=0xFF00FFFF>말<color=0xFFFFFFFF>약으로 대체됨" },
        { text = "미사용 알약 식별 가능" },
    },
    [58] = {
        { text = "알약이 <color=0xFFC9FF00>꿀꺽!<color=0xFFFFFFFF>과 능력치 관련 효과만 등장" },
    },
    [59] = {
        { text = "맵에 스테이지 중심 5x5의 방을 표시" },
        { text = "숨어 있는 적을 친화적으로 바꿈" },
    },
    [60] = {
        { text = "<warning>일회용, 비밀방에서 사용 불가" },
        { text = "방 클리어 시 20% 확률로 스택 증가 <color=0xFFb9d27d>(행운 비례)" },
        { text = "사용 시 누적 스택만큼 공격 교체형 아이템 소환 (택1)" },
    },
    [61] = {
        { text = "스테이지 진입 시 소지 아이템 1개를 제거하고 제거된 아이템과 <color=0xFFC9FF00>서큐버스<color=0xFFFFFFFF> 양자택일" },
        { text = "<warning><color=0xFFC9FF00>서큐버스<color=0xFFFFFFFF> 4개 이상 소지 시 미발동" },
    },
    [62] = {
        { text = "0~1퀄리티 아이템을 20% 확률로 정신류 아이템으로 리롤" },
        { text = "정신류 아이템 효과 2배" },
    },
    [64] = {
        { text = "황금방 아이템 3개 소환" },
        { text = "<arrow>하나만 선택 가능" },
    },
    [65] = {
        { text = "모든 아이템 양자택일 가능" },
    },
    [66] = {
        { text = "공격력을 항상 가장 높았던 값으로 고정" },
    },
    [67] = {
        { text = "연사를 항상 가장 높았던 값으로 고정" },
    },
    [68] = {
        { text = "행운을 항상 가장 높았던 값으로 고정" },
    },
    [69] = {
        { text = "적 명중 시 20% 확률로 연옥 유령 소환 <color=0xFFb9d27d>(행운 비례)" },
    },
    [70] = {
        { text = "적 명중 시 20% 확률로 여러 유령 소환 <color=0xFFb9d27d>(행운 비례)" },
    },
    [71] = {
        { text = "30% 확률로 접촉 씨앗 발사 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow>씨앗은 2초 공격력 x6 +35의 폭발 피해를 입힘" },
    },
    [72] = {
        { text = "파란 파리 소환량 2배" },
    },
    [73] = {
        { text = "<color=0xFFC9FF00>정복의 메뚜기<color=0xFFFFFFFF> 장신구 드롭" },
        { text = "적 처치 시 파란 파리 소환" },
    },
    [74] = {
        { text = "액티브 사용 시 충전량 1칸당 공격력 <color=0xFF3BF745>+1<color=0xFFC8C8C8> (최대 +5)" },
    },
    [75] = {
        { text = "체력 증가와 같이 더 로스트에게 불필요한 아이템 미등장" },
    },
    [76] = {
        { text = "모든 능력치 배율 <color=0xFF3BF745>증<color=0xFFF7513B>감" },
    },
    [77] = {
        { text = "안 돼." },
    },
    [78] = {
        { text = "적 명중 시 12방향으로 초당 공격력 x10.5의 광선 발사 <color=0xFFb9d27d>(행운 비례)" },
    },
    [79] = {
        { text = "<warning>스테이지당 1번 사용 가능" },
        { text = "사용 시:" },
        { text = "<indent>행운 <color=0xFFF7513B>-2" },
        { text = "<indent><color=0xFFC9FF00>검은 거울<color=0xFFFFFFFF> 장신구 소환" },
    },
    [80] = {
        { text = "소지중일 때 적 처치 시 적의 영혼을 2개까지 저장" },
        { text = "사용 시 영혼을 모두 소모하고 여러 유령 소환" },
    },
    [81] = {
        { text = "연사 배율 <color=0xFFF7513B>x0.8" },
        { text = "눈물에 50% 확률로 프레임당 공격력 x1의 피해를 주는 레이저 고리 생성 <color=0xFFb9d27d>(행운 비례)" },
    },
    [83] = {
        { text = "<warning>일회용, <color=0xFF696969>？<color=0xFFFFFFFF>에서만 가능" },
        { text = "사용 시 소지중인 3~4퀄리티 아이템 3개 소환" },
        { text = "<arrow>하나만 선택 가능" },
    },
    [84] = {
        { text = "<warning>스테이지당 1번, <color=0xFF696969>？<color=0xFFFFFFFF>에서만 가능" },
        { text = "사용 시 소지 아이템 1개 제거 후 제거된 아이템과 침실 아이템 2개 소환" },
        { text = "<arrow>하나만 선택 가능" },
    },
    [85] = {
        { text = "사용 시 보물방·천사방·비밀방 아이템 소환" },
        { text = "<arrow>하나만 선택 가능" },
    },
    [86] = {
        { text = "책 액티브 사용 시 효과 영구 유지" },
    },
    [87] = {
        { text = "클리어한 방에서 이동속도 <color=0xFF3BF745>+2" },
        { text = "클리어하지 않은 방에서 이동속도 <color=0xFFF7513B>-0.3" },
    },
    [88] = {
        { text = "소지중일 때:" },
        { text = "<indent><color=0xFFC9FF00>모르핀<color=0xFFFFFFFF> 효과 적용" },
        { text = "<indent>적 처치 시 영혼 저장, 적 명중 시 영혼 1개당 1%p 추가 피해" },
        { text = "방 클리어 시 영혼 5개 감소" },
    },
    [89] = {
        { text = "소지중일 때:" },
        { text = "<indent><color=0xFFC9FF00>YO, 리슨!<color=0xFFFFFFFF> 효과 적용" },
        { text = "<indent>적 처치 시 영혼 저장, 적 명중 시 영혼 1개당 1%p 추가 피해" },
        { text = "방 클리어 시 영혼 5개 감소" },
    },
    [90] = {
        { text = "<color=0xFFC9FF00>굶주린 영혼<color=0xFFFFFFFF>·<color=0xFFC9FF00>연옥<color=0xFFFFFFFF>·<color=0xFFC9FF00>유령 폭탄<color=0xFFFFFFFF> 효과 적용" },
        { text = "소환하는 유령들의 속도 2배" },
    },
    [91] = {
        { text = "스테이지 진입 시 <color=0xFFC9FF00>고기조각<color=0xFFFFFFFF> 1개 획득" },
    },
    [92] = {
        { text = "사용 시 <color=0xFFC9FF00>버섯 모자<color=0xFFFFFFFF>+<color=0xFFC9FF00>유체이탈<color=0xFFFFFFFF> 효과 발동" },
    },
    [93] = {
        { text = "<warning>일회용" },
        { text = "숫자 8키로 메인 액티브와 카드/알약 슬롯 액티브 자리 교체" },
    },
    [94] = {
        { text = "<warning>예측 불허." },
    },
    [95] = {
        { text = "샴쌍둥이 변신세트 적용" },
    },
    [96] = {
        { text = "사용 시 방 안의 아이템을 모두 이후 ID의 아이템으로 리롤" },
    },
    [97] = {
        { text = "<warning>일회용" },
        { text = "사용 시 <color=0xFFC9FF00>양초<color=0xFFFFFFFF> 또는 <color=0xFFC9FF00>붉은 양초<color=0xFFFFFFFF> 소환" },
    },
    [98] = {
        { text = "대각선으로 이동 시 이동속도 <color=0xFF3BF745>+0.3" },
    },
    [99] = {
        { text = "사용 시 방 안의 모든 아이템을 소지중인 아이템으로 리롤" },
        { text = "<arrow>0~1퀄리티 아이템은 미등장" },
    },
    [100] = {
        { text = "사용 시 동전 10개를 소모하고 아래 옵션 중 2가지 적용:" },
        { text = "<indent>공격력 <color=0xFF3BF745>+1%p~+50%p" },
        { text = "<indent>보스 피해량 +1%p~+50%p" },
        { text = "<indent>몬스터 피해량 +1%p~+50%p" },
    },
    [101] = {
        { text = "사용 시 동전 5개를 소모하고 아래 옵션 중 하나 적용:" },
        { text = "<indent>공격력 <color=0xFF3BF745>+1%p~+25%p" },
        { text = "<indent>보스 피해량 +1%p~+25%p" },
        { text = "<indent>몬스터 피해량 +1%p~+25%p" },
    },
    [102] = {
        { text = "<warning>일회용" },
        { text = "사용 시 캐릭터를 디아벨스타로 변경" },
    },
    [103] = {
        { text = "1초마다 공격력 <color=0xFF3BF745>+0.008" },
        { text = "피격 시 1분간 효과 중지" },
    },
    [104] = {
        { text = "1초마다 이동속도 <color=0xFF3BF745>+0.0001" },
        { text = "피격 시 1분간 효과 중지" },
    },
    [105] = {
        { text = "1초마다 연사 <color=0xFF3BF745>+0.0002" },
        { text = "피격 시 1분간 효과 중지" },
    },
    [106] = {
        { text = "1초마다 행운 <color=0xFF3BF745>+0.01" },
        { text = "피격 시 1분간 효과 중지" },
    },
    [107] = {
        { text = "사용 시 방 안의 모든 아이템을 정신류 아이템으로 리롤" },
    },
    [108] = {
        { text = "<color=0xFFFF8000>맵에 표시된<color=0xFFFFFFFF> 보스방 클리어 시:" },
        { text = "<indent><color=0xFFC9FF00>태양<color=0xFFFFFFFF> 효과 발동" },
        { text = "<indent><color=0xFFC9FF00>신조<color=0xFFFFFFFF> 획득" },
        { text = "<indent>랜덤 장신구 1개 드롭" },
    },
    [109] = {
        { text = "<color=0xFFC9FF00>달<color=0xFFFFFFFF>, <color=0xFFC9FF00>투시 안경<color=0xFFFFFFFF> 효과 적용" },
        { text = "맵에 ？<color=0xFF696969>？<color=0xFF9F0000>？<color=0xFFFFFFF>위치 표시" },
    },
    [110] = {
        { text = "이동속도 <color=0xFF3BF745>+0.4" },
        { text = "클리어하지 않은 방의 문이 항상 열림 <color=0xFFC8C8C8>(특수방 제외)" },
        { text = "방 클리어 시 50% 확률로 <color=0xFFC9FF00>카인의 영혼<color=0xFFFFFFFF> 효과 발동" },
    },
    [111] = {
        { text = "최대 체력 <color=0xFF3BF745>+1" },
        { text = "빨간하트 <color=0xFF3BF745>+1" },
        { text = "항상 근처 적들을 매혹함" },
        { text = "매혹된 적이 받는 피해량 1.5배" },
    },
    [112] = {
        { text = "방 입장 시 공격력 배율 <color=0xFF3BF745>x1.1~x1.5" },
        { text = "<color=0xFFC9FF00>지구<color=0xFFFFFFFF> 효과 적용" },
        { text = "방 클리어 시 <color=0xFFC9FF00>하갈라즈<color=0xFFFFFFFF> 발동" },
    },
    [113] = {
        { text = "<color=0xFFC9FF00>화성<color=0xFFFFFFFF> 효과 적용" },
        { text = "피격 시 방마다 한 번 피해를 무시하고 즉시 돌진" },
    },
    [114] = {
        { text = "획득 시 <color=0xFFC9FF00>XV - 악마?<color=0xFFFFFFFF> 효과 발동" },
        { text = "<color=0xFFC9FF00>목성<color=0xFFFFFFFF>, <color=0xFFC9FF00>목성<color=0xFFFFFFFF> 효과 적용" },
        { text = "5초마다 피해를 입지 않고 '피격 시 효과'를 발동함" },
    },
    [115] = {
        { text = "<color=0xFFC9FF00>토성<color=0xFFFFFFFF> 효과 적용" },
        { text = "10초마다 3초간 주변의 투사체를 붙잡은 후 반사" },
    },
    [116] = {
        { text = "적 처치 시 적이 얼어붙음" },
        { text = "캐릭터에게 적을 둔화시키는 오라가 생김" },
    },
    [117] = {
        { text = "방을 클리어 시 그 스테이지에서 연사 <color=0xFF3BF745>+0.05" },
        { text = "공격을 하지 않을 때 눈물을 충전함" },
    },
    [118] = {
        { text = "연사 <color=0xFF3BF745>+0.7" },
        { text = "캐릭터 크기 대폭 감소" },
        { text = "방 입장 시 5초간 방 안의 적들을 밟아 죽일 수 있음" },
    },
    [119] = {
        { text = "<warning>스테이지당 1번, <color=0xFF696969>？<color=0xFFFFFFFF>에서만 가능" },
        { text = "사용 시:" },
        { text = "<indent>행운 <color=0xFFF7513B>-1" },
        { text = "<indent>소지중인 아이템 1개와 3~4퀄리티 아이템 1개 소환" },
        { text = "<indent><arrow>하나만 선택 가능" },
    },
    [120] = {
        { text = "사용 시 빈 아이템 받침대에 그 방의 아이템 생성" },
    },
    [121] = {
        { text = "사용 시 방 안의 모든 아이템을 2~4퀄리티 아이템으로 리롤" },
        { text = "<arrow>2퀄리티 아이템 등장 시 20% 확률로 리롤" },
    },
    [122] = {
        { text = "사용 시 방 안의 모든 아이템을 그 방의 패시브로 리롤" },
    },
    [123] = {
        { text = "사용 시 황금 장신구 1개 소환" },
    },
    [124] = {
        { text = "상자를 열 때마다:" },
        { text = "<indent>랜덤 능력치 <color=0xFF3BF745>+0.05" },
        { text = "<indent>40% 확률로 상자 1개 소환" },
    },
    [125] = {
        { text = "적 처치 시 방마다 한 번 3초간 주변의 투사체를 붙잡은 후 반사" },
    },
    [126] = {
        { text = "증발성 연사 <color=0xFF3BF745>+21.6" },
        { text = "<arrow>증발 도중 적 처치 시 연사 +0.12 회복" },
    },
    [127] = {
        { text = "증발성 행운 <color=0xFF3BF745>+21.6" },
        { text = "<arrow>증발 도중 적 처치 시 행운 +0.12 회복" },
    },
    [128] = {
        { text = "증발성 이동속도 <color=0xFF3BF745>+1.08" },
        { text = "<arrow>증발 도중 적 처치 시 이동속도 +0.006 회복" },
    },
    [129] = {
        { text = "<warning>스테이지당 최대 2번 발동 가능" },
        { text = "방 입장 시 그 방의 적 1마리가 이번 게임에서 영원히 미등장" },
    },
    [130] = {
        { text = "<color=0xFF3BF745>모든 능력치 배율 증가" },
    },
    [131] = {
        { text = "<warning>일회용" },
        { text = "사용 시 방 안의 별 아이템을 모두 업그레이드" },
    },
    [132] = {
        { text = "명중한 적 주위에 눈물이 돌며;" },
        { text = "<arrow>일정량 이상 명중 시 눈물이 적을 공격함" },
    },
    [133] = {
        { text = "방마다 캐릭터 색 변경" },
        { text = "<arrow>캐릭터 색에 따라 능력치 증가:" },
        { text = "<indent><color=0xFFFF8080>빨강<color=0xFFFFFFFF>: 공격력 배율 <color=0xFF3BF745>x1.4" },
        { text = "<indent><color=0xFF80FF80>초록<color=0xFFFFFFFF>: 행운 배율 <color=0xFF3BF745>x1.5" },
        { text = "<indent><color=0xFF8080FF>파랑<color=0xFFFFFFFF>: 연사 배율 <color=0xFF3BF745>x1.2" },
    },
    [134] = {
        { text = "50% 확률로 적 명중 시 태아로 변하는 눈물 발사 <color=0xFFb9d27d>(행운 비례)" },
        { text = "태아는 유도 + 적/지형 관통" },
        { text = "<arrow><color=0xFFC8C8C8>피해량: 8프레임당 공격력 x1" },
    },
    [135] = {
        { text = "5초마다 랜덤 유령 1마리를 소환하는 패밀리어" },
    },
    [136] = {
        { text = "<warning>적에게 피해를 주면 충전됨" },
        { text = "사용 시 10초간 무적 + 블랙홀 소환" },
    },
    [137] = {
        { text = "피격으로 인해 <color=0xFFC9FF00>올백<color=0xFFFFFFFF>이 떨궈질 때 다시 주울 수 있음" },
        { text = "<arrow>스테이지당 1번 가능" },
    },
    [138] = {
        { text = "공격 시 1% 확률로 <color=0xFFC9FF00>리틀 스티븐<color=0xFFFFFFFF> 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow><color=0xFFC8C8C8>최대 5마리" },
    },
    [139] = {
        { text = "방 클리어 시 20% 확률로 마이크로 배터리를 드롭하는 패밀리어" },
    },
    [140] = {
        { text = "사용 시 방 안의 모든 아이템을 1~3번 앞의 ID나 1~3번 뒤의 ID의 아이템으로 리롤" },
    },
    [141] = {
        { text = "연사 <color=0xFF3BF745>+0.25" },
        { text = "2초마다 4방향으로 공격력 x0.5의 유도 눈물 발사" },
    },
    [142] = {
        { text = "적 명중 시 진드기 소환" },
        { text = "<arrow>진드기는 적들을 쫓아 초당 공격력 x4의 접촉피해를 입힘" },
    },
    [143] = {
        { text = "<color=0xFFC9FF00>바빌론의 창녀<color=0xFFFFFFFF>와 <color=0xFFC9FF00>죽은 새<color=0xFFFFFFFF> 효과 항시 발동" },
    },
    [144] = {
        { text = "소울하트 <color=0xFF3BF745>+2" },
        { text = "소울하트 획득량 2배" },
    },
    [145] = {
        { text = "도박 시 25% 확률로 동전을 소모하지 않음" },
        { text = "슬롯머신/야바위 거지를 글리치 머신/인형 뽑기로 대체" },
    },
    [146] = {
        { text = "클리어하지 않은 방에서 4초마다 공격력 185의 폭발을 일으킴" },
    },
    [147] = {
        { text = "<warning>페널티 피격 시 소멸" },
        { text = "피격 시 방마다 한 번 피해를 무시함 <color=0xFFC8C8C8>(헌혈 제외)" },
    },
    [148] = {
        { text = "<color=0xFFC9FF00>???의 영혼<color=0xFFFFFFFF> 장신구 드롭" },
        { text = "보스방 클리어 시 <color=0xFFC9FF00>리틀 스티븐<color=0xFFFFFFFF> 1마리 획득 <color=0xFFC8C8C8>(최대 4마리)" },
    },
    [149] = {
        { text = "클리어하지 않은 방 입장 시 무저갱 메뚜기 3마리 소환" },
    },
    [150] = {
        { text = "사용 시 <color=0xFFC9FF00>생득권<color=0xFFFFFFFF> 1개 획득" },
        { text = "획득 시/스테이지 진입 시:" },
        { text = "<indent>소지중인 아이템과 능력치를 모두 리롤" },
    },
    [151] = {
        { text = "블랙하트 <color=0xFF3BF745>+1" },
        { text = "악마/천사방 확률 <color=0xFF3BF745>+15%" },
        { text = "저주로부터 면역" },
        { text = "가려진 아이템 식별 가능" },
        { text = "모든 보라 모닥불 소화" },
    },
    [152] = {
        { text = "연사 <color=0xFFF7513B>-0.3" },
        { text = "공격력 <color=0xFF3BF745>+0.5" },
        { text = "탄속 <color=0xFFF7513B>-0.3" },
        { text = "공격이 적에게 유도됨" },
        { text = "눈물에 초당 공격력 x0.3의 피해를 주는 원광이 생김" },
    },
    [153] = {
        { text = "<color=0xFFC9FF00>성스러운 심장<color=0xFFFFFFFF> 효과 적용" },
        { text = "적들이 받는 피해량 2.3배" },
    },
    [154] = {
        { text = "사용 시 동전 5개를 소모하고 아래 옵션 중 2가지 적용:" },
        { text = "<indent>공격력 <color=0xFF3BF745>+1%p~+25%p" },
        { text = "<indent>보스 피해량 +1%p~+25%p" },
        { text = "<indent>몬스터 피해량 +1%p~+25%p" },
    },
    [155] = {
        { text = "스테이지 진입 시 50% 확률로 구피 세트 <color=0xFF3BF745>+1" },
    },
    [156] = {
        { text = "스테이지 진입 시 소멸" },
    },
    [157] = {
        { text = "능력치가 아이작의 기본 능력치보다 낮아지지 않음" },
    },
    [158] = {
        { text = "사용 시 모든 0~2퀄리티 아이템 중 1개를 획득할 수 있는 곳으로 순간이동" },
    },
    [159] = {
        { text = "0~2퀄리티 아이템 등장 시 20% 확률로 리롤" },
    },
    [160] = {
        { text = "사용 시 <color=0xFF9F0000>？<color=0xFFFFFFF>아이템 중 1개를 얻을 수 있는 곳으로 순간이동" },
    },
    [161] = {
        { text = "사용 시 방 안의 아이템을 변신세트 아이템으로 리롤" },
    },
    [162] = {
        { text = "새 층을 시작할 때마다 밴드 덩어리를 얻습니다" },
    },
    [163] = {
        { text = "사용 시 소지중인 아이템 중 1개를 획득할 수 있는 곳으로 순간이동" },
    },
    [164] = {
        { text = "공격 중 폭탄 설치 시 기가 로켓이 공격방향으로 발사됨" },
    },
    [165] = {
        { text = "기가 폭탄 10개 드롭" },
    },
    [166] = {
        { text = "소지중일 때 적 명중 시 10초 후 사라지는 끈적이 니켈 드롭" },
        { text = "사용 시 끈적이 니켈을 점화된 폭탄으로 변환" },
    },
    [167] = {
        { text = "개발 중 (WIP)" },
    },
    [168] = {
        { text = "공격력 <color=0xFF3BF745>+1" },
        { text = "<color=0xFFC9FF00>공허의 구렁텅이<color=0xFFFFFFFF> 효과 적용" },
        { text = "<arrow>고리로 적 처치 시 10% 확률로 블랙하트 1개 드롭" },
    },
    [169] = {
        { text = "동전/폭탄/열쇠/빨간하트 픽업이 1+1으로 등장" },
    },
    [170] = {
        { text = "방 중앙에서 소환되어 보스방으로 직행하는 오라" },
        { text = "<arrow>오라 안에 서 있을 시:" },
        { text = "<indent>연사 배율 <color=0xFF3BF745>x2.5" },
        { text = "<indent>공격력 배율 <color=0xFF3BF745>x1.2" },
        { text = "<indent>공격이 적에게 유도됨" },
    },
    [171] = {
        { text = "사용 시 그 자리에 다락문 생성" },
        { text = "<arrow>치장성 타일 위에 사용 시 <color=0xFFC9FF00>멤버십 카드<color=0xFFFFFFFF> 상점 생성" },
    },
    [172] = {
        { text = "15초마다/적 처치 시 노란 장판 생성" },
        { text = "<arrow><color=0xFFC8C8C8>피해량: 초당 24" },
    },
    [173] = {
        { text = "빈 최대 체력 <color=0xFF3BF745>+3" },
        { text = "음식 아이템 미등장" },
    },
    [174] = {
        { text = "<color=0xFFC9FF00>죽음의 살생부<color=0xFFFFFFFF> 효과 적용" },
        { text = "방 입장 시 랜덤 적에게 유황 표식 추가" },
    },
    [175] = {
        { text = "공격키를 누르는 동안 공격력 증가 (<color=0xFF3BF745>최대 x1.5<color=0xFFFFFFFF>)" },
    },
    [176] = {
        { text = "소지중일 때 적 처치 시 10% 확률로 불꽃 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "사용 시:" },
        { text = "<indent>그 방의 적 1마리 화상" },
        { text = "<indent><color=0xFFC9FF00>XIX - 태양<color=0xFFFFFFFF> 드롭 <color=0xFFC8C8C8>(처음 한정)" },
    },
    [177] = {
        { text = "？<color=0xFF696969>？<color=0xFF9F0000>？<color=0xFFFFFFF>속 달빛과 접촉 시 소울하트/그 스테이지에서 연사(+상한) <color=0xFF3BF745>+0.5" },
        { text = "사용 시:" },
        { text = "<indent>방 중앙에 달빛 생성" },
        { text = "<indent><color=0xFFC9FF00>XVIII - 달<color=0xFFFFFFFF> 드롭 <color=0xFFC8C8C8>(처음 한정)" },
    },
    [178] = {
        { text = "소지중일 때 적 처치 시 10% 확률로 불꽃 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "사용 시:" },
        { text = "<indent>그 방의 적 1마리 화상" },
        { text = "<indent><color=0xFFC9FF00>XIX - 태양?<color=0xFFFFFFFF> 드롭 <color=0xFFC8C8C8>(처음 한정)" },
    },
    [179] = {
        { text = "？<color=0xFF696969>？<color=0xFF9F0000>？<color=0xFFFFFFF>속 달빛과 접촉 시 소울하트/그 스테이지에서 연사(+상한) <color=0xFF3BF745>+0.5" },
        { text = "사용 시:" },
        { text = "<indent>방 중앙에 달빛 생성" },
        { text = "<indent><color=0xFFC9FF00>XVIII - 달?<color=0xFFFFFFFF> 드롭 <color=0xFFC8C8C8>(처음 한정)" },
    },
    [180] = {
        { text = "새 층마다 시작방에 특별한 악마방으로 이어지는 사다리를 생성합니다" },
        { text = "사다리는 시작방을 나가면 사라집니다" },
    },
    [181] = {
        { text = "<warning>일회용" },
        { text = "소지중일 때 목숨 <color=0xFF3BF745>+1" },
        { text = "사용 시 조우한 아이템 중 소지하지 않은 아이템 1개 소환" },
    },
    [182] = {
        { text = "3% 확률로 <color=0xFFC9FF00>안락사<color=0xFFFFFFFF> 공격 발사 <color=0xFFb9d27d>(행운 비례)" },
    },
    [183] = {
        { text = "방 클리어 시 25% 확률로 랜덤 픽업을 드롭하는 패밀리어" },
        { text = "5개의 방마다 장신구 1개 드롭" },
    },
    [184] = {
        { text = "공격력 배율 <color=0xFF3BF745>x1.5" },
    },
    [185] = {
        { text = "소지중일 때 연사 <color=0xFF3BF745>+0.5" },
        { text = "사용 시 그 방에서 연사 <color=0xFF3BF745>+2" },
    },
    [186] = {
        { text = "랜덤 카드 1개 드롭" },
        { text = "카드 효과 2배 및 영구 유지" },
    },
    [187] = {
        { text = "사용 시 방 안의 모든 아이템이 오지선다로 빠르게 순환함" },
    },
    [188] = {
        { text = "사용 후 공격방향으로 초당 공격력 x60의 광선 발사" },
    },
    [189] = {
        { text = "방 클리어 시 그 방의 바위를 모두 파괴" },
    },
    [190] = {
        { text = "스테이지 진입 시 30원을 소모하고 천체관으로 이동 가능" },
    },
    [191] = {
        { text = "보물방에 IBN 5100 생성" },
        { text = "<arrow>IBN 5100은 10원을 소모하고 그 방에서 발생한 모든 일을 취소" },
    },
    [192] = {
        { text = "클리어하지 않은 방 입장 시:" },
        { text = "<indent>연사 배율 <color=0xFF3BF745>x5.5" },
        { text = "<indent>공격력 배율 <color=0xFFF7513B>x0.2" },
        { text = "<indent>눈물 크기 <color=0xFFF7513B>-0.3" },
        { text = "<indent>충전형 공격이 바로 발사됨" },
    },
    [193] = {
        { text = "1+1 행운의 동전 1개 드롭" },
        { text = "행운의 동전이 1+1으로 등장" },
    },
    [194] = {
        { text = "모든 정방향 카드를 역방향 카드로 대체" },
    },
    [195] = {
        { text = "캐릭터 주변에 프레임당 공격력 x1의 접촉피해를 주는 삼각 레이저를 두름" },
    },
    [196] = {
        { text = "폭탄 <color=0xFF3BF745>+5" },
        { text = "폭탄을 설치하지 않고 투척" },
    },
    [197] = {
        { text = "<warning>스테이지당 1번 사용 가능" },
        { text = "사용 후 <color=0xFFE80000>♥<color=0xFFFFFFFF> 또는 <color=0xFF6175A3>♥♥<color=0xFFFFFFFF>를 브로큰하트 1칸으로 바꾸고 공격방향으로 편지 발사" },
        { text = "<arrow>편지에 맞은 몬스터는 이번 게임에서 아군으로 등장" },
    },
    [198] = {
        { text = "페널티 피격 시 50% 확률로 그 방에서 발생한 모든 일을 취소<color=0xFFb9d27d>(행운 비례)" },
    },
    [199] = {
        { text = "공격력이 적의 체력보다 높으면 해당 적이 이번 게임에서 영원히 미등장" },
    },
    [200] = {
        { text = "2분마다 <color=0xFFC9FF00>서큐버스<color=0xFFFFFFFF> 패밀리어 소환 (최대 10마리)" },
    },
    [201] = {
        { text = "파란 파리 소환 시 50% 확률로 뼈 파리 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow>뼈 파리는 적과 접촉 시 4방향으로 뼈 눈물 발사" },
    },
    [202] = {
        { text = "파란 파리 소환 시 50% 확률로 1마리 더 소환 <color=0xFFb9d27d>(행운 비례)" },
    },
    [203] = {
        { text = "파란 파리 소환 시 50% 확률로 황금 파리 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow>황금 파리는 <color=0xFFC9FF00>미다스의 손길<color=0xFFFFFFFF> 효과를 가짐" },
    },
    [204] = {
        { text = "파란 파리 소환 시 50% 확률로 유황 파리 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow>유황 파리는 적과 접촉 시 최대 공격력 x22의 소용돌이 소환" },
    },
    [205] = {
        { text = "파란 파리 소환 시 50% 확률로 신성한 파리 소환 <color=0xFFb9d27d>(행운 비례)" },
        { text = "<arrow>신성한 파리는 적과 접촉 시 최대 공격력 x22의 소용돌이 소환" },
    },
    [206] = {
        { text = "사용 시 퀄리티를 선택 후;" },
        { text = "<arrow>그 퀄리티의 패시브를 모두 리롤" },
    },
    [207] = {
        { text = "사용 시 5가지의 리롤 효과 중 하나 발동 가능" },
    },
    [208] = {
        { text = "사용 시 능력치를 선택 후;" },
        { text = "<arrow>그 능력치 배율을 리롤 <color=0xFFC8C8C8>(x1~x2)" },
    },
    [209] = {
        { text = "보스방 클리어 시 황금 장신구 3개 드롭" },
        { text = "Ctrl 키를 눌러 소지중인 장신구 흡수 및 그 방의 장신구 황금화" },
    },
    [210] = {
        { text = "모든 변신세트 효과 강화" },
        { text = "스테이지당 1번 방 안의 모든 아이템을 변신세트 아이템으로 리롤 가능" },
    },
    [211] = {
        { text = "<warning>3회 피격 시 소멸" },
        { text = "소지중일 때 피격 시 피해를 무시하고 10초간 무적" },
    },
    [212] = {
        { text = "<warning>스테이지당 3번 사용 가능" },
        { text = "사용 시 <color=0xFFC9FF00>나의 작은 유니콘<color=0xFFFFFFFF> 발동" },
        { text = "<arrow>발동 중 처처한 적은 이번 게임에서 영원히 미등장" },
    },
    [213] = {
        { text = "연사 배율 <color=0xFF3BF745>x1.2" },
        { text = "클리어한 방에 입장 시 11.15% 확률로 그 방 재시작" },
    },
    [214] = {
        { text = "사용 시:" },
        { text = "<indent>아군 Dip 4마리 소환" },
        { text = "<indent>방 안의 모든 똥 타입 적에게 40의 피해를 입힘" },
    },
    [215] = {
        { text = "페널티 피격 시 스테이지당 한 번 QTE 이벤트 발생" },
        { text = "<arrow><color=0xFF3BF745>성공<color=0xFFFFFFFF>: 피해 무시+근처 적 출혈+증발성 공격력·연사 증가" },
        { text = "<arrow><color=0xFFF7513B>실패<color=0xFFFFFFFF>: 공격력 배율 x0.8" },
    },
    [216] = {
        { text = "3번째 공격마다 공격력 x3의 근접 공격이 나감" },
    },
    [217] = {
        { text = "최대 체력 <color=0xFF3BF745>+1" },
        { text = "빨간하트 <color=0xFF3BF745>+1" },
    },
    [218] = {
        { text = "비행 가능" },
    },
    [219] = {
        { text = "적과 접촉 시 공격력 x6의 근접 공격이 나감" },
        { text = "적 처치 시 2초 후 사라지는 빨간하트 드롭" },
    },
    [220] = {
        { text = "최대 체력 <color=0xFF3BF745>+1" },
        { text = "빨간하트 <color=0xFF3BF745>+1" },
        { text = "항상 미로의 저주에 걸리는 대신 그 외 저주로부터 면역" },
    },
    [221] = {
        { text = "공격력 배율 <color=0xFF3BF745>x1.1" },
    },
    [222] = {
        { text = "사용 시 방 안의 모든 패밀리어 아이템을 리롤" },
        { text = "<arrow>아이템은 패밀리어에 따라 다름" },
    },
    [223] = {
        { text = "<color=0xFF3BF745>모든 능력치 증가" },
    },
    [224] = {
        { text = "<color=0xFFC9FF00>군체의식<color=0xFFFFFFFF> 효과 적용" },
        { text = "공격키로 파란 파리/거미 조종 가능" },
        { text = "방 입장 시 파란 파리/거미 수만큼 모든 능력치 증가" },
    },
    [225] = {
        { text = "동전 1개당 연사 <color=0xFF3BF745>+0.1" },
    },
    [226] = {
        { text = "이동속도 <color=0xFF3BF745>+0.2" },
        { text = "연사 <color=0xFF3BF745>+0.2" },
        { text = "공격력 <color=0xFF3BF745>+1.5" },
    },
    [227] = {
        { text = "사용 시 방 안의 모든 아이템을 천사방 아이템으로 리롤" },
    },
    [228] = {
        { text = "사망 시 50% 확률로 부활" },
        { text = "확률형 부활 아이템들의 부활 여부 예측" },
    },
    [229] = {
        { text = "<color=0xFF3BF745>모든 능력치 증가" },
    },
    [230] = {
        { text = "<color=0xFFC9FF00>챔피언 벨트<color=0xFFFFFFFF> 효과 적용" },
        { text = "챔피언 적이 받는 피해량 +50%p 증가" },
    },
    [231] = {
        { text = "공격이 적을 관통함" },
        { text = "<arrow>관통한 눈물은 초당 60의 피해를 주는 원광이 생김" },
    },
    [232] = {
        { text = "소울하트 <color=0xFF3BF745>+3" },
        { text = "연사 <color=0xFF3BF745>+1" },
        { text = "0~1퀄리티 아이템 등장 시 5% 확률로 세라핌 세트 아이템으로 리롤" },
    },
    [233] = {
        { text = "공격의 피해량이 이동한 거리에 비례해 증가" },
        { text = "눈물의 피해량이 시간에 비례해 증가" },
    },
    [234] = {
        { text = "15% 확률로 독 눈물 발사" },
        { text = "적과 접촉 시 적을 중독시킴" },
        { text = "중독된 적 처치 시 20% 확률로 블랙하트 1개 드롭" },
    },
    [235] = {
        { text = "사용 시 최대 체력 1칸을 뼈하트 2칸으로 변환" },
    },
    [236] = {
        { text = "15번째 눈물마다 공격력 x3 +5의 깃털 다발 발사" },
    },
    [237] = {
        { text = "연사 <color=0xFF3BF745>+0.3" },
        { text = "적이 피해를 입을 때 6.67% 확률로 피해량 4배 <color=0xFFb9d27d>(행운 비례)" },
    },
    [238] = {
        { text = "적이 피해를 입을 때 6.67% 확률로 피해량 3배 <color=0xFFb9d27d>(행운 비례)" },
    },
    [239] = {
        { text = "사용 시 공격력/연사 모드 전환" },
        { text = "소지중일 때 선택한 모드에 따라 능력치 증감" },
    },
    [240] = {
        { text = "사용 시 방 안의 적을 모두 빙결시키고 모든 장애물 파괴" },
    },
    [241] = {
        { text = "이동속도 <color=0xFF3BF745>+0.2" },
        { text = "공격력 <color=0xFF3BF745>+1" },
        { text = "이터널하트 2개 드롭" },
    },
    [242] = {
        { text = "연사 <color=0xFF3BF745>+0.7" },
        { text = "공격력 <color=0xFF3BF745>+0.5" },
        { text = "이터널하트 4개 드롭" },
    },
}

Descriptions.trinkets = {
    [1] = {
        { text = "눈물을 발사할 때 확률적으로 눈물에 초당 60의 피해를 주는 신성한 오라가 생깁니다" },
        { text = "확률은 행운에 비례해 증가합니다" },
    },
    [2] = {
        { text = "붉은 상자가 생성될 때 확률적으로로 한 개 더 생성합니다" },
        { text = "확률은 행운에 비례해 증가합니다" },
    },
    [3] = {
        { text = "확률적으로 적을 둔화시키는 얼음 눈물을 발사합니다" },
        { text = "확률은 행운에 비례해 증가합니다" },
        { text = "얼음 눈물로 적을 처치하면 그 적이 얼어붙으며, 밀어서 깨뜨리면 얼음 눈물 고리가 발사됩니다" },
    },
    [4] = {
        { text = "저주방 문으로부터의 피해를 받지 않습니다" },
        { tag = "1", text = "맵에 저주방을 표시합니다" },
    },
    [5] = {
        { text = "메가 사탄이나 섬망, 어머니 또는 도그마를 처치하면 이 장신구를 소모하고 에덴의 축복을 획득합니다" },
        { text = "피격을 당하면 흡수됩니다" },
    },
    [6] = {
        { text = "동전을 주울 때 5% 확률로 작은 배터리를 소환합니다" },
        { text = "확률은 행운에 비례해 증가합니다" },
    },
    [7] = {
        { text = "패시브 아이템을 획득할 때 아이템을 하나 더 얻습니다" },
        { text = "이 장신구는 발동된 후 소멸합니다" },
    },
    [8] = {
        { text = "장신구를 획득하면 즉시 동전 5개를 소모하여 장신구를 흡수해 효과를 영구적으로 얻습니다" },
    },
    [9] = {
        { text = "보스를 처치하면 어린 양의 분노에서 등장한 아이템 2개를 소환합니다" },
        { text = "이 장신구는 발동된 후 소멸합니다" },
    },
    [10] = {
        { text = "저주에 면역이 생깁니다" },
        { text = "새 층을 시작할 때마다 천사방이 등장할 확률이 증가합니다" },
    },
    [11] = {
        { text = "2칸 이내에 있는 방들의 구조를 맵에 표시합니다" },
        { text = "가려진 아이템을 밝힙니다" },
    },
    [12] = {
        { text = "보물방에 천체관 아이템 1개가 추가로 등장합니다" },
        { text = "이 장신구는 발동된 후 소멸합니다" },
    },
    [13] = {
        { text = "Astro-rules 전용" },
        { text = "올백과 같은 판정을 가집니다" },
    },
    [14] = {
        { text = "패시브 아이템이 생성되지 않습니다" },
    },
    [15] = {
        { text = "새 층을 시작할 때마다 소지중인 장신구를 흡수해 효과를 영구적으로 얻습니다" },
    },
    [16] = {
        { text = "아이작이 알약을 소모할 때마다 방 안의 모든 적에게 즉시 피해를 줍니다" },
    },
    [17] = {
        { text = "치명타를 입었을 때 이 장신구가 적은 확률로 사망을 무효로 해줍니다" },
        { text = "확률은 행운에 비례해 증가합니다" },
    },
}

Descriptions.pills = {
}

Descriptions.cards = {
}

return Descriptions

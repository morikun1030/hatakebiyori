import '../models/companion_relation.dart';

class CompanionData {
  static const List<CompanionEntry> all = [
    // ── トマト ──────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'tomato',
      goodPartners: [
        CompanionInfo(
            partnerId: 'basil',
            effect: 'バジルの香りがアブラムシやコナジラミを遠ざける。互いの風味も高め合う。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根に共生する微生物がトマトの萎凋病・青枯病を予防する。'),
        CompanionInfo(
            partnerId: 'shiso',
            effect: 'シソの香りが害虫を忌避。アブラムシ対策に効果的。'),
        CompanionInfo(
            partnerId: 'carrot',
            effect: 'ニンジンの根がトマトの根圏を耕し通気性を向上させる。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'cabbage',
            effect: 'トマトはアブラナ科植物の生育を抑制する物質を出す。'),
        CompanionInfo(
            partnerId: 'potato',
            effect: '同じナス科のため共通の病害虫（疫病など）が伝播しやすい。'),
        CompanionInfo(
            partnerId: 'corn',
            effect: 'トウモロコシがトマトの日照を遮り生育を妨げる。'),
      ],
    ),

    // ── ミニトマト ───────────────────────────────────────
    CompanionEntry(
      vegetableId: 'cherry_tomato',
      goodPartners: [
        CompanionInfo(
            partnerId: 'basil',
            effect: 'バジルの香りがアブラムシ・コナジラミを忌避。定番の組み合わせ。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: '根圏の微生物が土壌病害を抑制する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'potato',
            effect: 'ナス科同士で病害が共通。距離を置いて植えること。'),
      ],
    ),

    // ── キュウリ ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'cucumber',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根の拮抗菌がキュウリのつる割れ病を予防する。定番の組み合わせ。'),
        CompanionInfo(
            partnerId: 'lettuce',
            effect: 'レタスが地面を覆い土の乾燥と雑草を抑制する。'),
        CompanionInfo(
            partnerId: 'green_bean',
            effect: 'インゲンがチッソを固定し、お互いの生育を助け合う。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'potato',
            effect: 'キュウリの根が病原菌を持ちやすく、ジャガイモに疫病が伝播するリスクがある。'),
        CompanionInfo(
            partnerId: 'tomato',
            effect: '水分・肥料の要求量が異なり管理が複雑になる。害虫も共通しやすい。'),
      ],
    ),

    // ── ナス ────────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'eggplant',
      goodPartners: [
        CompanionInfo(
            partnerId: 'shiso',
            effect: 'シソの強い香りがカメムシやアブラムシを忌避する。'),
        CompanionInfo(
            partnerId: 'green_bean',
            effect: 'インゲンがチッソを固定し、ナスの肥料要求を補助する。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根がナスの立枯病・萎凋病を予防する効果がある。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'bell_pepper',
            effect: '同じナス科で共通の病害虫の影響を受けやすい。密植は避ける。'),
        CompanionInfo(
            partnerId: 'potato',
            effect: 'ナス科同士で疫病などの病害が共通する。'),
      ],
    ),

    // ── ピーマン ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'bell_pepper',
      goodPartners: [
        CompanionInfo(
            partnerId: 'basil',
            effect: 'バジルの香りがアブラムシを忌避し、ピーマンの生育を助ける。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根の微生物がピーマンの土壌病害を抑制する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'eggplant',
            effect: 'ナス科同士のため病害虫が共通しやすい。株間を十分あける。'),
      ],
    ),

    // ── カボチャ ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'pumpkin',
      goodPartners: [
        CompanionInfo(
            partnerId: 'corn',
            effect: 'トウモロコシが支柱代わりになりカボチャのつるが絡まる。空間を有効活用できる。'),
        CompanionInfo(
            partnerId: 'edamame',
            effect: 'エダマメのチッソ固定がカボチャの生育を助ける。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'potato',
            effect: 'つるが伸びてジャガイモの生育スペースを奪う。管理が困難になる。'),
      ],
    ),

    // ── スイカ ──────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'watermelon',
      goodPartners: [
        CompanionInfo(
            partnerId: 'corn',
            effect: 'トウモロコシが風よけになり、空間を立体的に使える。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根の拮抗菌がスイカのつる割れ病を予防する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'potato',
            effect: '同じ根圏での競合が激しく、お互いの生育を妨げる。'),
      ],
    ),

    // ── ゴーヤ ──────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'goya',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根の微生物がゴーヤの土壌病害を防ぐ。育てやすくなる。'),
        CompanionInfo(
            partnerId: 'basil',
            effect: 'バジルの香りが害虫を忌避する効果がある。'),
      ],
      badPartners: [],
    ),

    // ── トウモロコシ ─────────────────────────────────────
    CompanionEntry(
      vegetableId: 'corn',
      goodPartners: [
        CompanionInfo(
            partnerId: 'edamame',
            effect: 'エダマメのチッソ固定がトウモロコシの肥料を補助。三姉妹栽培の定番。'),
        CompanionInfo(
            partnerId: 'pumpkin',
            effect: 'カボチャが地面を覆い雑草を抑制。空間利用効率が上がる。'),
        CompanionInfo(
            partnerId: 'spinach',
            effect: 'トウモロコシが日陰を作りホウレンソウの夏の暑さを緩和する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'トウモロコシの高い草丈がトマトの日照を遮る。'),
      ],
    ),

    // ── ダイコン ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'daikon',
      goodPartners: [
        CompanionInfo(
            partnerId: 'carrot',
            effect: 'お互いの根が異なる深さに伸びるため競合しにくく、土を耕し合う。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギが病害虫を忌避。ダイコンの生育を助ける。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'spinach',
            effect: 'ホウレンソウとの競合で生育が抑制される場合がある。'),
      ],
    ),

    // ── ニンジン ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'carrot',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギがキアゲハの幼虫（アゲハ芋虫）を遠ざける。根が絡まないため相性抜群。'),
        CompanionInfo(
            partnerId: 'lettuce',
            effect: 'レタスが地表を覆い土の乾燥を防ぐ。スペースを有効活用できる。'),
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'ニンジンの根がトマトの根圏を耕し通気性を高める。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'potato',
            effect: '根が競合し、お互いの生育を妨げる可能性がある。'),
      ],
    ),

    // ── ジャガイモ ───────────────────────────────────────
    CompanionEntry(
      vegetableId: 'potato',
      goodPartners: [
        CompanionInfo(
            partnerId: 'green_bean',
            effect: 'インゲンがチッソを固定してジャガイモの生育を助け、コロラドハムシも忌避。'),
        CompanionInfo(
            partnerId: 'spinach',
            effect: 'ジャガイモの葉が日陰を作りホウレンソウの高温障害を和らげる。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'cucumber',
            effect: '疫病の菌が共通で伝播しやすい。距離を十分あける。'),
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'ナス科同士で同じ病害（疫病・モザイク病）が伝播しやすい。'),
        CompanionInfo(
            partnerId: 'eggplant',
            effect: 'ナス科同士で病害虫が共通する。'),
      ],
    ),

    // ── サツマイモ ───────────────────────────────────────
    CompanionEntry(
      vegetableId: 'sweet_potato',
      goodPartners: [
        CompanionInfo(
            partnerId: 'shiso',
            effect: 'シソの香りが害虫を忌避。地面の乾燥も抑制する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'potato',
            effect: 'つるが伸びてジャガイモに絡みつき管理が複雑になる。'),
      ],
    ),

    // ── ホウレンソウ ─────────────────────────────────────
    CompanionEntry(
      vegetableId: 'spinach',
      goodPartners: [
        CompanionInfo(
            partnerId: 'corn',
            effect: 'トウモロコシが適度な日陰を作り、夏のホウレンソウの暑さを軽減する。'),
        CompanionInfo(
            partnerId: 'strawberry',
            effect: 'ホウレンソウがイチゴの根元を覆い乾燥を防ぎ、互いの生育を助ける。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'daikon',
            effect: 'ダイコンとの競合でホウレンソウの生育が抑制される場合がある。'),
      ],
    ),

    // ── コマツナ ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'komatsuna',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギが害虫を忌避し、コマツナの生育を助ける。'),
        CompanionInfo(
            partnerId: 'lettuce',
            effect: 'スペースを有効活用でき、お互いの生育を妨げない。'),
      ],
      badPartners: [],
    ),

    // ── レタス ──────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'lettuce',
      goodPartners: [
        CompanionInfo(
            partnerId: 'carrot',
            effect: 'ニンジンの根がレタスの根圏をほぐし、互いに共存できる。'),
        CompanionInfo(
            partnerId: 'cucumber',
            effect: 'レタスが地面を覆いキュウリの根元の乾燥と雑草を抑制する。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギが害虫を忌避してレタスを守る。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'cabbage',
            effect: 'キャベツは生育が旺盛でレタスのスペースと日照を奪いやすい。'),
      ],
    ),

    // ── キャベツ ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'cabbage',
      goodPartners: [
        CompanionInfo(
            partnerId: 'lettuce',
            effect: 'スペースを有効活用。レタスがキャベツの足元を覆い雑草を抑制。'),
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギがアオムシ・アブラムシを忌避。キャベツの害虫被害を軽減。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'トマトがアブラナ科植物の生育を抑制する成分を出す。'),
        CompanionInfo(
            partnerId: 'strawberry',
            effect: 'キャベツの根がイチゴの生育を妨げるとされる。'),
      ],
    ),

    // ── ブロッコリー ─────────────────────────────────────
    CompanionEntry(
      vegetableId: 'broccoli',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギがアオムシなどアブラナ科の害虫を忌避する。'),
        CompanionInfo(
            partnerId: 'lettuce',
            effect: 'レタスが足元を覆い雑草抑制と土の乾燥防止に役立つ。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'トマトのアレロパシーがアブラナ科の生育を抑制する。'),
      ],
    ),

    // ── ハクサイ ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'hakusai',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギがハクサイの害虫を忌避し、軟腐病などの病害も抑制する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'cabbage',
            effect: '同じアブラナ科で病害虫が共通する。距離を置いて植える。'),
      ],
    ),

    // ── ネギ ────────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'negi',
      goodPartners: [
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'ネギの根の拮抗菌がトマトの萎凋病・青枯病を予防する名コンビ。'),
        CompanionInfo(
            partnerId: 'cucumber',
            effect: 'キュウリのつる割れ病を予防。古くから行われる伝統的な混植。'),
        CompanionInfo(
            partnerId: 'strawberry',
            effect: 'イチゴの灰色かび病・根腐れを予防する効果がある。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'green_bean',
            effect: 'ネギの根から出る成分がインゲンの生育を妨げる。'),
        CompanionInfo(
            partnerId: 'edamame',
            effect: 'マメ科全般とネギは相性が悪く、根粒菌の働きを阻害する。'),
      ],
    ),

    // ── エダマメ ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'edamame',
      goodPartners: [
        CompanionInfo(
            partnerId: 'corn',
            effect: 'エダマメがチッソを固定しトウモロコシの肥料を補助。三姉妹栽培の基本。'),
        CompanionInfo(
            partnerId: 'pumpkin',
            effect: 'エダマメのチッソ固定がカボチャの生育を助け、空間を有効利用できる。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの成分がマメ科の根粒菌を阻害し、チッソ固定能力が低下する。'),
      ],
    ),

    // ── インゲン ─────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'green_bean',
      goodPartners: [
        CompanionInfo(
            partnerId: 'pumpkin',
            effect: 'インゲンがチッソを固定しカボチャに栄養を供給。三姉妹栽培の組み合わせ。'),
        CompanionInfo(
            partnerId: 'potato',
            effect: 'インゲンのチッソ固定がジャガイモを助け、コロラドハムシも忌避する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根の成分がマメ科の根粒菌を阻害する。'),
      ],
    ),

    // ── イチゴ ──────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'strawberry',
      goodPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギの根の微生物がイチゴの灰色かび病・根腐れを予防する効果がある。'),
        CompanionInfo(
            partnerId: 'spinach',
            effect: 'ホウレンソウがイチゴの根元を覆い保湿・雑草抑制に役立つ。'),
        CompanionInfo(
            partnerId: 'carrot',
            effect: 'ニンジンの根がイチゴの根圏をほぐし生育を助ける。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'cabbage',
            effect: 'キャベツの根の成分がイチゴの生育を妨げるとされる。'),
      ],
    ),

    // ── ブルーベリー ─────────────────────────────────────
    CompanionEntry(
      vegetableId: 'blueberry',
      goodPartners: [
        CompanionInfo(
            partnerId: 'basil',
            effect: 'バジルの香りがブルーベリーの害虫を忌避する。'),
      ],
      badPartners: [
        CompanionInfo(
            partnerId: 'negi',
            effect: 'ネギ類はブルーベリーと酸性度の好みが大きく異なり相性が悪い。'),
      ],
    ),

    // ── シソ ────────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'shiso',
      goodPartners: [
        CompanionInfo(
            partnerId: 'eggplant',
            effect: 'シソの香りがカメムシ・アブラムシを忌避しナスを守る。定番の組み合わせ。'),
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'シソの香りがアブラムシを遠ざける。互いの味も引き立つとされる。'),
      ],
      badPartners: [],
    ),

    // ── バジル ──────────────────────────────────────────
    CompanionEntry(
      vegetableId: 'basil',
      goodPartners: [
        CompanionInfo(
            partnerId: 'tomato',
            effect: 'バジルの香りがアブラムシ・コナジラミを忌避。トマトの風味も向上するとされる。'),
        CompanionInfo(
            partnerId: 'bell_pepper',
            effect: 'バジルの香りがピーマンの害虫を忌避し生育を促進する。'),
        CompanionInfo(
            partnerId: 'cucumber',
            effect: 'バジルがアブラムシなどの害虫を遠ざけキュウリを守る。'),
      ],
      badPartners: [],
    ),
  ];

  /// 野菜IDからコンパニオン情報を取得
  static CompanionEntry? findById(String vegetableId) {
    try {
      return all.firstWhere((e) => e.vegetableId == vegetableId);
    } catch (_) {
      return null;
    }
  }
}

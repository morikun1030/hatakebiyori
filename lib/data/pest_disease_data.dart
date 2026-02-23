import '../models/pest_disease.dart';

class PestDiseaseData {
  // ── 病害虫マスターデータ ────────────────────────────────

  static const List<PestDiseaseInfo> all = [
    // ━━ 害虫 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    PestDiseaseInfo(
      id: 'aphid',
      name: 'アブラムシ',
      type: PestDiseaseType.pest,
      emoji: '🐛',
      symptom: '葉の裏や茎に緑・黒・白色の小さな虫が群生。植物の汁を吸い、葉が縮れたり黄変する。ウイルス病を媒介することもある。',
      prevention: 'バジル・ネギなどコンパニオンプランツを活用。防虫ネットで覆う。アルミホイルをマルチに使うと光を嫌がって忌避できる。',
      treatment: '水で強く洗い流す。牛乳を薄めたスプレーで窒息させる。木酢液・唐辛子液を散布。天然由来の殺虫剤（ニーム油など）を使用。',
    ),
    PestDiseaseInfo(
      id: 'whitefly',
      name: 'コナジラミ',
      type: PestDiseaseType.pest,
      emoji: '🦟',
      symptom: '葉の裏に群生する白い小さな虫。株を揺らすと一斉に飛び立つ。吸汁で葉が黄変し、すす病を誘発することもある。',
      prevention: '黄色粘着トラップをつるして早期発見。防虫ネットで覆う。窒素肥料のやりすぎを避ける。',
      treatment: '黄色粘着トラップで捕獲。葉の裏にしっかり水をかける。ニーム油スプレー。天然由来の殺虫剤。',
    ),
    PestDiseaseInfo(
      id: 'cabbage_worm',
      name: 'アオムシ',
      type: PestDiseaseType.pest,
      emoji: '🐛',
      symptom: 'キャベツ・ブロッコリーなどアブラナ科の葉に大きな穴が開く。モンシロチョウの幼虫で緑色の芋虫。',
      prevention: '防虫ネットで成虫の産卵を防ぐ。ネギを近くに植える。卵（葉裏の黄色い粒）を早期に取り除く。',
      treatment: '見つけ次第手で取り除く。BT剤（天然由来の微生物農薬）が有効。',
    ),
    PestDiseaseInfo(
      id: 'stink_bug',
      name: 'カメムシ',
      type: PestDiseaseType.pest,
      emoji: '🐞',
      symptom: '実に黒い斑点ができる。吸汁によって実が変形・着色不良になる。触れると強い悪臭を放つ。',
      prevention: '防虫ネットで覆う。シソを近くに植える。周囲の雑草を刈る。',
      treatment: '早朝（動きが鈍い時間帯）に捕殺する。ペットボトルトラップ。天然由来の忌避剤を散布。',
    ),
    PestDiseaseInfo(
      id: 'spider_mite',
      name: 'ハダニ',
      type: PestDiseaseType.pest,
      emoji: '🕷️',
      symptom: '葉の裏に細かい網を張る。葉の表面が白くかすれたようになり、ひどいと落葉する。乾燥・高温時に多発。',
      prevention: '葉の裏に定期的に水をスプレーして湿度を保つ。風通しを良くする。',
      treatment: '強めの水流で葉裏を洗い流す。ダニ専用の天然由来農薬（コロマイト乳剤など）を散布。',
    ),
    PestDiseaseInfo(
      id: 'cucumber_beetle',
      name: 'ウリハムシ',
      type: PestDiseaseType.pest,
      emoji: '🪲',
      symptom: '葉に丸い穴が多数開く。ウリ科（キュウリ・カボチャ・スイカ）に多発するオレンジ色の小さな甲虫。',
      prevention: '防虫ネットで覆う。キラキラしたテープを株の周りに張る。早期発見が大切。',
      treatment: '早朝に手で捕殺する。天然由来の殺虫剤を散布。',
    ),
    PestDiseaseInfo(
      id: 'swallowtail_larva',
      name: 'アゲハ幼虫',
      type: PestDiseaseType.pest,
      emoji: '🦋',
      symptom: 'ニンジンなどセリ科植物の葉を食べる大型の緑色の芋虫。若齢幼虫は鳥の糞に擬態した黒白模様。',
      prevention: '防虫ネットで覆う。ネギを近くに植えて成虫の産卵を抑制。',
      treatment: '手で取り除く（アゲハチョウの幼虫なので他の場所に移してもよい）。',
    ),
    PestDiseaseInfo(
      id: 'slug',
      name: 'ナメクジ',
      type: PestDiseaseType.pest,
      emoji: '🐌',
      symptom: '葉や実に不規則な穴が開く。夜間・雨天後に活動する。光る粘液の跡が残る。',
      prevention: '銅テープを鉢の周りに貼る。石灰・珪藻土を株元に散布。ジメジメした環境を改善する。',
      treatment: '夜間にライトを持って手で捕殺。ビールトラップ（容器にビールを入れて誘引・溺死させる）。',
    ),
    PestDiseaseInfo(
      id: 'cutworm',
      name: 'ネキリムシ',
      type: PestDiseaseType.pest,
      emoji: '🐛',
      symptom: '苗が根元からきれいに切られて倒れる。夜行性の蛾の幼虫で、土の中に潜んでいる。',
      prevention: '苗の根元にプラスチックのガードを挿す（ペットボトルの底を切ったものなど）。植え付け時に土に混ぜる殺虫剤を使用。',
      treatment: '株元の土を掘り起こして幼虫を探して取り除く。',
    ),
    PestDiseaseInfo(
      id: 'beetle_larva',
      name: 'コガネムシ幼虫',
      type: PestDiseaseType.pest,
      emoji: '🪲',
      symptom: '根を食べるため植物が突然しおれる。土を掘ると白いC字形の幼虫がいる。',
      prevention: '不織布で根を保護。植え付け時に土に殺虫剤を混ぜる。成虫が飛来する6〜8月は注意。',
      treatment: '土を掘り起こして幼虫を手で取り除く。根が大きく傷んでいる場合は株ごと処分。',
    ),

    // ━━ 病気 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    PestDiseaseInfo(
      id: 'powdery_mildew',
      name: 'うどんこ病',
      type: PestDiseaseType.disease,
      emoji: '🍄',
      symptom: '葉や茎が白い粉をまぶしたようになる。ひどくなると葉が黄変して枯れる。乾燥して昼夜の温度差が大きい時期に多発。',
      prevention: '風通しを良くする。窒素肥料のやりすぎを避ける（葉が柔らかくなると感染しやすい）。',
      treatment: '罹患した葉をすぐ取り除く。重曹水（水1ℓ+重曹1g）をスプレー。カリグリーン（カリウム系農薬）を散布。',
    ),
    PestDiseaseInfo(
      id: 'blight',
      name: '疫病',
      type: PestDiseaseType.disease,
      emoji: '🍂',
      symptom: '葉に水浸状の不規則な病斑が現れ、急速に拡大して茶褐色に枯れる。実にも発生。雨天・多湿時に多発。',
      prevention: '水はけの良い高畝にする。同じ科の野菜の連作を避ける。雨が葉に直接当たらないよう工夫する。',
      treatment: '罹患した葉や株をすぐに除去して処分（土に埋めない）。銅剤系農薬（ボルドー液など）を散布。',
    ),
    PestDiseaseInfo(
      id: 'gray_mold',
      name: '灰色かび病',
      type: PestDiseaseType.disease,
      emoji: '🍄',
      symptom: '葉・茎・実に灰色のカビが生える。感染部位が腐敗する。低温多湿の時期に多発。',
      prevention: '風通しを良くする。罹患した葉はすぐに取り除く。密植を避ける。水やりは朝に行う。',
      treatment: '罹患部位をすぐに取り除いて処分。殺菌剤（ボトキラー水和剤など）を散布。',
    ),
    PestDiseaseInfo(
      id: 'damping_off',
      name: '立枯病',
      type: PestDiseaseType.disease,
      emoji: '🌱',
      symptom: '苗の茎が根元から細くなり腐って倒れる。発芽直後の苗に多く、急に枯れる。',
      prevention: '清潔な新しい培養土を使う。過湿・過密を避ける。種まき後は適切な水管理を行う。',
      treatment: '罹患した苗はすぐに取り除く。周辺の土を乾燥させて菌の繁殖を防ぐ。',
    ),
    PestDiseaseInfo(
      id: 'bacterial_wilt',
      name: '青枯病',
      type: PestDiseaseType.disease,
      emoji: '🥀',
      symptom: '日中に急激に葉がしおれ、夜間は回復する症状を繰り返した後、全株が枯死する。茎を切ると白い液（細菌）が糸を引く。',
      prevention: 'ネギとの混植が有効。連作を避ける（3〜4年）。水はけを改善する。',
      treatment: '発症した株はすぐに根ごと取り除いて処分。土壌に残るため同じ場所での連作はしない。',
    ),
    PestDiseaseInfo(
      id: 'fusarium_wilt',
      name: '萎凋病',
      type: PestDiseaseType.disease,
      emoji: '🥀',
      symptom: '下葉から黄変して順に枯れ上がる。茎を切ると断面が褐変している。土壌伝染性の病気。',
      prevention: '接ぎ木苗を使用（耐病性台木が有効）。連作を避ける。土壌消毒を行う。',
      treatment: '発症した株は根ごと取り除く。土壌消毒剤で処理。同じ場所での栽培は数年間避ける。',
    ),
    PestDiseaseInfo(
      id: 'soft_rot',
      name: '軟腐病',
      type: PestDiseaseType.disease,
      emoji: '😷',
      symptom: '組織が軟化・腐敗して強い悪臭を放つ。傷口から細菌が侵入して発症。多湿時に多発。',
      prevention: '傷をつけないよう丁寧に扱う。過湿を避ける。土壌の水はけを改善する。',
      treatment: '罹患した部分をすぐに取り除く。株全体が感染した場合は処分。銅剤系農薬を散布。',
    ),
    PestDiseaseInfo(
      id: 'downy_mildew',
      name: 'べと病',
      type: PestDiseaseType.disease,
      emoji: '🍂',
      symptom: '葉の表に黄色〜淡褐色の不規則な斑点ができ、裏面には灰紫色のカビが生える。低温多湿時に多発。',
      prevention: '風通しを良くする。葉が濡れた状態を長引かせない（夕方の水やりを避ける）。密植を避ける。',
      treatment: '罹患した葉をすぐ取り除く。銅剤系農薬（ボルドー液）を散布。',
    ),
    PestDiseaseInfo(
      id: 'anthracnose',
      name: '炭疽病',
      type: PestDiseaseType.disease,
      emoji: '🍂',
      symptom: '果実や葉に黒〜暗褐色の凹んだ病斑ができる。雨の多い時期に多発する。',
      prevention: '雨除けを設置する。罹患した実はすぐに除去する。傷をつけないよう管理する。',
      treatment: '罹患部位を取り除く。殺菌剤（ダコニール水和剤など）を予防的に散布。',
    ),
    PestDiseaseInfo(
      id: 'mosaic_virus',
      name: 'モザイク病',
      type: PestDiseaseType.disease,
      emoji: '🌿',
      symptom: '葉にモザイク状の濃淡斑が現れ、葉が縮れる。生育が著しく遅れる。アブラムシが媒介するウイルス病。',
      prevention: 'アブラムシの防除が最重要。防虫ネットで覆う。罹患した株の汁液が伝染するので道具を消毒する。',
      treatment: '有効な治療法はない。発症した株は早急に取り除いて処分する。',
    ),
  ];

  // ── 野菜別の病害虫マッピング ──────────────────────────

  static const Map<String, List<String>> _vegetableMap = {
    'tomato': [
      'aphid', 'whitefly', 'spider_mite',
      'blight', 'bacterial_wilt', 'fusarium_wilt', 'powdery_mildew',
      'mosaic_virus',
    ],
    'cherry_tomato': [
      'aphid', 'whitefly',
      'blight', 'powdery_mildew', 'mosaic_virus',
    ],
    'cucumber': [
      'aphid', 'cucumber_beetle', 'spider_mite',
      'powdery_mildew', 'downy_mildew', 'anthracnose',
    ],
    'eggplant': [
      'aphid', 'whitefly', 'stink_bug', 'spider_mite',
      'powdery_mildew', 'bacterial_wilt',
    ],
    'bell_pepper': [
      'aphid', 'spider_mite',
      'powdery_mildew', 'mosaic_virus',
    ],
    'pumpkin': [
      'aphid', 'cucumber_beetle',
      'powdery_mildew', 'downy_mildew',
    ],
    'watermelon': [
      'aphid', 'cucumber_beetle',
      'powdery_mildew', 'downy_mildew', 'anthracnose',
    ],
    'goya': [
      'aphid', 'cucumber_beetle',
      'powdery_mildew',
    ],
    'corn': [
      'aphid', 'cutworm', 'beetle_larva',
    ],
    'daikon': [
      'aphid', 'cabbage_worm', 'cutworm',
      'soft_rot', 'downy_mildew',
    ],
    'carrot': [
      'swallowtail_larva', 'aphid',
      'damping_off',
    ],
    'potato': [
      'aphid', 'beetle_larva',
      'blight', 'mosaic_virus',
    ],
    'sweet_potato': [
      'beetle_larva', 'cutworm',
      'soft_rot',
    ],
    'turnip': [
      'aphid', 'cabbage_worm',
      'soft_rot',
    ],
    'spinach': [
      'aphid', 'slug',
      'downy_mildew', 'damping_off',
    ],
    'komatsuna': [
      'aphid', 'cabbage_worm',
      'downy_mildew',
    ],
    'lettuce': [
      'aphid', 'slug',
      'gray_mold', 'damping_off',
    ],
    'cabbage': [
      'cabbage_worm', 'aphid', 'cutworm',
      'soft_rot', 'downy_mildew',
    ],
    'broccoli': [
      'cabbage_worm', 'aphid',
      'downy_mildew',
    ],
    'hakusai': [
      'cabbage_worm', 'aphid',
      'soft_rot', 'downy_mildew',
    ],
    'negi': [
      'aphid', 'cutworm',
      'soft_rot',
    ],
    'edamame': [
      'stink_bug', 'aphid',
      'mosaic_virus',
    ],
    'green_bean': [
      'aphid', 'stink_bug',
      'anthracnose', 'mosaic_virus',
    ],
    'fava_bean': [
      'aphid',
      'powdery_mildew',
    ],
    'peas': [
      'aphid',
      'powdery_mildew', 'downy_mildew',
    ],
    'strawberry': [
      'aphid', 'slug', 'spider_mite',
      'gray_mold', 'powdery_mildew',
    ],
    'blueberry': [
      'stink_bug',
      'anthracnose', 'powdery_mildew',
    ],
    'shiso': [
      'aphid',
    ],
    'basil': [
      'aphid', 'slug',
      'damping_off',
    ],
    // ── 葉物野菜（追加）
    'mizuna': [
      'aphid', 'cabbage_worm',
      'downy_mildew',
    ],
    'chingensai': [
      'aphid', 'cabbage_worm',
      'soft_rot', 'downy_mildew',
    ],
    'shungiku': [
      'aphid',
      'downy_mildew',
    ],
    'arugula': [
      'aphid', 'slug',
      'damping_off',
    ],
    'kale': [
      'cabbage_worm', 'aphid',
      'downy_mildew',
    ],
    // ── 根菜（追加）
    'onion': [
      'aphid', 'cutworm',
      'soft_rot', 'downy_mildew',
    ],
    'radish': [
      'aphid', 'cabbage_worm',
      'soft_rot',
    ],
    'ginger': [
      'cutworm',
      'soft_rot',
    ],
    'garlic': [
      'aphid',
      'soft_rot',
    ],
    'taro': [
      'aphid', 'slug',
      'soft_rot',
    ],
    'burdock': [
      'aphid', 'cutworm',
    ],
    // ── 実野菜（追加）
    'zucchini': [
      'aphid', 'cucumber_beetle',
      'powdery_mildew', 'gray_mold',
    ],
    'okra': [
      'aphid', 'stink_bug',
    ],
    'paprika': [
      'aphid', 'spider_mite',
      'powdery_mildew', 'mosaic_virus',
    ],
    'chili': [
      'aphid', 'spider_mite',
      'mosaic_virus',
    ],
    'melon': [
      'aphid', 'cucumber_beetle',
      'powdery_mildew', 'anthracnose', 'downy_mildew',
    ],
    // ── 豆類（追加）
    'peanut': [
      'aphid', 'cutworm',
    ],
    // ── 果樹・果実（追加）
    'lemon': [
      'aphid', 'spider_mite', 'stink_bug',
    ],
    'fig': [
      'stink_bug', 'beetle_larva',
      'anthracnose',
    ],
    'persimmon': [
      'stink_bug',
      'anthracnose',
    ],
    'ume': [
      'aphid', 'stink_bug',
    ],
    'grape': [
      'aphid',
      'powdery_mildew', 'downy_mildew', 'anthracnose',
    ],
    'apple': [
      'aphid', 'spider_mite', 'stink_bug',
      'powdery_mildew',
    ],
    'yuzu': [
      'aphid', 'spider_mite',
    ],
    'raspberry': [
      'aphid', 'stink_bug',
      'gray_mold',
    ],
    // ── ハーブ（追加）
    'mint': [
      'aphid', 'slug',
    ],
    'parsley': [
      'swallowtail_larva', 'aphid',
    ],
    'rosemary': [
      'aphid',
    ],
    'chive': [
      'aphid',
    ],
    'cilantro': [
      'swallowtail_larva', 'aphid',
    ],
    'dill': [
      'swallowtail_larva', 'aphid',
    ],
    'thyme': [
      'aphid',
    ],
  };

  /// 野菜IDに対応する病害虫リストを返す
  static List<PestDiseaseInfo> forVegetable(String vegetableId) {
    final ids = _vegetableMap[vegetableId] ?? [];
    return ids
        .map((id) => all.where((p) => p.id == id).firstOrNull)
        .whereType<PestDiseaseInfo>()
        .toList();
  }
}

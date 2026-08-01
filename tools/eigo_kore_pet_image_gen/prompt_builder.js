// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// eigo-kore ペットキャラクター プロンプト組み立てモジュール
// leonardo-ai-image-gen スキルのパターンを踏襲（cardId の代わりに petId=species_stage を使用）
// 対象: lib/models/pet_model.dart の PetSpecies(5) × PetEvolutionStage(4) = 20枚
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 5種族: それぞれの見た目の核となる特徴
const SPECIES = {
  parrot: { nameJp: 'オウム', desc: 'a colorful parrot with a curved beak, vivid red-blue-yellow feathers, expressive round eyes' },
  turtle: { nameJp: 'カメ', desc: 'a small turtle with a rounded green-brown shell with soft patterns, stubby little legs, gentle round eyes' },
  fish: { nameJp: 'さかな', desc: 'a plump tropical fish with shimmering blue-orange scales, fan-like fins, big sparkling eyes' },
  lion: { nameJp: 'ライオン', desc: 'a small lion cub with a fluffy golden mane, round fluffy ears, warm amber eyes' },
  fox: { nameJp: 'キツネ', desc: 'a fluffy orange fox with a big bushy white-tipped tail, pointed ears, bright curious eyes' },
};

// 4進化段階: 同じ種族でもステージごとに姿・プロポーションが変わる
const STAGES = {
  egg: { nameJp: 'たまご', desc: 'depicted as a cute round egg with soft matching-color speckled pattern, tiny cracks hinting at the creature inside, no visible limbs' },
  baby: { nameJp: 'ベビー', desc: 'depicted as a tiny baby version, extremely chibi proportions, oversized head, tiny stubby limbs, sitting pose, sparkly innocent eyes' },
  kids: { nameJp: 'キッズ', desc: 'depicted as a young playful version, chibi proportions but slightly more balanced, mid-action playful pose, cheerful expression' },
  adult: { nameJp: 'アダルト', desc: 'depicted as a fully grown confident version, still cute and rounded (not realistic/scary), proud upright pose, sparkling proud eyes' },
};

const ART_STYLE =
  'cute kawaii mascot illustration for a Japanese elementary school English learning app, ' +
  'thick clean rounded outlines, flat vector art style, soft pastel color palette, simple flat shading, ' +
  'chibi proportions, centered composition, friendly and welcoming, no scary or realistic elements';

const NEGATIVE_PROMPT = [
  'text, words, letters, numbers, watermark, signature',
  'photorealistic, realistic, scary, creepy, dark, grim',
  'human features, human face, human hands',
  'background scenery, complex background',
  'ugly, blurry, low quality, deformed, mutated, malformed, extra limbs, bad anatomy, extra fingers',
  'duplicate, oversaturated, washed out',
].join(', ');

function getAllPetCombos() {
  const combos = [];
  for (const speciesId of Object.keys(SPECIES)) {
    for (const stageId of Object.keys(STAGES)) {
      combos.push({
        petId: `${speciesId}_${stageId}`,
        speciesId,
        stageId,
        nameJp: `${SPECIES[speciesId].nameJp}（${STAGES[stageId].nameJp}）`,
      });
    }
  }
  return combos;
}

// 魚は硬い卵殻ではなく半透明の卵嚢の方が自然なので egg ステージのみ専用の描写を使う
const FISH_EGG_OVERRIDE =
  'depicted peeking out of a small round translucent glowing egg sac with soft speckled pattern, ' +
  'tiny bubbles floating around, only the head and upper body visible above the sac, no visible tail or fins below';

function buildPrompt(combo) {
  const species = SPECIES[combo.speciesId];
  const stage = STAGES[combo.stageId];
  const stageDesc =
    combo.speciesId === 'fish' && combo.stageId === 'egg' ? FISH_EGG_OVERRIDE : stage.desc;

  const prompt = [
    species.desc,
    stageDesc,
    ART_STYLE,
    'plain solid white background, isolated character, no shadow on ground',
    'high quality, clean lineart, professional game asset',
  ]
    .filter(Boolean)
    .join(', ');

  return { prompt, negativePrompt: NEGATIVE_PROMPT };
}

module.exports = { getAllPetCombos, buildPrompt, SPECIES, STAGES };

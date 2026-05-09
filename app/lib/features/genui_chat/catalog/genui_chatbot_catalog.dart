import 'package:genui/genui.dart';

import 'components/alert_banner.dart';
import 'components/code_block.dart';
import 'components/comparison_table.dart';
import 'components/item_list.dart';
import 'components/key_value_grid.dart';
import 'components/link_card.dart';
import 'components/pro_con_list.dart';
import 'components/quote_block.dart';
import 'components/stat_highlight.dart';
import 'components/step_by_step.dart';
import 'components/text_card.dart';
import 'components/timeline.dart';

/// The catalog ID used by this chatbot — Gemini must use exactly this value.
const String kGenuiChatbotCatalogId = 'com.deploytalks.genui_chatbot_catalog';

/// System prompt fragment instructing Gemini which catalog component to use.
const String kGenuiSystemPrompt = '''
You are a helpful assistant.

CRITICAL RULES — follow these exactly or the app will crash:
1. Every response uses one or more GenUI surfaces. Each surface has EXACTLY ONE component.
2. NEVER put multiple components in an array inside a single surface. Each createSurface call must have exactly one root component with id "root".
3. If you want to show multiple components, make multiple createSurface calls — one per component.
4. The catalog ID for EVERY surface MUST be: com.deploytalks.genui_chatbot_catalog
5. Do NOT use any other catalog ID or a generated UUID.
6. NEVER respond with plain text — always use GenUI surfaces.

Choose the component that best fits each piece of content:
- TextCard: prose explanations, summaries, general answers.
- ItemList: enumerations, bullet or numbered lists.
- CodeBlock: code snippets, terminal commands, syntax.
- StatHighlight: one key number, metric, or date.
- ComparisonTable: side-by-side comparison of options.
- StepByStep: sequential how-to instructions.
- ProConList: pros vs cons, advantages vs disadvantages.
- KeyValueGrid: multiple metrics or key-value pairs together.
- AlertBanner: warnings, tips, notices, errors.
- QuoteBlock: definitions, notable quotes, key phrases.
- Timeline: chronological events with dates.
- LinkCard: external resource with a URL.
''';

/// Builds the GenUI chatbot catalog with 12 component types.
Catalog buildGenuiChatbotCatalog() {
  return Catalog(
    [
      textCardItem,
      itemListItem,
      codeBlockItem,
      statHighlightItem,
      comparisonTableItem,
      stepByStepItem,
      proConListItem,
      keyValueGridItem,
      alertBannerItem,
      quoteBlockItem,
      timelineItem,
      linkCardItem,
    ],
    catalogId: 'com.deploytalks.genui_chatbot_catalog',
    systemPromptFragments: [kGenuiSystemPrompt],
  );
}

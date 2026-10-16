# Lessons from Client and Garage helpers

This audit includes improvements to existing SDK APIs, not just new utilities.
The source applications remain unchanged.

| Source pattern | Existing SDK API | Decision |
| --- | --- | --- |
| Garage tagged debounce | ui.Autocomplete | Fix delayed calls that still send every query. Skip superseded/pending disposed searches, ignore obsolete results, report current failures through onSearchError. Regression tests reproduce rapid typing and exercise disposal, stale completion and errors. |
| Client bottom CTA inset handling | ui.Scaffold | Add an explicit BottomActionArea for bottomNavigationBar composition; do not force bottom padding on every screen. |
| Client currency and Garage quantity editing | ui.TextField.inputFormatters | Add DecimalInputFormatter preserving selection and IME composition. Precision and limits are host-configured. Grouping/currency symbol editing is not implemented. |
| Garage Vietnamese money reading | Core | Add optional money.dart import with exact integer/BigInt dong presentation. |
| Client popup priority queue | ToastQueue, TooltipCoordinator | Existing queues address toast sequencing and tooltip exclusion. Cross-modal priority/cancellation needs a separate contract; do not replace them with the business-specific singleton. |
| Garage permission and picker workflows | ui.MediaPicker | Keep permission, upload and persistence host-owned. Native adapters can be added independently when an integration needs them. |
| Client audio in-flight request coalescing | Remote Config source | Candidate for concurrent fetch handling. Requires dedicated start/load/dispose and transport timeout tests before changing lifecycle behavior. |
| Garage dashboard polling | ui.RefreshView | Polling and user pull-to-refresh are different lifecycles. A future polling controller must await work and account for visibility, errors and disposal. |
| Garage upload manager | MediaPicker, FileAttachmentTile | UI surfaces already exist; background transfer queue is separate work requiring cancellation, concurrency and retry semantics. |

Further review candidates: host-local tooltip coordination, callback failures in
notification queues, text truncation with scaling/graphemes, and normalized
transport errors. These are not claimed as fixed by this change.

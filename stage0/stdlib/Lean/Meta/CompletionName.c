// Lean compiler output
// Module: Lean.Meta.CompletionName
// Imports: Init Lean.Meta.Basic Lean.Meta.Match.MatcherInfo
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
static lean_object* l_Lean_Meta_addToCompletionBlackList___closed__1;
uint8_t lean_is_matcher(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___boxed(lean_object*, lean_object*);
static lean_object* l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___closed__1;
lean_object* l_Lean_Name_mkStr3(lean_object*, lean_object*, lean_object*);
uint8_t l_Lean_TagDeclarationExtension_isTagged(lean_object*, lean_object*, lean_object*);
static lean_object* l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__3;
uint8_t lean_is_aux_recursor(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Lean_Meta_allowCompletion___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted(lean_object*, lean_object*);
static lean_object* l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__4;
static lean_object* l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__2;
LEAN_EXPORT uint8_t l_Lean_Meta_allowCompletion(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Lean_Meta_completionBlackListExt;
lean_object* l_Lean_TagDeclarationExtension_tag(lean_object*, lean_object*, lean_object*);
uint8_t l_Lean_isPrivateName(lean_object*);
uint8_t l_Lean_isRecCore(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lean_completion_add_to_black_list(lean_object*, lean_object*);
extern lean_object* l_Lean_noConfusionExt;
static lean_object* l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__1;
lean_object* l_Lean_mkTagDeclarationExtension(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5_(lean_object*);
uint8_t l_Lean_Name_isInternal(lean_object*);
static lean_object* _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_from_bytes("Lean", 4);
return x_1;
}
}
static lean_object* _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__2() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_from_bytes("Meta", 4);
return x_1;
}
}
static lean_object* _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__3() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_from_bytes("completionBlackListExt", 22);
return x_1;
}
}
static lean_object* _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__4() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; lean_object* x_4; 
x_1 = l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__1;
x_2 = l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__2;
x_3 = l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__3;
x_4 = l_Lean_Name_mkStr3(x_1, x_2, x_3);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5_(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; 
x_2 = l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__4;
x_3 = l_Lean_mkTagDeclarationExtension(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Lean_Meta_addToCompletionBlackList___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = l_Lean_Meta_completionBlackListExt;
return x_1;
}
}
LEAN_EXPORT lean_object* lean_completion_add_to_black_list(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = l_Lean_Meta_addToCompletionBlackList___closed__1;
x_4 = l_Lean_TagDeclarationExtension_tag(x_3, x_1, x_2);
return x_4;
}
}
static lean_object* _init_l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = l_Lean_noConfusionExt;
return x_1;
}
}
LEAN_EXPORT uint8_t l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; uint8_t x_16; 
x_16 = l_Lean_Name_isInternal(x_2);
if (x_16 == 0)
{
lean_object* x_17; 
x_17 = lean_box(0);
x_3 = x_17;
goto block_15;
}
else
{
uint8_t x_18; 
x_18 = l_Lean_isPrivateName(x_2);
if (x_18 == 0)
{
uint8_t x_19; 
lean_dec(x_2);
lean_dec(x_1);
x_19 = 1;
return x_19;
}
else
{
lean_object* x_20; 
x_20 = lean_box(0);
x_3 = x_20;
goto block_15;
}
}
block_15:
{
uint8_t x_4; 
lean_dec(x_3);
lean_inc(x_2);
lean_inc(x_1);
x_4 = lean_is_aux_recursor(x_1, x_2);
if (x_4 == 0)
{
lean_object* x_5; uint8_t x_6; 
x_5 = l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___closed__1;
lean_inc(x_2);
lean_inc(x_1);
x_6 = l_Lean_TagDeclarationExtension_isTagged(x_5, x_1, x_2);
if (x_6 == 0)
{
uint8_t x_7; 
lean_inc(x_2);
lean_inc(x_1);
x_7 = l_Lean_isRecCore(x_1, x_2);
if (x_7 == 0)
{
lean_object* x_8; uint8_t x_9; 
x_8 = l_Lean_Meta_addToCompletionBlackList___closed__1;
lean_inc(x_2);
lean_inc(x_1);
x_9 = l_Lean_TagDeclarationExtension_isTagged(x_8, x_1, x_2);
if (x_9 == 0)
{
uint8_t x_10; 
x_10 = lean_is_matcher(x_1, x_2);
return x_10;
}
else
{
uint8_t x_11; 
lean_dec(x_2);
lean_dec(x_1);
x_11 = 1;
return x_11;
}
}
else
{
uint8_t x_12; 
lean_dec(x_2);
lean_dec(x_1);
x_12 = 1;
return x_12;
}
}
else
{
uint8_t x_13; 
lean_dec(x_2);
lean_dec(x_1);
x_13 = 1;
return x_13;
}
}
else
{
uint8_t x_14; 
lean_dec(x_2);
lean_dec(x_1);
x_14 = 1;
return x_14;
}
}
}
}
LEAN_EXPORT lean_object* l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted(x_1, x_2);
x_4 = lean_box(x_3);
return x_4;
}
}
LEAN_EXPORT uint8_t l_Lean_Meta_allowCompletion(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; 
x_3 = l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted(x_1, x_2);
if (x_3 == 0)
{
uint8_t x_4; 
x_4 = 1;
return x_4;
}
else
{
uint8_t x_5; 
x_5 = 0;
return x_5;
}
}
}
LEAN_EXPORT lean_object* l_Lean_Meta_allowCompletion___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l_Lean_Meta_allowCompletion(x_1, x_2);
x_4 = lean_box(x_3);
return x_4;
}
}
lean_object* initialize_Init(uint8_t builtin, lean_object*);
lean_object* initialize_Lean_Meta_Basic(uint8_t builtin, lean_object*);
lean_object* initialize_Lean_Meta_Match_MatcherInfo(uint8_t builtin, lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_Lean_Meta_CompletionName(uint8_t builtin, lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Lean_Meta_Basic(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Lean_Meta_Match_MatcherInfo(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__1 = _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__1();
lean_mark_persistent(l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__1);
l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__2 = _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__2();
lean_mark_persistent(l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__2);
l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__3 = _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__3();
lean_mark_persistent(l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__3);
l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__4 = _init_l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__4();
lean_mark_persistent(l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5____closed__4);
if (builtin) {res = l_Lean_Meta_initFn____x40_Lean_Meta_CompletionName___hyg_5_(lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
l_Lean_Meta_completionBlackListExt = lean_io_result_get_value(res);
lean_mark_persistent(l_Lean_Meta_completionBlackListExt);
lean_dec_ref(res);
}l_Lean_Meta_addToCompletionBlackList___closed__1 = _init_l_Lean_Meta_addToCompletionBlackList___closed__1();
lean_mark_persistent(l_Lean_Meta_addToCompletionBlackList___closed__1);
l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___closed__1 = _init_l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___closed__1();
lean_mark_persistent(l___private_Lean_Meta_CompletionName_0__Lean_Meta_isBlacklisted___closed__1);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif

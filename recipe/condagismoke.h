#pragma once

#include <glib-object.h>

G_BEGIN_DECLS

#if defined(_WIN32)
#  if defined(CONDA_GI_SMOKE_BUILD)
#    define CONDA_GI_SMOKE_API __declspec(dllexport)
#  else
#    define CONDA_GI_SMOKE_API __declspec(dllimport)
#  endif
#else
#  define CONDA_GI_SMOKE_API
#endif

#define CONDA_GI_SMOKE_TYPE_THING (conda_gi_smoke_thing_get_type())

CONDA_GI_SMOKE_API
G_DECLARE_FINAL_TYPE(CondaGISmokeThing, conda_gi_smoke_thing,
                     CONDA_GI_SMOKE, THING, GObject)

CONDA_GI_SMOKE_API
CondaGISmokeThing *conda_gi_smoke_thing_new(void);

CONDA_GI_SMOKE_API
gint conda_gi_smoke_thing_answer(CondaGISmokeThing *self);

G_END_DECLS

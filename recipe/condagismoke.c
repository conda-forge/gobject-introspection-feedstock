#include "condagismoke.h"

struct _CondaGISmokeThing
{
  GObject parent_instance;
};

G_DEFINE_TYPE(CondaGISmokeThing, conda_gi_smoke_thing, G_TYPE_OBJECT)

static void
conda_gi_smoke_thing_class_init(CondaGISmokeThingClass *klass)
{
}

static void
conda_gi_smoke_thing_init(CondaGISmokeThing *self)
{
}

/**
 * conda_gi_smoke_thing_new:
 *
 * Returns: (transfer full): a new #CondaGISmokeThing
 */
CondaGISmokeThing *
conda_gi_smoke_thing_new(void)
{
  return g_object_new(CONDA_GI_SMOKE_TYPE_THING, NULL);
}

/**
 * conda_gi_smoke_thing_answer:
 * @self: a #CondaGISmokeThing
 *
 * Returns: the smoke-test value
 */
gint
conda_gi_smoke_thing_answer(CondaGISmokeThing *self)
{
  g_return_val_if_fail(CONDA_GI_SMOKE_IS_THING(self), -1);
  return 42;
}

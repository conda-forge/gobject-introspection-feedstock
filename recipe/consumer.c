#include "condagismoke.h"
#include <girepository.h>
#include <stdio.h>

int
main(void)
{
  GError *error = NULL;
  GIRepository *repository = g_irepository_get_default();
  GITypelib *typelib = g_irepository_require(repository, "CondaGISmoke", "1.0", 0, &error);
  GIBaseInfo *object_info;
  GIFunctionInfo *method_info;
  CondaGISmokeThing *thing;
  GIArgument instance, result;

  if (typelib == NULL)
    {
      fprintf(stderr, "failed to load typelib: %s\n", error->message);
      g_clear_error(&error);
      return 1;
    }

  object_info = g_irepository_find_by_name(repository, "CondaGISmoke", "Thing");
  if (object_info == NULL || g_base_info_get_type(object_info) != GI_INFO_TYPE_OBJECT)
    {
      fprintf(stderr, "CondaGISmoke.Thing is not an object\n");
      return 1;
    }

  method_info = g_object_info_find_method((GIObjectInfo *) object_info, "answer");
  if (method_info == NULL)
    {
      fprintf(stderr, "CondaGISmoke.Thing.answer is missing\n");
      return 1;
    }

  thing = conda_gi_smoke_thing_new();
  instance.v_pointer = thing;
  if (!g_function_info_invoke(method_info, &instance, 1, NULL, 0, &result, &error))
    {
      fprintf(stderr, "introspected call failed: %s\n", error->message);
      g_clear_error(&error);
      return 1;
    }
  if (result.v_int32 != 42) return 1;

  g_object_unref(thing);
  g_base_info_unref((GIBaseInfo *) method_info);
  g_base_info_unref(object_info);
  puts("installed gobject-introspection smoke test passed");
  return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
  const char extra_paths[] = "<extra_paths>";
  const char command[] = "<command>";
  const char appname[] = "<appname>";

  char option[] = "-u";
  char config_file[] = "<config_file>";

  const char *path = getenv("PATH");
  if (path == NULL) path = "";
  size_t path_len = strlen(path);

  size_t buf_size = path_len + sizeof(extra_paths) + 1;
  size_t args_size = sizeof(char*) * (argc + 3);
  if (args_size > buf_size) buf_size = args_size;
  void *buf = malloc(buf_size);
  if (buf == NULL) {
    perror("Failed to allocate memory");
    return 1;
  }

  {
    char *updated = buf;
    if (path_len > 0) {
      memcpy(updated, path, path_len);
      updated[path_len] = ':';
      memcpy(updated + path_len + 1, extra_paths, sizeof(extra_paths));
    } else {
      memcpy(updated, extra_paths, sizeof(extra_paths));
    }

    setenv("NVIM_APPNAME", appname, 1);
    setenv("PATH", updated, 1);
  }

  {
    char **args = buf;
    memcpy(args, argv, sizeof(char*) * argc);
    args[argc + 0] = option;
    args[argc + 1] = config_file;
    args[argc + 2] = NULL;

    execv(command, args);
    perror("Failed to execute command");
  }

  free(buf);
  return 1;
}

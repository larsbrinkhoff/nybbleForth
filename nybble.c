#include <stdio.h>
#include <stdlib.h>

#define MSIZE 4096
#define RSIZE 16
#define CSIZE 2

struct machine {
  unsigned char *memory;
  int p;
  int *s;
  int *r;
};

static int fetch (struct machine *m)
{
  return m->memory[m->p++];
}

static int fetch2 (struct machine *m)
{
  return fetch (m) + (fetch (m) << 8);
}

static int ext (int x)
{
  if (x & 0x80)
    x |= -0x100;
  return x;
}

static void execute (unsigned char i, struct machine *m)
{
  int n;
  switch (i)
    {
    case 0: break;
    case 1: *m->s = m->memory[*m->s]; break;
    case 2: *--m->r = m->p + 2; m->p = fetch2 (m); break;
    case 3: m->p = *m->r++; break;
    case 4: *--m->s = fetch2 (m); break;
    case 7: *--m->s = *m->r++; break;
    case 8: n = *m->s++; *m->s = (*m->s + n) & 0xFFFF; break;
    case 9: n = *m->s++; *m->s = ~(*m->s & n) & 0xFFFF; break;
    case 10: *--m->r = *m->s++; break;
    case 11: n = fetch (m); if (*m->s++ == 0) m->p += ext (n); break;
    case 12: n = *m->s++; m->memory[n] = *m->s++; break;
    default: fprintf (stderr, "\nHALTED\n"); exit (1);
    }
}

static void run (struct machine *m)
{
  int i;
  for (;;)
    {
      fprintf (stderr, "\n%04X ", m->p);
      i = fetch (m);
      fprintf (stderr, "%02X ", i);
      execute (i >> 4, m);
      execute (i & 15, m);
    }
}

static struct machine *start (void)
{
  struct machine *m = malloc (sizeof (struct machine));
  m->memory = malloc (MSIZE);
  m->s = malloc (RSIZE * sizeof (int));
  m->r = malloc (RSIZE * sizeof (int));
  m->s += RSIZE;
  m->r += RSIZE;
  return m;
}

int main (int argc, char **argv)
{
  struct machine *m = start ();
  FILE *f = fopen (argv[1], "rb");
  fread (m->memory, 1, MSIZE, f);
  run (m);
}

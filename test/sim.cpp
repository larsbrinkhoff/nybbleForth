#include <Vcpu.h>
#include "verilated_vcd_c.h"

int main (void)
{
  Vcpu *top = new Vcpu;
  vluint64_t t = 0;

  Verilated::traceEverOn(true);
  VerilatedVcdC *vcd = new VerilatedVcdC;
  top->trace(vcd, 99);

  top->clock = 0;

  while (!Verilated::gotFinish())
    {
      top->eval();
      vcd->dump(t++);
      top->clock = !top->clock;
    }

  vcd->close();
  return 0;
}

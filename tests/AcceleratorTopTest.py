import os
import sys

import numpy as np

ROWS = 32
COLS = 32

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer

CMD_NOP     = 0
CMD_LOAD_B  = 1
CMD_COMPUTE = 2

STATUS_IDLE            = 0
STATUS_LOAD_B          = 1
STATUS_INFERENCE_READY = 2
STATUS_COMPUTE         = 3
STATUS_INFERENCE_DONE  = 4

def to_signed(value, width):
    value &= (1 << width) - 1
    if value & (1 << (width - 1)):
        value -= 1 << width
    return value

# Pakuje tablice w bitowo jeden wektor
def pack_vector(values, width):
    mask = (1 << width) - 1
    word = 0
    for i, v in enumerate(values):
        word |= (int(v) & mask) << (i * width)
    return word

def unpack_vector(word, width, count):
    mask = (1 << width) - 1
    return [to_signed((int(word) >> (i * width)) & mask, width) for i in range(count)]


class AcceleratorDriver:

    def __init__(self, dut):
        self.dut = dut

    async def _sample(self):
        await RisingEdge(self.dut.clk)
        await Timer(1, units="ns")

    async def reset(self):
        self.dut.a_in_flat.value = 0
        self.dut.load_w.value = 0
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.clk, 4) # W syntezie reset jest za wolny by wszedzie dotrzec w jednym cyklu
        self.dut.rst_n.value = 1
        await self._sample()

    async def load_weights(self, weights):
        self.dut.load_w.value = 1
        for cycle in range(COLS):
            self.dut.a_in_flat.value = pack_vector(weights[:, COLS - 1 - cycle], 8)
            await self._sample()
        self.dut.load_w.value = 0
        self.dut.a_in_flat.value = 0
        for cycle in range(ROWS + COLS):
            await self._sample()


    async def run_matmul(self, a_vectors_skewed):
        result = []
        for cycle in range(2 * ROWS + COLS - 1):
            out = unpack_vector(self.dut.result_flat.value, 32, COLS)
            if(cycle >= ROWS):
                #print(out)
                result.append(out)
            if cycle < a_vectors_skewed.shape[1]:
                self.dut.a_in_flat.value = pack_vector(a_vectors_skewed[:, cycle], 8)
            else:
                self.dut.a_in_flat.value = 0
            await self._sample()
        return np.array(result)



def augment_A_for_accelerator(A):
    columns = np.array(A).T
    return np.array([np.pad(column, (i, len(columns) - 1 - i)) for i, column in enumerate(columns)])

def convert_out_to_matrix(accelerator_out):
    return np.array([[accelerator_out[k + col][col] for col in range(COLS)] for k in range(ROWS)])

@cocotb.test()
async def test_accelerator_matmul(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    drv = AcceleratorDriver(dut)
    await drv.reset()

    W = np.random.randint(-128, 128, size=(ROWS, COLS))
    await drv.load_weights(W)

    A = np.random.randint(-128, 128, size=(32, 32))
    out = await drv.run_matmul(augment_A_for_accelerator(A))
    #print(out)
    print(out.shape)
    out_matrix = convert_out_to_matrix(out)
    print(out_matrix.shape)

    #todo assert etc


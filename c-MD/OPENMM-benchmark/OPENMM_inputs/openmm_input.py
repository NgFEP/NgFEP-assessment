import openmm as mm
import openmm.app as app
from openmm.unit import *
import sys, time, netCDF4, ctypes
from parmed import load_file
from parmed.openmm import StateDataReporter, NetCDFReporter

CUDA_SUCCESS = 0
cuda = ctypes.CDLL("libcuda.so")
device = ctypes.c_int()
nGpus = ctypes.c_int()
name = b" " * 100
devID=[]

result = cuda.cuInit(0)
if result != CUDA_SUCCESS:
    print("CUDA is not available")
    quit()
cuda.cuDeviceGetCount(ctypes.byref(nGpus))
for i in range(nGpus.value):
    result = cuda.cuDeviceGet(ctypes.byref(device), i)
    result = cuda.cuDeviceGetName(ctypes.c_char_p(name), len(name), device)
    print("Device %s:  %s"  % (device.value, name.split(b"\0", 1)[0].decode()))
    devID.append(device.value)
dvi=",".join(str(i) for i in devID)

amber_sys=load_file("prmtop.parm7", "restart.rst7")
ncrst=app.amberinpcrdfile.AmberInpcrdFile("restart.rst7")

nsteps=100000
system=amber_sys.createSystem(
            nonbondedMethod=app.PME, 
            ewaldErrorTolerance=0.0004,
            nonbondedCutoff=8.0*angstroms,
            constraints=app.HBonds,
            removeCMMotion = True,
)

integrator = mm.LangevinIntegrator(300*kelvin, 1.0/picoseconds, 1.0*femtoseconds,)
barostat = mm.MonteCarloBarostat(1.0*atmosphere, 300.0*kelvin, 25)
system.addForce(barostat)

platform = mm.Platform.getPlatformByName("CUDA")
prop = dict(CudaPrecision="mixed", DeviceIndex=dvi)

sim = app.Simulation(amber_sys.topology, system, integrator, platform, prop)
sim.context.setPositions(amber_sys.positions)
sim.context.setVelocities(ncrst.velocities)

sim.reporters.append(
        StateDataReporter(
            sys.stdout, 
            400, 
            step=True,
            time=False, 
            potentialEnergy=True,
            kineticEnergy=True, 
            temperature=True, 
            volume=True
        )
)

sim.reporters.append(
        NetCDFReporter(
            "trajectory.nc", 
            50000, 
            crds=True
        )
)

print("Running dynamics")
start = time.time()
sim.step(nsteps)
elapsed=time.time() - start
benchmark_time=3.6*2.4*nsteps*0.01/elapsed
print(f"Elapsed time: {elapsed} sec\nBenchmark time: {benchmark_time} ns/day, ", end="")


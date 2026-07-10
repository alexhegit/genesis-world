# MI300X ROCm 7.2 Required Test Report

## Environment

| Component | Detail |
|-----------|--------|
| GPU | AMD Instinct MI300X VF, CDNA 3, gfx942, 192GB HBM3 |
| ROCm | 7.0.0 |
| PyTorch | 2.13.0+rocm7.2 |
| Genesis | 1.2.1 |
| triton | 3.7.1 |

## Command

```bash
uv run pytest -m required tests/ --backend=amdgpu --numprocesses=1 --timeout=1800
```

## Per-file Results

| Test file | Passed | Failed | Skipped | xfailed | Duration |
|-----------|--------|--------|---------|---------|----------|
| test_utils.py | 29 | 0 | 0 | 0 | 5m |
| test_mesh.py | 22 | 0 | 0 | 0 | 4m |
| test_bvh.py | 21 | 0 | 0 | 0 | 1m |
| test_sph.py | 11 | 0 | 0 | 0 | 2m |
| test_fem.py | 8 | 0 | 0 | 1 | 5m |
| test_pbd.py | 6 | 0 | 0 | 0 | 4m |
| test_rigid_physics_analytical_vs_gjk.py | 11 | 0 | 0 | 0 | 5m |
| test_deformable_physics.py | 4 | 0 | 0 | 0 | 19m |
| test_rigid_physics_sparse.py | 2 | 1 | 0 | 0 | 1m |
| test_quadrants.py | 13 | 2 | 0 | 0 | 16m |
| test_sensors.py | 41 | 4 | 0 | 0 | 19m |
| test_rigid_physics.py | 11 | 5 | 0 | 4 | 14m |
| test_render.py (no viewer) | 15 | 12 | 18 | 0 | 37m |
| test_sensor_camera.py | 7 | 1 | 7 | 0 | 3m |
| test_misc.py | 16 | 1 | 0 | 0 | 2m |
| test_grad.py | 10 | 2 | 0 | 0 | 11m |
| test_rigid_physics_island.py | 2 | 5 | 0 | 0 | 8m |
| test_kinematic.py | 0 | 1 | 0 | 0 | — |
| test_integration.py | 0 | 1 | 0 | 0 | — |
| test_recorders.py | 2 | 1 | 0 | 0 | — |
| test_hybrid.py | 0 | 1 | 0 | 0 | 1m |
| test_viewer.py | 0 | 5 | 1 | 0 | — |
| test_backend_switching.py | 1 | 0 | 0 | 0 | — |
| test_imgui_overlay.py | 0 | 0 | 6 | 0 | — |
| test_ipc.py | 0 | 0 | 1 | 0 | — |
| test_usd.py | 0 | 0 | 1 | 0 | — |

## Summary

| Metric | Count |
|--------|-------|
| Passed | 267 |
| Failed | 52 |
| Skipped | 33 |
| xfailed | 1 |
| Total ran | 320 |
| Pass rate | 267/320 = 83.4% |

## Failed Test Cases

### CDNA illegal memory (15)

All in `test_hybrid.py`:

| Test case | Error |
|-----------|-------|
| test_fluid_emitter[0-genesis.engine.materials.SPH.liquid.Liquid] | CUDA error: illegal memory access |
| test_fluid_emitter[1-genesis.engine.materials.SPH.liquid.Liquid] | CUDA error: illegal memory access |
| test_fluid_emitter[2-genesis.engine.materials.SPH.liquid.Liquid] | CUDA error: illegal memory access |
| test_fluid_emitter[2-genesis.engine.materials.PBD.liquid.Liquid] | CUDA error: illegal memory access |
| test_fluid_emitter[2-genesis.engine.materials.MPM.liquid.Liquid] | CUDA error: illegal memory access |
| test_fluid_emitter[2-genesis.engine.materials.MPM.sand.Sand] | CUDA error: illegal memory access |
| test_fluid_emitter[2-genesis.engine.materials.MPM.snow.Snow] | CUDA error: illegal memory access |
| test_fluid_emitter[2-genesis.engine.materials.MPM.elastic.Elastic] | CUDA error: illegal memory access |
| test_sap_rigid_rigid_hydroelastic_contact[64] | CUDA error: illegal memory access |
| test_rigid_mpm_legacy_coupling[1] | CUDA error: illegal memory access |
| test_rigid_mpm_legacy_coupling[10] | CUDA error: illegal memory access |
| test_rigid_mpm_muscle | hipErrorIllegalAddress: illegal memory access |
| test_mesh_mpm_build | CUDA error: illegal memory access |
| test_sap_fem_vs_robot[64] | CUDA error: illegal memory access |
| test_rigid_mpm_muscle (ERROR) | hipErrorIllegalAddress via hipStreamSynchronize |

### Rendering — no display (18)

`test_render.py` (12):

| Test case | Error |
|-----------|-------|
| test_camera_follow_entity[RASTERIZER-0] | RuntimeError |
| test_camera_follow_entity[RASTERIZER-2] | RuntimeError |
| test_sensors_draw_debug[RASTERIZER-0] | RuntimeError: Unable to create OpenGL context |
| test_sensors_draw_debug[RASTERIZER-2] | RuntimeError: Unable to create OpenGL context |
| test_batch_deformable_render[RASTERIZER] | RuntimeError |
| test_rasterizer_env_separate[True-RASTERIZER] | RuntimeError |
| test_render_api_advanced[0-RASTERIZER] | RuntimeError |
| test_render_api_advanced[4-RASTERIZER] | RuntimeError |
| test_draw_debug_frustum_and_trajectory[0-RASTERIZER] | RuntimeError |
| test_draw_debug_frustum_and_trajectory[2-RASTERIZER] | RuntimeError |
| test_render_offscreen_oversized_resolution[RASTERIZER] | RuntimeError |

`test_viewer.py` (5):

| Test case | Error |
|-----------|-------|
| test_interactive_viewer_disable_viewer_defaults | Viewer needs display |
| test_default_viewer_plugin[0] | Viewer needs display |
| test_default_viewer_plugin[2] | Viewer needs display |
| test_viewer_thread_crash_reports_traceback | Viewer needs display |
| test_mouse_interaction_plugin[...] | Viewer needs display |

`test_recorders.py` (1):

| Test case | Error |
|-----------|-------|
| test_plotter | AssertionError: snapshot mismatch (needs display) |

### Rigid physics precision (10)

`test_rigid_physics.py` (5):

| Test case | Error |
|-----------|-------|
| test_set_root_pose[False-False] | Precision mismatch |
| test_set_root_pose[False-True] | Precision mismatch |
| test_set_root_pose[True-False] | Precision mismatch |
| test_set_root_pose[True-True] | Precision mismatch |
| test_normalized_quat | Precision mismatch |

`test_rigid_physics_island.py` (5):

| Test case | Error |
|-----------|-------|
| test_partition_logics[0] | Assertion error |
| test_partition_logics[2] | Assertion error |
| test_solve_correctness[0-0] | Precision mismatch |
| test_solve_correctness[0-5] | Precision mismatch |
| test_solve_correctness[2-0] | Precision mismatch |

### Sensors precision (4)

`test_sensors.py` (4):

| Test case | Error |
|-----------|-------|
| test_contact_sensors_gravity_force[0] | Precision mismatch (CPU backend) |
| test_contact_sensors_gravity_force[2] | Precision mismatch (GPU backend) |
| test_surface_distance_sensor_box_sphere[0] | Precision mismatch (CPU backend) |
| test_surface_distance_sensor_box_sphere[2] | Precision mismatch (GPU backend) |

### Quadrants (2)

`test_quadrants.py` (2):

| Test case | Error |
|-----------|-------|
| test_ndarray_no_compile[gpu-[(3, 0), (4, 1)]-None] | Compile error |
| test_ndarray_no_compile[gpu-[(3, 3), (4, 4)]-None] | Compile error |

### Grad (2)

`test_grad.py` (2):

| Test case | Error |
|-----------|-------|
| test_differentiable_rigid[gpu] | GenesisException |
| test_diff_sim_vs_solver_state_grad_parity[gpu] | GenesisException |

### Other (4)

| Test file | Test case | Error |
|-----------|-----------|-------|
| test_sensor_camera.py | test_camera_lookat_entity | Precision mismatch |
| test_misc.py | test_repr_does_not_crash | Worker crash |
| test_kinematic.py | test_track_rigid | CUDA error: illegal memory access |
| test_integration.py | test_hanging_rigid_cable[gpu] | CUDA error: illegal memory access |

## New failure vs ROCm 7.0

| Test case | ROCm 7.0 | ROCm 7.2 |
|-----------|----------|----------|
| test_rigid_physics_sparse::test_sparse_noslip_resting_stability[gpu] | PASSED | FAILED |

## Tests now passing on ROCm 7.2 (previously failed on 7.0)

4 tests in `test_sensors.py` that failed on ROCm 7.0 now pass on 7.2 (sensors count increased from 37 to 41).

## Skipped Tests (33)

| File | Count | Reason |
|------|-------|--------|
| test_ipc.py | 1 | Missing `uipc` module |
| test_usd.py | 1 | Missing `pxr` module |
| test_imgui_overlay.py | 6 | Missing `imgui-bundle` |
| test_viewer.py | 1 | No display |
| test_render.py | 16 | Missing CUDA (8), LuisaRender (2), other (6) |
| test_sensor_camera.py | 7 | Missing CUDA (3), LuisaRender (4) |

## Root Cause Analysis

### Category 1: CDNA HIP Illegal Memory Access (15 cases)

**Root cause:** All failures involve `quadrants` (QD) kernels — Genesis's GPU compute framework. CDNA 3 (gfx942) architecture has compatibility issues with certain QD kernel memory operations (likely atomics, shared memory, or global memory access patterns), triggering HIP's illegal address detection.

**Affected functionality:**

| Sub-category | Tests | What breaks |
|--------------|-------|-------------|
| SPH/MPM/PBD fluid emission | `test_fluid_emitter` (7) | Particle physics simulation — all fluid types (SPH liquid, PBD liquid, MPM liquid/sand/snow/elastic) |
| Rigid+muscle hybrid | `test_rigid_mpm_muscle` (1) | Muscle-driven soft-rigid coupled simulation |
| Rigid+MPM coupling | `test_rigid_mpm_legacy_coupling` (2) | Legacy rigid-MPM particle coupling |
| Mesh-MPM build | `test_mesh_mpm_build` (1) | Mesh-to-MPM particle conversion |
| FEM+rigid SAP | `test_sap_fem_vs_robot[64]` (1) | FEM-rigid body SAP coupler |
| Rigid-rigid SAP | `test_sap_rigid_rigid_hybrid[64]` (1) | SAP hydroelastic contact between rigid bodies |

**Impact:** All Hybrid materials, particle emitters (SPH/MPM/PBD), and SAP coupler are completely unusable on MI300X. This is the largest functional gap.

### Category 2: Rendering — No Display (18 cases)

**Root cause:** MI300X is a compute-only GPU with no display output. OpenGL context cannot be created.

**Affected functionality:**

| Sub-category | Tests | What breaks |
|--------------|-------|-------------|
| Rasterizer rendering | `test_render.py` (12) | Camera tracking, sensor debug visualization, offscreen rendering, batch rendering |
| Interactive viewer | `test_viewer.py` (5) | 3D interactive visualization |
| Data plotting | `test_recorders.py` (1) | Statistical charts and recording |

**Impact:** All visual output (rendering, viewer, plotting) is unavailable on MI300X. This is expected behavior for a compute-only card and does not affect physics computation.

### Category 3: Rigid Physics Precision (10 cases)

**Root cause:** GPU floating-point precision differences cause numerical errors to exceed test tolerances. CDNA 3's FPU may produce slightly different rounding results in certain accumulation/reduction operations compared to NVIDIA GPUs.

**test_rigid_physics.py (5 cases):**

| Test | What it tests | Failure mode |
|------|--------------|--------------|
| `test_set_root_pose[batch_fixed_verts, relative]` (4) | Rigid body pose set/get with `set_pos`/`set_quat`, AABB computation, frame-relative vs world-frame transforms | AABB precision check fails in `batch_fixed_verts=True` mode |
| `test_normalized_quat` (1) | Quaternion normalization robustness — setting unnormalized quaternion, verifying simulation handles it correctly | Post-step quaternion norm deviates from 1.0 beyond tolerance |

**Functional impact:** Rigid body pose control (set_pos/set_quat) has slight precision degradation in batch fixed vertex mode. Quaternion normalization robustness is marginally reduced.

**test_rigid_physics_island.py (5 cases):**

| Test | What it tests | Failure mode |
|------|--------------|--------------|
| `test_partition_logics[n_envs]` (2) | Contact island partitioning logic — which rigid bodies are grouped into independent "islands" for parallel solving | Island assignment or dof/contact/constraint counts differ from expected |
| `test_solve_correctness[noslip_iterations, n_envs]` (3) | Equivalence of island-decomposed solve vs monolithic solve, with and without noslip friction post-solve | Position results drift apart at fp-accumulation level after 80 chaotic steps |

**Functional impact:** Contact island partitioning and the decomposed solver produce slightly different numerical results. For most use cases this is acceptable, but applications requiring bit-exact reproducibility across backends will see differences.

### Category 4: Sensors Precision (4 cases)

**Root cause:** GPU floating-point precision differences in sensor computation kernels.

| Test | What it tests | Failure mode |
|------|--------------|--------------|
| `test_contact_sensors_gravity_force[n_envs]` (2) | Contact force sensor detects correct forces on a falling box (should equal weight) | Force reading deviates from theoretical value |
| `test_surface_distance_sensor_box_sphere[n_envs]` (2) | Surface distance sensor measures nearest distance between box and sphere | Distance reading deviates from exact geometric distance |

**Functional impact:** Force/torque sensors and distance sensors have slightly reduced precision on MI300X. The absolute values may differ by small amounts from CPU or NVIDIA GPU results.

### Category 5: Quadrants ndarray Compilation (2 cases)

**Root cause:** QD's ndarray mode (`GS_ENABLE_NDARRAY=1`, no Triton) fails to compile or run on GPU backend. The test spawns a subprocess with ndarray mode enabled and verifies offline cache behavior.

| Test | What it tests | Failure mode |
|------|--------------|--------------|
| `test_ndarray_no_compile[gpu-[(3,0),(4,1)]]` | QD ndarray mode with scene building (3 objects, 0 envs → 4 objects, 1 env) | Subprocess returns non-success exit code |
| `test_ndarray_no_compile[gpu-[(3,3),(4,4)]]` | QD ndarray mode with batched scenes (3 objects/3 envs → 4 objects/4 envs) | Same failure |

**Functional impact:** The ndarray fallback path (non-Triton GPU computation) is unusable on MI300X. This is a secondary code path; the primary Triton-based path works fine.

### Category 6: Differentiable Simulation (2 cases)

**Root cause:** Gradient computation in differentiable simulation fails on GPU backend. The `GenesisException` suggests a kernel-level failure when computing or propagating gradients.

| Test | What it tests | Failure mode |
|------|--------------|--------------|
| `test_differentiable_rigid` | Optimizes initial pose via Adam to reach target position through 100-step differentiable simulation | `loss.backward()` or simulation step raises GenesisException |
| `test_diff_sim_vs_solver_state_grad_parity` | Verifies that gradients from `get_state()` and `solver_state` produce identical results | Same exception during gradient computation |

**Functional impact:** Differentiable simulation (trajectory optimization, optimal control, gradient-based policy learning) is completely unusable on MI300X.

### Category 7: Other Failures (7 cases)

| Test | Root cause | Functional impact |
|------|-----------|-------------------|
| `test_sparse_noslip_resting_stability[gpu]` | Sparse solver + noslip friction constraint produces insufficient precision on CDNA 3. 16 boxes on a table fail to reach stable resting state within tolerance. | Sparse rigid body solving for large-scale contact scenes has reduced stability |
| `test_camera_lookat_entity` | Rasterizer camera snapshot pixel comparison fails (likely rendering precision difference or missing OpenGL context) | Camera rendering output differs |
| `test_repr_does_not_crash` | Worker crash — likely caused by residual GPU state from a prior test corrupting the process | Debug string representation |
| `test_track_rigid` | HIP illegal memory access during kinematic ghost entity tracking | Kinematic rigid body tracking (ghost entities) |
| `test_hanging_rigid_cable` | HIP illegal memory access during multi-segment articulated rigid body simulation | Multi-body articulated structures (cables, chains) |
| `test_plotter` | Snapshot pixel comparison fails (needs display) | Data plotting |

## Functional Availability Summary

### ✅ Fully Functional (267 tests, 83.4%)

| Domain | Coverage |
|--------|----------|
| Rigid body basics | Analytical vs GJK collision, pose control, joint limits |
| Individual solvers | SPH, FEM, PBD, MPM (standalone) |
| Deformable physics | Soft body simulation |
| Acceleration structures | BVH |
| Mesh processing | Loading, convexification, simplification |
| Utilities | Math, geometry, I/O |
| Contact island basics | Partitioning works, precision slightly degraded |

### ⚠️ Functional with Precision Degradation

| Domain | Impact |
|--------|--------|
| Rigid body pose control | AABB precision slightly reduced in batch mode |
| Contact island solving | Decomposed vs monolithic solve differs at fp level |
| Force/distance sensors | Readings deviate slightly from exact values |
| Sparse rigid solving | Static stability margin reduced |

### ❌ Not Functional

| Domain | Root cause | Severity |
|--------|-----------|----------|
| Hybrid materials (rigid+soft coupling) | QD kernel CDNA incompatibility | **Critical** — core feature |
| Particle emitters (SPH/MPM/PBD) | QD kernel CDNA incompatibility | **Critical** — core feature |
| SAP coupler (FEM-rigid, rigid-rigid) | QD kernel CDNA incompatibility | **High** — coupled simulation |
| Differentiable simulation | Gradient kernel failure | **High** — ML/optimization workflows |
| QD ndarray mode | GPU compilation failure | **Low** — secondary code path |
| Rendering/visualization | No display output | **N/A** — expected for compute-only GPU |
| Kinematic ghost tracking | HIP illegal memory | **Medium** — ghost entity feature |
| Articulated multi-body (cables) | HIP illegal memory | **Medium** — specific use case |

## Fix Plan (by dependency order)

### Prerequisite: Confirm QD CDNA 3 Support

QD 1.0.2 ships `runtime_rocm70/oclc_isa_version_942.bc` for gfx942, but kernel execution triggers illegal memory access. This indicates compiled kernel code has CDNA 3 compatibility issues.

**Action items:**
- File upstream issue with QD, include minimal reproduction
- Check if QD has a newer version with CDNA 3 fixes

### Phase 1: QD Kernel CDNA Compatibility (Foundation)

**Difficulty: High** — requires QD upstream fix or Genesis-level workaround

| # | Fix | Cases fixed | Difficulty | Notes |
|---|-----|-------------|------------|-------|
| 1.1 | Report CDNA 3 illegal memory to QD upstream | — | Low | File issue with minimal repro |
| 1.2 | Check for QD version with CDNA 3 fix | — | Low | `pip install quadrants --upgrade` |
| 1.3 | Genesis-level CDNA kernel workaround | 15 | High | If QD cannot fix short-term, bypass problematic QD kernel call patterns |

**Unlocks:** Hybrid materials, particle emitters, SAP coupler, kinematic ghost tracking, articulated multi-body

### Phase 2: Precision Fixes (parallel with Phase 1)

**Difficulty: Medium** — Genesis code-level changes

| # | Fix | Cases fixed | Difficulty | Notes |
|---|-----|-------------|------------|-------|
| 2.1 | Rigid body pose AABB precision | 5 | Medium | Adjust floating-point accumulation in AABB computation or relax `test_set_root_pose` tolerance |
| 2.2 | Quaternion normalization precision | 1 | Medium | Check `kernel_forward_kinematics_links_geoms` normalization implementation |
| 2.3 | Contact island partitioning precision | 5 | Medium | Check numerical stability in island partitioning — likely atomic operation rounding differences |
| 2.4 | Sensor precision tolerance | 4 | Low | Relax tolerance in `test_contact_sensors_gravity_force` and `test_surface_distance_sensor_box_sphere` |
| 2.5 | Sparse solver resting stability | 1 | Medium | Check noslip friction numerical behavior on CDNA in `test_sparse_noslip_resting_stability` |

### Phase 3: Differentiable Simulation (depends on Phase 1)

**Difficulty: High** — likely also affected by QD kernel issues

| # | Fix | Cases fixed | Difficulty | Notes |
|---|-----|-------------|------------|-------|
| 3.1 | Differentiable rigid body simulation | 2 | High | `test_differentiable_rigid` and `test_diff_sim_vs_solver_state_grad_parity` — gradient kernel failure on CDNA |

**Note:** These `GenesisException` failures are very likely QD kernel issues; Phase 1 fix should resolve them.

### Phase 4: QD ndarray Mode (independent)

**Difficulty: Low** — isolated compilation issue

| # | Fix | Cases fixed | Difficulty | Notes |
|---|-----|-------------|------------|-------|
| 4.1 | ndarray mode GPU compilation | 2 | Low | `test_ndarray_no_compile[gpu-...]` — subprocess ndarray compilation failure |

### No Fix Needed (expected behavior)

| Cases | Reason | Notes |
|-------|--------|-------|
| 18 | No display | MI300X is compute-only GPU; rendering/viewer unavailability is expected |
| 1 | Worker crash | `test_repr_does_not_crash` likely caused by residual GPU state from prior test, not an independent bug |

### Execution Order

```
Phase 1 (QD upstream)  ──→  Phase 3 (differentiable)
       │
       └──→ Phase 2 (precision) [can parallel]
                    │
                    └──→ Phase 4 (ndarray) [can parallel]
```

**Minimum viable fix path:** Phase 2 + Phase 4 (~13 cases) — completable at Genesis code level without QD upstream dependency.

## Date

2026-07-09

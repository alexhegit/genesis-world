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

## Date

2026-07-09

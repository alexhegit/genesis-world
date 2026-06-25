#!/bin/bash
# Genesis World AMD ROCm - 失败测试重跑脚本
# 测试之前失败的 8 个用例
# 使用方法: bash run_rocm_failed_tests.sh

set -e

echo "=========================================="
echo "  Genesis World AMD ROCm 失败测试重跑"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL_PASS=0
TOTAL_FAIL=0
FAILED_TESTS=""

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local timeout="${3:-300}"
    
    echo -e "${YELLOW}[运行] ${test_name}${NC}"
    echo "  命令: ${test_cmd}"
    
    if timeout ${timeout} bash -c "${test_cmd}" 2>&1 | tee /tmp/test_output.txt; then
        if grep -q "passed" /tmp/test_output.txt; then
            passed=$(grep -oP '\d+(?= passed)' /tmp/test_output.txt | head -1)
            failed=$(grep -oP '\d+(?= failed)' /tmp/test_output.txt | head -1 || echo "0")
            
            TOTAL_PASS=$((TOTAL_PASS + ${passed:-0}))
            TOTAL_FAIL=$((TOTAL_FAIL + ${failed:-0}))
            
            if [ "${failed:-0}" -eq 0 ]; then
                echo -e "  ${GREEN}✓ 通过: ${passed} 个测试${NC}"
            else
                echo -e "  ${RED}✗ 失败: ${failed} 个测试${NC}"
                FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}"
            fi
        else
            echo -e "  ${RED}✗ 测试结果解析失败${NC}"
            TOTAL_FAIL=$((TOTAL_FAIL + 1))
            FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: 解析失败"
        fi
    else
        echo -e "  ${RED}✗ 测试超时或异常退出${NC}"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        FAILED_TESTS="${FAILED_TESTS}\n  - ${test_name}: 超时/异常"
    fi
    echo ""
}

echo "=========================================="
echo "  第 1 组: viewer 相关测试 (需要图形环境)"
echo "=========================================="
echo ""
echo -e "${YELLOW}注意: 这些测试在无头环境下会失败，属于正常现象${NC}"
echo ""

run_test "test_render::test_rasterizer_camera_sensor_with_viewer" \
    "uv run pytest tests/test_render.py::test_rasterizer_camera_sensor_with_viewer -v --backend=amdgpu --timeout=300"

run_test "test_render::test_rasterizer_sensor_env_spacing_invariance[with_viewer]" \
    "uv run pytest 'tests/test_render.py::test_rasterizer_sensor_env_spacing_invariance[with_viewer-RASTERIZER]' -v --backend=amdgpu --timeout=300"

run_test "test_render::test_interactive_viewer_key_press" \
    "uv run pytest tests/test_render.py::test_interactive_viewer_key_press -v --backend=amdgpu --timeout=300"

run_test "test_recorders::test_plotter" \
    "uv run pytest tests/test_recorders.py::test_plotter -v --backend=amdgpu --timeout=300"

echo "=========================================="
echo "  第 2 组: 物理精度测试"
echo "=========================================="
echo ""

run_test "test_rigid_physics::test_frictionloss_advanced" \
    "uv run pytest tests/test_rigid_physics.py::test_frictionloss_advanced -v --backend=amdgpu --timeout=300"

echo "=========================================="
echo "  第 3 组: 混合求解器测试 (单进程)"
echo "=========================================="
echo ""

run_test "test_hybrid::test_fluid_emitter[Sand]" \
    "uv run pytest 'tests/test_hybrid.py::test_fluid_emitter[2-genesis.engine.materials.MPM.sand.Sand]' -v --backend=amdgpu --timeout=300 --numprocesses=1"

run_test "test_hybrid::test_fluid_emitter[Liquid]" \
    "uv run pytest 'tests/test_hybrid.py::test_fluid_emitter[2-genesis.engine.materials.SPH.liquid.Liquid]' -v --backend=amdgpu --timeout=300 --numprocesses=1"

run_test "test_hybrid::test_rigid_mpm_legacy_coupling" \
    "uv run pytest 'tests/test_hybrid.py::test_rigid_mpm_legacy_coupling[1]' -v --backend=amdgpu --timeout=300 --numprocesses=1"

echo "=========================================="
echo "  测试结果汇总"
echo "=========================================="
echo ""
echo -e "  ${GREEN}通过: ${TOTAL_PASS}${NC}"
echo -e "  ${RED}失败: ${TOTAL_FAIL}${NC}"
echo ""

if [ ${TOTAL_FAIL} -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  所有失败测试重跑通过!${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  有 ${TOTAL_FAIL} 个测试仍然失败${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "\n失败的测试:${FAILED_TESTS}"
fi

echo ""
echo "详细日志: /tmp/test_output.txt"
echo ""

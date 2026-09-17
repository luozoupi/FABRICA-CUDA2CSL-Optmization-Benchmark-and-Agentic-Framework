"""Tests for csl_templates — template-based CSL code generation."""

import unittest

from csl_templates import (
    COLLECTIVES_TEMPLATE,
    HALO_EXCHANGE_TEMPLATE,
    SINGLE_PE_TEMPLATE,
    format_template_prompt,
    get_template,
    select_template,
)


class TestSelectTemplate(unittest.TestCase):

    def test_single_pe_1x1(self):
        layout = "const width = 1;\nconst height = 1;\n"
        self.assertEqual(select_template(layout), "single_pe")

    def test_single_pe_no_dims(self):
        layout = "@set_rectangle(1, 1);\n"
        self.assertEqual(select_template(layout), "single_pe")

    def test_collectives(self):
        layout = """
const kernel_rows = 5;
const kernel_cols = 5;
@import_module("<collectives_2d/pe>", c2d_params)
"""
        self.assertEqual(select_template(layout), "collectives")

    def test_halo_exchange(self):
        layout = """
const kernel_rows = 3;
const kernel_cols = 3;
param TX_N: color = @get_color(8);
param RX_N: color = @get_color(9);
param is_n_edge: bool;
"""
        self.assertEqual(select_template(layout), "halo_exchange")

    def test_no_template_game_of_life(self):
        layout = """
const kernel_rows = 5;
const kernel_cols = 5;
@get_color(8)
@bind_data_task(recv_east, rx_east_task_id)
"""
        self.assertIsNone(select_template(layout))

    def test_empty_layout(self):
        self.assertIsNone(select_template(""))
        self.assertIsNone(select_template(None))

    def test_collectives_takes_priority_over_halo(self):
        layout = """
const kernel_rows = 5;
@import_module("<collectives_2d/pe>", c2d)
param TX_N: color = @get_color(8);
"""
        self.assertEqual(select_template(layout), "collectives")


class TestGetTemplate(unittest.TestCase):

    def test_single_pe(self):
        tpl = get_template("single_pe")
        self.assertIn("SLOT: KERNEL_FUNCTION", tpl)
        self.assertIn("SLOT: DATA_BUFFERS", tpl)
        self.assertIn("SLOT: EXPORT_SYMBOLS", tpl)
        self.assertIn("memcpy_params", tpl)
        self.assertIn("timestamp", tpl)
        self.assertIn("f_exit", tpl)

    def test_halo_exchange(self):
        tpl = get_template("halo_exchange")
        self.assertIn("SLOT: STENCIL_BODY", tpl)
        self.assertIn("fab_tx_n", tpl)
        self.assertIn("fab_rx_n", tpl)
        self.assertIn("f_send", tpl)
        self.assertIn("f_rx_done", tpl)
        self.assertIn("@initialize_queue", tpl)

    def test_collectives(self):
        tpl = get_template("collectives")
        self.assertIn("SLOT: LOCAL_COMPUTE", tpl)
        self.assertIn("SLOT: DISTRIBUTE_DATA", tpl)
        self.assertIn("SLOT: GATHER", tpl)
        self.assertIn("mpi_x", tpl)
        self.assertIn("mpi_y", tpl)
        self.assertIn("c2d_params", tpl)

    def test_invalid_name(self):
        with self.assertRaises(KeyError):
            get_template("nonexistent")


class TestFormatTemplatePrompt(unittest.TestCase):

    def test_single_pe_prompt(self):
        tpl = get_template("single_pe")
        out = format_template_prompt("single_pe", tpl)
        self.assertIn("CSL TEMPLATE (single_pe)", out)
        self.assertIn("KERNEL_FUNCTION", out)
        self.assertIn("Do NOT modify", out)
        self.assertIn("```csl", out)

    def test_halo_prompt_has_slots_list(self):
        tpl = get_template("halo_exchange")
        out = format_template_prompt("halo_exchange", tpl)
        self.assertIn("STENCIL_BODY", out)
        self.assertIn("EXTRA_STORAGE", out)

    def test_collectives_prompt_has_slots_list(self):
        tpl = get_template("collectives")
        out = format_template_prompt("collectives", tpl)
        self.assertIn("LOCAL_COMPUTE", out)
        self.assertIn("DISTRIBUTE_DATA", out)
        self.assertIn("GATHER", out)


class TestTemplateCompleteness(unittest.TestCase):

    def test_single_pe_has_timer_packing(self):
        tpl = get_template("single_pe")
        self.assertIn("@bitcast(f32", tpl)
        self.assertIn("@activate(EXIT)", tpl)

    def test_halo_has_queue_init(self):
        tpl = get_template("halo_exchange")
        self.assertIn('@is_arch("wse3")', tpl)
        self.assertIn("@initialize_queue", tpl)

    def test_halo_has_edge_guards(self):
        tpl = get_template("halo_exchange")
        self.assertIn("!is_n_edge", tpl)
        self.assertIn("!is_s_edge", tpl)
        self.assertIn("!is_e_edge", tpl)
        self.assertIn("!is_w_edge", tpl)

    def test_collectives_has_init_pattern(self):
        tpl = get_template("collectives")
        self.assertIn("mpi_x.init()", tpl)
        self.assertIn("mpi_y.init()", tpl)


if __name__ == "__main__":
    unittest.main()

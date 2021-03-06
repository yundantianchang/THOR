// **********************************************************************************
//
// Example of external module to reuse phy module code at various places
// This pushes the module code in another file, with a standard structure, that make it easy to
// put modules in a list and reuse them

#include "phy_modules.h"

#include "boundary_layer.h"
#include "log_writer.h"
#include "radiative_transfer.h"

#include <math.h>
#include <memory>
#include <vector>

// define all the modules we want to use

bool       radiative_transfer_enabled         = false;
const bool radiative_transfer_enabled_default = false;

radiative_transfer rt;

bool       boundary_layer_enabled         = false;
const bool boundary_layer_enabled_default = false;

boundary_layer bl;


std::string phy_modules_get_name() {
    return std::string("multi");
}

void phy_modules_print_config() {
    log::printf("  multi physics module, with radiative transfer, boundary_layer \n");
    log::printf("   Radiative Transfer module: %s.\n",
                radiative_transfer_enabled ? "true" : "false");

    log::printf("   Boundary Layer module: %s.\n", boundary_layer_enabled ? "true" : "false");
    log::printf("\n");

    if (radiative_transfer_enabled)
        rt.print_config();

    if (boundary_layer_enabled)
        bl.print_config();
}


bool phy_modules_init_mem(const ESP& esp, device_RK_array_manager& phy_modules_core_arrays) {
    // initialise all the modules memory

    bool out = true;

    if (radiative_transfer_enabled)
        rt.initialise_memory(esp, phy_modules_core_arrays);

    if (boundary_layer_enabled)
        bl.initialise_memory(esp, phy_modules_core_arrays);

    return out;
}

bool phy_modules_init_data(const ESP& esp, const SimulationSetup& sim, storage* s) {
    bool out = true;
    // initialise all the modules data

    // if (s != nullptr) {
    //     // load initialisation data from storage s
    // }

    if (radiative_transfer_enabled)
        out &= rt.initial_conditions(esp, sim, s);

    if (boundary_layer_enabled)
        out &= bl.initial_conditions(esp, sim, s);

    return out;
}

bool phy_modules_generate_config(config_file& config_reader) {
    bool out = true;

    config_reader.append_config_var(
        "radiative_transfer", radiative_transfer_enabled, radiative_transfer_enabled_default);

    rt.configure(config_reader);

    config_reader.append_config_var(
        "boundary_layer", boundary_layer_enabled, boundary_layer_enabled_default);

    bl.configure(config_reader);

    return out;
}

bool phy_modules_dyn_core_loop_init(const ESP& esp) {

    return true;
}

bool phy_modules_dyn_core_loop_slow_modes(const ESP&             esp,
                                          const SimulationSetup& sim,
                                          int                    nstep, // Step number
                                          double                 times) {               // Time-step [s]

    return true;
}

bool phy_modules_dyn_core_loop_fast_modes(const ESP&             esp,
                                          const SimulationSetup& sim,
                                          int                    nstep, // Step number
                                          double                 time_step) {           // Time-step [s]

    return true;
}

bool phy_modules_dyn_core_loop_end(const ESP& esp) {

    return true;
}


bool phy_modules_phy_loop(ESP& esp, const SimulationSetup& sim, int nstep, double time_step) {
    // run all the modules main loop
    bool out = true;

    if (radiative_transfer_enabled)
        rt.phy_loop(esp, sim, nstep, time_step);

    if (boundary_layer_enabled)
        bl.phy_loop(esp, sim, nstep, time_step);

    return out;
}

bool phy_modules_store_init(storage& s) {
    // radiative transfer option
    s.append_value(radiative_transfer_enabled ? 1.0 : 0.0,
                   "/radiative_transfer",
                   "-",
                   "Using radiative transfer");

    rt.store_init(s);

    s.append_value(
        boundary_layer_enabled ? 1.0 : 0.0, "/boundary_layer", "-", "Using boundary layer");

    bl.store_init(s);

    return true;
}

bool phy_modules_store(const ESP& esp, storage& s) {

    if (radiative_transfer_enabled)
        rt.store(esp, s);

    if (boundary_layer_enabled)
        bl.store(esp, s);

    return true;
}


bool phy_modules_free_mem() {
    // generate all the modules config
    bool out = true;

    if (radiative_transfer_enabled)
        rt.free_memory();

    if (boundary_layer_enabled)
        bl.free_memory();

    return out;
}

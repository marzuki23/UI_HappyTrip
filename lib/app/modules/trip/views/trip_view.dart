import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trip_controller.dart';
import '../../../routes/app_pages.dart';

class TripView extends GetView<TripController> {
  const TripView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Rencanakan Perjalanan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Atur preferensi liburan idealmu",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildLabel("KATEGORI WISATA"),
                  Obx(() {
                    if (controller.isLoadingDestinations.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: LinearProgressIndicator(
                          color: Color(0xFF0061A8),
                          backgroundColor: Color(0xFFE2E8F0),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.selectedCategory.value.isEmpty
                          ? null
                          : controller.selectedCategory.value,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      items: controller.categoryList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                          if (value != null) {
                            controller.selectedCategory.value = value;
                          }
                      },
                      decoration: _inputStyle(),
                    );
                  }),

                  _buildSpacing(),

                  _buildLabel("LOKASI USER"),
                  Obx(() {
                    if (controller.isLoadingDestinations.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: LinearProgressIndicator(
                          color: Color(0xFF0061A8),
                          backgroundColor: Color(0xFFE2E8F0),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.userLocationController.text.isEmpty
                          ? null
                          : controller.userLocationController.text,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      hint: Text(
                        "Pilih lokasi asal Anda",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      items: controller.destinationList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.userLocationController.text = value;
                        }
                      },
                      decoration: _inputStyle(),
                    );
                  }),

                  _buildSpacing(),

                  _buildLabel("LOKASI TUJUAN"),
                  Obx(() {
                    if (controller.isLoadingDestinations.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: LinearProgressIndicator(
                          color: Color(0xFF0061A8),
                          backgroundColor: Color(0xFFE2E8F0),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.selectedDestination.value.isEmpty 
                          ? null 
                          : controller.selectedDestination.value,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      items: controller.destinationList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.selectedDestination.value = value;
                          });
                        }
                      },
                      decoration: _inputStyle(),
                    );
                  }),

                  _buildSpacing(),

                  _buildLabel("JENIS KENDARAAN"),
                  Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedVehicle.value,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    items: controller.vehicleList
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.onVehicleChanged(value);
                      }
                    },
                    decoration: _inputStyle(),
                  )),

                  // CASCADING DROPDOWN: TIPE KENDARAAN (Dinamis Berjenjang)
                  Obx(() {
                    if (controller.selectedVehicle.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpacing(),
                        _buildLabel("TIPE KENDARAAN"),
                        DropdownButtonFormField<String>(
                          key: ValueKey(controller.selectedVehicle.value),
                          value: controller.selectedSubVehicle.value.isEmpty
                              ? null
                              : controller.selectedSubVehicle.value,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          hint: Text(
                            controller.selectedVehicle.value == "Kendaraan Pribadi"
                                ? "Pilih Mobil / Motor"
                                : "Pilih Kereta / Bis",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          items: controller.getSubVehicleList()
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedSubVehicle.value = value;
                            }
                          },
                          decoration: _inputStyle(),
                        ),
                      ],
                    );
                  }),

                  _buildSpacing(),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("BUDGET PERJALANAN"),
                            TextField(
                              controller: controller.budgetController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                              decoration: _inputStyle(hint: "Contoh: 1000000"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("DURASI"),
                            TextField(
                              controller: controller.durationController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                              decoration: _inputStyle(hint: "Contoh: 2 (Hari)"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // BUTTON PROSES
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.validateInputs()) {
                          Get.toNamed(Routes.RECOMMENDATION);
                        }
                      },
                      icon: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Lihat Rekomendasi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0061A8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSpacing() => const SizedBox(height: 20);

  InputDecoration _inputStyle({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
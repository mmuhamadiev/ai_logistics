import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/domain/models/car_type_model.dart';
import 'package:hegelmann_order_automation/domain/models/driver_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_group_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/domain/models/post_code_model.dart';
import 'package:hegelmann_order_automation/domain/models/time_window.dart';
import 'package:hegelmann_order_automation/presentation/manager/filter/filter_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/widgets/board_date_time/board_datetime_picker.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_error.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';
import 'package:hegelmann_order_automation/utils/clustering_dbscan_service.dart';
import 'package:hegelmann_order_automation/utils/route_optimizer.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'postal_code_menu.dart';

class EditOrderInGroupDialog extends StatefulWidget {
  final OrderModel order;
  final OrderGroupModel group;

  const EditOrderInGroupDialog({Key? key, required this.order, required this.group}) : super(key: key);

  @override
  State<EditOrderInGroupDialog> createState() => _EditOrderInGroupDialogState();
}

class _EditOrderInGroupDialogState extends State<EditOrderInGroupDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScrollController _scrollController = ScrollController();

  // Form field controllers
  late TextEditingController _orderNameController;
  late TextEditingController _priceController;
  late TextEditingController _carTypeController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverCarController;
  late TextEditingController _ldmController;
  late TextEditingController _weightController;

  bool _isAdrOrder = false; // Default isAdrOrder value
  bool _canGroupWithAdr = false; // Default canGroupWithAdr value

  OrderStatus orderStatus = OrderStatus.Pending;

  double _ldm = 3.2; // Default LDM value
  double _weight = 2.2; // Default Weight value

  TimeWindow? _pickupTimeWindow;
  TimeWindow? _deliveryTimeWindow;

  PostalCode? _pickupPlace;
  PostalCode? _deliveryPlace;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controllers with existing order data
    _orderNameController = TextEditingController(text: widget.order.orderName);
    _priceController = TextEditingController(text: widget.order.price.toString());
    _carTypeController = TextEditingController(text: widget.order.carTypeName);
    _driverNameController = TextEditingController(text: widget.order.driverInfo?.driverName ?? '');
    _driverCarController = TextEditingController(text: widget.order.driverInfo?.driverCar ?? '');
    orderStatus = widget.order.status;
    _pickupTimeWindow = widget.order.pickupTimeWindow;
    _deliveryTimeWindow = widget.order.deliveryTimeWindow;
    _ldm = widget.order.ldm;
    _isAdrOrder = widget.order.isAdrOrder;
    _canGroupWithAdr = widget.order.canGroupWithAdr;
    _ldmController = TextEditingController(text: widget.order.ldm.toString());
    _weight = widget.order.weight;
    _weightController = TextEditingController(text: widget.order.weight.toString());
    _pickupPlace = widget.order.pickupPlace;
    _deliveryPlace = widget.order.deliveryPlace;
  }

  void _goToNextTab() {
    if (_tabController.index < 3) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _goToPreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupOrderListCubit, GroupOrderListState>(
      listener: (context, state) {
        if (state is GroupOrderListActionLoading) {
          setState(() => _isSaving = true);
        } else if (state is GroupOrderListActionSuccess) {
          setState(() => _isSaving = false);
          context.pop(true);
          showTopSnackbarInfo(context, state.message);
        } else if (state is GroupOrderListActionError) {
          setState(() => _isSaving = false);
          showTopSnackbarError(context, state.message);
        }
      },
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: Scaffold(
            body: Column(
              children: [
                Container(
                  height: 70,
                  color: AppColors.white,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Order: ${widget.order.orderID}', style: AppTextStyles.head32RobotoMedium,),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(false),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Left Section: Tabs and Forms
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                controller: _tabController,
                                labelColor: AppColors.black,
                                indicatorColor: AppColors.black,
                                unselectedLabelColor: Colors.grey,
                                tabs: const [
                                  Tab(text: 'Order Details'),
                                  Tab(text: 'Pickup Info'),
                                  Tab(text: 'Delivery Info'),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: TabBarView(
                                        physics: const NeverScrollableScrollPhysics(),
                                        controller: _tabController,
                                        children: [
                                          _buildOrdererDataForm(),
                                          _buildPickupShipmentInfoForm(),
                                          _buildDeliveryShipmentInfoForm(),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              _goToPreviousTab();
                                            },
                                            icon: const Icon(Icons.arrow_back),
                                            label: const Text("Previous"),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _goToNextTab();
                                            },
                                            icon: Icon(Icons.arrow_forward, color: AppColors.white,),
                                            label: Text("Next", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white)),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right Section: Order Summary
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Order Summary',
                                          style: TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const Divider(),
                                        _buildOrderSummary(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.black),
                                    icon: _isSaving
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                        : Icon(Icons.save, color: AppColors.white,),
                                    label: Text('Save Order', style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white),),
                                    onPressed: _isSaving ? null : () async{
                                      var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                                      if(result) {
                                        final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
                                        var isTeamLead = user.user.userRole == UserRoles.allRoles[1] || user.user.userRole == UserRoles.user;
                                        if (isTeamLead == false) {
                                          showTopSnackbarInfo(
                                              context, 'You do not have access');
                                          return;
                                        } else {
                                          _saveOrder();
                                        }
                                      } else {
                                        showErrorNotification(context, 'Sorry action your connection is lost');
                                        return;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupShipmentInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Text(
            '* All times are set in German Time Zone (CET/CEST)',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () {
              _openPostcodeDialog(true);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey),
                  color: AppColors.white
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.location_on),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Pickup Place: ${_pickupPlace != null? '${_pickupPlace!.countryCode}, ${_pickupPlace!.postalCode}, ${_pickupPlace!.name}': 'Not Selected'}'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          // Pickup TimeWindow
          GestureDetector(
            onTap: () async{
              final germanTimeZone = tz.getLocation('Europe/Berlin');
              final nowInGermanTimeStart = tz.TZDateTime.now(germanTimeZone);

              final result = await showBoardDateTimeMultiPicker(
                context: context,
                pickerType: DateTimePickerType.datetime,
                minimumDate: nowInGermanTimeStart,
                maximumDate: nowInGermanTimeStart.add(const Duration(days: 365)),
                showDragHandle: true,
                options: BoardDateTimeOptions(
                  boardTitle: 'Select Pickup Time Window',
                  boardTitleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                  pickerFormat: PickerFormat.dmy,
                  startDayOfWeek: DateTime.monday,
                  useAmpm: false,
                  actionButtonTypes: const [
                    BoardDateButtonType.today,
                    BoardDateButtonType.tomorrow,
                  ],
                  useResetButton: true,
                  withSecond: false,
                  inputable: false,
                ),
              );

              if (result != null) {
                setState(() {
                  _pickupTimeWindow = TimeWindow(
                    start: result.start,
                    end: result.end,
                  );
                });
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey),
                  color: AppColors.white
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.calendar_today),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Pickup TimeWindow: ${_pickupTimeWindow != null ? "${_pickupTimeWindow!.start} to ${_pickupTimeWindow!.end}" : 'Not Selected'}'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryShipmentInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Text(
            '* All times are set in German Time Zone (CET/CEST)',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          SizedBox(
            height: 12,
          ),
          // Delivery Place Selection
          GestureDetector(
            onTap: () async{
              _openPostcodeDialog(false);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey),
                  color: AppColors.white
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.flag),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Delivery Place: ${_deliveryPlace != null? '${_deliveryPlace!.countryCode}, ${_deliveryPlace!.postalCode}, ${_deliveryPlace!.name}': 'Not Selected'}'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          // Delivery TimeWindow
          GestureDetector(
            onTap: () async{
              final germanTimeZone = tz.getLocation('Europe/Berlin');
              final nowInGermanTime = tz.TZDateTime.now(germanTimeZone);

              final result = await showBoardDateTimeMultiPicker(
                context: context,
                pickerType: DateTimePickerType.datetime,
                minimumDate: nowInGermanTime,
                maximumDate: nowInGermanTime.add(const Duration(days: 365)),
                showDragHandle: true,
                options: BoardDateTimeOptions(
                  boardTitle: 'Select Delivery Time Window',
                  boardTitleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  pickerFormat: PickerFormat.dmy,
                  startDayOfWeek: DateTime.monday,
                  useAmpm: false,
                  actionButtonTypes: const [
                    BoardDateButtonType.today,
                    BoardDateButtonType.tomorrow,
                  ],
                  useResetButton: true,
                  withSecond: false,
                  inputable: false,
                ),
              );

              if (result != null) {
                setState(() {
                  _deliveryTimeWindow = TimeWindow(
                    start: result.start,
                    end: result.end,
                  );
                });
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey),
                  color: AppColors.white
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.calendar_today),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Delivery TimeWindow: ${_deliveryTimeWindow != null ? "${_deliveryTimeWindow!.start} to ${_deliveryTimeWindow!.end}" : 'Not Selected'}'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdererDataForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Name Text Field
                _buildTextField(_orderNameController, 'Order Name'),
                const SizedBox(height: 12),
                // Car Type Selector
                Text('Car type', style: AppTextStyles.body17RobotoMedium,),
                SizedBox(
                  height: 5,
                ),
                DropdownButtonFormField<String>(
                  value: _carTypeController.text.isNotEmpty
                      ? _carTypeController.text
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Car Type',
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: CarTypeModel.carTypes
                      .map(
                        (carType) => DropdownMenuItem(
                      value: carType.name,
                      child: Text(carType.name),
                    ),
                  )
                      .toList(),
                  onChanged: (String? selectedCarType) {
                    if (selectedCarType != null) {
                      final carType = CarTypeModel.getByName(selectedCarType);
                      if (carType != null) {
                        // Update the car type controller
                        setState(() {
                          _carTypeController.text = carType.name;
                          _ldm = _ldm <= carType.length? _ldm: _ldm > carType.length? carType.length: 3.2;
                          _weight = _weight <= carType.maxWeight? _ldm: _ldm > carType.maxWeight? carType.maxWeight: 2.2;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                // ADR Order Checkbox
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey),
                      color: AppColors.white
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Is ADR Order'),
                      Checkbox(
                        value: _isAdrOrder,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAdrOrder = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey),
                      color: AppColors.white
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Can Group with ADR Orders'),
                      Checkbox(
                        value: _canGroupWithAdr,
                        onChanged: (bool? value) {
                          setState(() {
                            _canGroupWithAdr = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LDM (Length x Width x Height)', style: AppTextStyles.body17RobotoMedium,),
                          SizedBox(
                            height: 5,
                          ),
                          IgnorePointer(
                            ignoring: _carTypeController.text.isEmpty,
                            child: Opacity(
                              opacity: _carTypeController.text.isEmpty ? 0.5 : 1.0,
                              child: TextField(
                                controller: _ldmController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')), // Allows numbers with up to 2 decimal places
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    if (newValue.text.isEmpty) return newValue;

                                    double? newValueDouble = double.tryParse(newValue.text);
                                    double maxLength = _carTypeController.text.isEmpty
                                        ? 25.0
                                        : CarTypeModel.getByName(_carTypeController.text)!.length;

                                    if (newValueDouble != null && newValueDouble > maxLength) {
                                      return oldValue; // Restrict input if it exceeds maxWeight
                                    }
                                    return newValue;
                                  }),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Enter LDM',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                ),
                                onChanged: (value) {
                                  double? newValue = double.tryParse(value);
                                  if (newValue != null) {
                                    double maxLDM = _carTypeController.text.isEmpty ? 13.6 : CarTypeModel.getByName(_carTypeController.text)!.length;
                                    if (newValue > maxLDM) {
                                      newValue = maxLDM;
                                    }
                                    setState(() {
                                      _ldm = newValue!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weight (tons)', style: AppTextStyles.body17RobotoMedium,),
                          SizedBox(
                            height: 5,
                          ),
                          IgnorePointer(
                            ignoring: _carTypeController.text.isEmpty,
                            child: Opacity(
                              opacity: _carTypeController.text.isEmpty ? 0.5 : 1.0,
                              child: TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')), // Allows numbers with up to 2 decimal places
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    if (newValue.text.isEmpty) return newValue;

                                    double? newValueDouble = double.tryParse(newValue.text);
                                    double maxWeight = _carTypeController.text.isEmpty
                                        ? 25.0
                                        : CarTypeModel.getByName(_carTypeController.text)!.maxWeight;

                                    if (newValueDouble != null && newValueDouble > maxWeight) {
                                      return oldValue; // Restrict input if it exceeds maxWeight
                                    }
                                    return newValue;
                                  }),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Enter Weight',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                ),
                                onChanged: (value) {
                                  double? newValue = double.tryParse(value);
                                  if (newValue != null) {
                                    double maxWeight = _carTypeController.text.isEmpty ? 25.0 : CarTypeModel.getByName(_carTypeController.text)!.maxWeight;
                                    if (newValue > maxWeight) {
                                      newValue = maxWeight;
                                    }
                                    setState(() {
                                      _weight = newValue!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price', style: AppTextStyles.body17RobotoMedium,),
                          SizedBox(
                            height: 5,
                          ),
                          _buildTextField(_priceController, 'Price'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status Dropdown
                Text('Status', style: AppTextStyles.body17RobotoMedium,),
                SizedBox(
                  height: 5,
                ),
                DropdownButtonFormField<OrderStatus>(
                  value: orderStatus, // Set the current status as the default value
                  decoration: InputDecoration(
                    labelText: 'Order Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: [OrderStatus.Confirmed, OrderStatus.Assigned, OrderStatus.Loaded, OrderStatus.OnTheWay, OrderStatus.Unloaded, OrderStatus.ClientCanceled, OrderStatus.Complete].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    setState(() {
                      orderStatus = newStatus!;
                    });
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                Text('Driver', style: AppTextStyles.body17RobotoMedium,),
                SizedBox(
                  height: 5,
                ),
                _buildTextField(_driverNameController, 'Driver name'),
                SizedBox(
                  height: 12,
                ),
                _buildTextField(_driverCarController, 'Driver Car'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)
        ),
      ),
    );
  }

  void _openPostcodeDialog(bool isPickupPlace) {
    showDialog(
      context: context,
      builder: (context) {
        return PostcodeMenu(
          onPostcodeSelected: (PostalCode selectedPostcode) {
            setState(() {
              print(selectedPostcode.name);
              print(selectedPostcode.code);
              print(selectedPostcode.postalCode);
              print(selectedPostcode.countryCode);
              print('Lat: ${selectedPostcode.latitude}');
              print('Lng: ${selectedPostcode.longitude}');
              if (isPickupPlace) {
                _pickupPlace = selectedPostcode;
              } else {
                _deliveryPlace = selectedPostcode;
              }
            });
            context.pop();
          },
        );
      },
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow('Order ID', widget.order.orderID),
        _buildSummaryRow('Order Name', _orderNameController.text.isEmpty? 'Empty':_orderNameController.text),
        _buildSummaryRow('Car Type', _carTypeController.text.isEmpty ? 'Not Selected' : _carTypeController.text),
        _buildSummaryRow('Weight (tons)', _weight.toStringAsFixed(1)),
        _buildSummaryRow('LDM', _ldm.toStringAsFixed(1)),
        const Divider(),
        Text('Pickup Details', style: AppTextStyles.head20RobotoMedium,),
        _buildSummaryRow('Pickup Place', _pickupPlace?.name == null? 'Not Selected': '${_pickupPlace?.countryCode}\n${_pickupPlace?.postalCode}\n${_pickupPlace?.name}'),
        _buildSummaryRow('Pickup D/T', _pickupTimeWindow != null ? '${DateFormat('dd-MM-yyyy HH:mm').format(_pickupTimeWindow!.start)}\n${DateFormat('dd-MM-yyyy HH:mm').format(_pickupTimeWindow!.end)}' : 'Not Selected'),
        const Divider(),
        Text('Delivery Details', style: AppTextStyles.head20RobotoMedium,),
        _buildSummaryRow('Delivery Place', _deliveryPlace?.name == null ? 'Not Selected': '${_deliveryPlace?.postalCode}\n${_deliveryPlace?.postalCode}\n${_deliveryPlace?.name}'),
        _buildSummaryRow('Delivery D/T', _deliveryTimeWindow != null ? '${DateFormat('dd-MM-yyyy HH:mm').format(_deliveryTimeWindow!.start)}\n${DateFormat('dd-MM-yyyy HH:mm').format(_deliveryTimeWindow!.end)}' : 'Not Selected'),
        const Divider(),
        Text('Driver Details', style: AppTextStyles.head20RobotoMedium,),
        _buildSummaryRow('Driver Name', _driverNameController.text.isEmpty ? 'Empty' : _driverNameController.text),
        _buildSummaryRow('Driver Car', _driverCarController.text.isEmpty ? 'Empty' : _driverCarController.text),
        const Divider(),
        Text('Total Price', style: AppTextStyles.head20RobotoMedium,),
        _buildSummaryRow('Price', _priceController.text.isEmpty ? '€0.00' : _priceController.text),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body16RobotoMedium.copyWith(color: AppColors.grey)),
          Text(value.isEmpty ? 'N/A' : value, textAlign: TextAlign.end,),
        ],
      ),
    );
  }

  void _saveOrder() async{
    if (_orderNameController.text.isEmpty) {
      showTopSnackbarError(context, 'Order Name is required.');
      return;
    }
    if (_pickupPlace == null) {
      showTopSnackbarError(context, 'Pickup Place is required.');
      return;
    }
    if (_pickupTimeWindow == null) {
      showTopSnackbarError(context, 'Pickup Date & Time is required.');
      return;
    }
    if (_deliveryPlace == null) {
      showTopSnackbarError(context, 'Delivery Place is required.');
      return;
    }
    if (_deliveryTimeWindow == null) {
      showTopSnackbarError(context, 'Delivery Date & Time is required.');
      return;
    }
    if (_carTypeController.text.isEmpty) {
      showTopSnackbarError(context, 'Car Type is required.');
      return;
    }
    if(_pickupTimeWindow != null && _deliveryTimeWindow != null) {
      if(!_deliveryTimeWindow!.start.isAfter(_pickupTimeWindow!.start)) {
        showTopSnackbarError(context, 'Delivery Date & Time can\'t be before pickup start.');
        return;
      }
    }

    // Save order via cubit
    var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
    if(result) {
      final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
      final updatedOrder = widget.order.copyWith(
        orderName: _orderNameController.text,
        pickupPlace: _pickupPlace!,
        deliveryPlace: _deliveryPlace!,
        ldm: _ldm,
        weight: _weight,
        price: double.tryParse(_priceController.text) ?? 0.0,
        carTypeName: _carTypeController.text,
        driverInfo: _driverNameController.text.isNotEmpty
            ? DriverInfo(
          driverCar: _driverCarController.text,
          driverName: _driverNameController.text,
          carTypeName: _carTypeController.text,
        )
            : null,
        status: orderStatus,
        pickupTimeWindow: _pickupTimeWindow,
        deliveryTimeWindow: _deliveryTimeWindow,
        isAdrOrder: _isAdrOrder,
        canGroupWithAdr: _canGroupWithAdr,
        isEditing: false,
        lastModifiedAt: DateTime.now(),
        lastStartEditTime: null,
      );

      var isOrderLastStartEditTimeChanged = await context.read<GroupOrderListCubit>().isOrderLastStartGroupEditTimeChanged(widget.group.groupID, widget.group.lastModifiedAt);

      if(isOrderLastStartEditTimeChanged) {
        showErrorNotification(context, 'Order has been updated recently, please retrieve new data first');
        return;
      } else {
        List<OrderModel> updateOrderInList(List<OrderModel> orders, OrderModel updatedOrder) {
          return orders.map((order) => order.orderID == updatedOrder.orderID ? updatedOrder : order).toList();
        }

        var orders = updateOrderInList(widget.group.orders, updatedOrder);

        _updateOrder(context, orders, widget.group);
        return;
      }
    } else {
      showErrorNotification(context, 'Sorry action your connection is lost');
      return;
    }

  }

  Future<void> _updateOrder(BuildContext context,
      List<OrderModel> selectedOrders, OrderGroupModel oldGroup,) async {
    try {
      List<int> optimizedGroup = RouteOptimizer.optimizeRoute(selectedOrders);

      double totalDistance = ClusteringDBSCANService.calculateRouteDistance(
          selectedOrders, optimizedGroup);
      double totalPrice = selectedOrders.fold(
          0, (sum, order) => sum + order.price);
      double pricePerKm = totalDistance > 0 ? totalPrice / totalDistance : 0.0;
      double totalWeight = selectedOrders.fold(
          0, (sum, order) => sum + order.weight);
      double totalLDM = selectedOrders.fold(0, (sum, order) => sum + order.ldm);
      var orderIdsList = [];
      selectedOrders.forEach((order) {
        orderIdsList.add(order.orderID);
      });

      var group = OrderGroupModel(
        groupID: orderIdsList.join('-'),
        orders: selectedOrders.map((order) {
          return order.copyWith(
            lastModifiedAt: DateTime.now(),
            isEditing: false,
            lastStartEditTime: null,
            connectedGroupID: orderIdsList.join('-'),
          );
        }).toList(),
        totalDistance: totalDistance,
        pricePerKm: pricePerKm,
        totalPrice: totalPrice,
        totalLDM: totalLDM,
        totalWeight: totalWeight,
        status: oldGroup.status,
        creatorID: oldGroup.creatorID,
        creatorName: oldGroup.creatorName,
        createdAt: oldGroup.createdAt,
        isNeedAddMore: oldGroup.isNeedAddMore,
        comments: oldGroup.comments,
        logs: oldGroup.logs,
        driverInfo: oldGroup.driverInfo,
        isEditing: false,
        lastModifiedAt: DateTime.now(),
        lastStartEditTime: null,
      );
      // Step 1: Fetch the global filter
      await context.read<FilterCubit>().fetchFilter();
      final filterState = context
          .read<FilterCubit>()
          .state;

      if (filterState is FilterLoaded) {
        final filter = filterState.filter;

        // Step 2: Validate the group order against the filter criteria

        final meetsPricePerKmThreshold = pricePerKm >=
            filter.pricePerKmThreshold;

        if (meetsPricePerKmThreshold) {
          // Criteria met: Add order directly
          var result = await context
              .read<UserProfileCubit>()
              .checkIfUserProfileActive(context);
          if (result) {
            final user = context
                .read<UserProfileCubit>()
                .state
            as UserProfileLoaded;

            var isOrderLastStartGroupEditTimeChanged = await context.read<GroupOrderListCubit>().isOrderLastStartGroupEditTimeChanged(group.groupID, oldGroup.lastModifiedAt);
            if(isOrderLastStartGroupEditTimeChanged) {
              showErrorNotification(context, 'Group has been updated recently, please retrieve new data first');
            } else {
              context
                  .read<GroupOrderListCubit>()
                  .updateOrderInGroup(
                  group,
                  user.user.userID,
                  user.user.name,
                  oldGroup
              );
            }

          } else {
            showErrorNotification(context,
                'Sorry action your connection is lost');
          }
        } else {
          // Criteria not met: Show confirmation dialog
          final shouldConfirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm Adding Order'),
                content: const Text(
                  'The order group does not fully meet the filter criteria. Do you want to add it anyway?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );

          // If the user confirms, add the order group
          if (shouldConfirm == true) {
            var result = await context
                .read<UserProfileCubit>()
                .checkIfUserProfileActive(context);
            if (result) {
              final user = context
                  .read<UserProfileCubit>()
                  .state
              as UserProfileLoaded;

              context
                  .read<GroupOrderListCubit>()
                  .updateOrderInGroup(
                  group,
                  user.user.userID,
                  user.user.name,
                  oldGroup
              );
            } else {
              showErrorNotification(context,
                  'Sorry action your connection is lost');
            }
          } else {
            showTopSnackbarInfo(context, 'Order group addition was canceled.');
          }
        }
      } else if (filterState is FilterError) {
        // Handle filter fetch error
        showErrorNotification(context, filterState.message);
      } else {
        // Handle unexpected state
        showErrorNotification(
            context, 'Failed to validate filter criteria. Please try again.');
      }
    } catch (e) {
      // Handle any other errors
      showErrorNotification(context, 'Error fetching filter: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderNameController.dispose();
    _priceController.dispose();
    _carTypeController.dispose();
    _driverNameController.dispose();
    _driverCarController.dispose();
    _ldmController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

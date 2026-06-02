import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';
import '../services/tax_service.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

class TaxSetupPage extends StatefulWidget {
  const TaxSetupPage({super.key});

  @override
  State<TaxSetupPage> createState() => _TaxSetupPageState();
}

class _TaxSetupPageState extends State<TaxSetupPage> {
  final TaxService _taxService = TaxService();
  bool _isLoading = false; 
  bool _isLoadingData = true; 

  String _businessType = 'individual';
  String _vatType = 'general';
  
  bool _hasEmployees = false;
  bool _hasVehicle = false;
  bool _hasProperty = false;
  bool _hasLicense = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings(); 
  }

  Future<void> _loadSavedSettings() async {
    final data = await _taxService.loadProfile();
    if (data != null) {
      setState(() {
        _businessType = data['business_type'] ?? 'individual';
        _vatType = data['vat_type'] ?? 'general';
        _hasEmployees = data['has_employees'] ?? false;
        _hasVehicle = data['has_vehicle'] ?? false;
        _hasProperty = data['has_property'] ?? false;
        _hasLicense = data['has_license'] ?? false;
      });
    }
    setState(() => _isLoadingData = false);
  }

  Future<void> _saveAndGenerate() async {
    setState(() => _isLoading = true);
    try {
      await _taxService.saveProfileAndGenerateEvents(
        businessType: _businessType,
        vatType: _vatType,
        hasEmployees: _hasEmployees,
        hasVehicle: _hasVehicle,
        hasProperty: _hasProperty,
        hasLicense: _hasLicense,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("세금 일정이 저장되었습니다!")));
        Navigator.pop(context, true); 
      }
    } catch (e) {
      appLogger.e('세금 설정 저장 실패', error: e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("저장 실패")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("세무 설정")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("사장님 상황에 딱 맞는\n세금 일정을 챙겨드릴게요.", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            const Text("기본 정보", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _businessType,
              decoration: const InputDecoration(labelText: "사업자 유형", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'individual', child: Text("개인사업자")),
                DropdownMenuItem(value: 'corporate', child: Text("법인사업자")),
              ],
              onChanged: (val) => setState(() => _businessType = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _vatType,
              decoration: const InputDecoration(labelText: "과세 유형", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'general', child: Text("일반과세자 (10%)")),
                DropdownMenuItem(value: 'simplified', child: Text("간이과세자 (연매출 1억 400만원 미만)")),
                DropdownMenuItem(value: 'exempt', child: Text("면세사업자")),
              ],
              onChanged: (val) => setState(() => _vatType = val!),
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            const Text("해당하는 항목을 켜주세요", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            
            SwitchListTile(
              title: const Text("직원/알바가 있나요?"),
              subtitle: const Text("원천세, 4대보험 일정 추가"),
              value: _hasEmployees,
              onChanged: (val) => setState(() => _hasEmployees = val),
            ),
            SwitchListTile(
              title: const Text("업무용 차량이 있나요?"),
              subtitle: const Text("자동차세 일정 추가"),
              value: _hasVehicle,
              onChanged: (val) => setState(() => _hasVehicle = val),
            ),
            SwitchListTile(
              title: const Text("사업장(건물/토지) 보유?"),
              subtitle: const Text("재산세, 주민세 일정 추가"),
              value: _hasProperty,
              onChanged: (val) => setState(() => _hasProperty = val),
            ),
            SwitchListTile(
              title: const Text("면허세 대상 업종인가요?"),
              subtitle: const Text("등록면허세 일정 추가 (요식업 등)"),
              value: _hasLicense,
              onChanged: (val) => setState(() => _hasLicense = val),
            ),

            const SizedBox(height: 30),
            PrimaryButton(
              label: _isLoading ? "저장 중..." : "설정 저장 및 일정 생성",
              isLoading: _isLoading,
              onPressed: _saveAndGenerate,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Structure to hold medical record details

contract HealthcareRecords {
    struct Patient {
    uint256 id;
    string name;
    uint256 birthdate;
    address patientAddress;
    bool isValid;
    }
// Structure to hold patient details
struct MedicalRecord {
    uint256 id;
    uint256 patientId;
    string recordData; // Encrypted medical record data
    uint256 timestamp;
    bool isValid;
}

// Array to store patients and medical records
Patient[] public patients;
MedicalRecord[] public medicalRecords;

// Address of the healthcare provider (institution)
address public institution;

// Modifier to restrict access to only the institution
modifier onlyInstitution() {
    require(msg.sender == institution, "Only institution can manage records");
    _;
}

// Event to log patient registration
event PatientRegistered(uint256 id, string name, uint256 birthdate, address patientAddress);
// Event to log medical record issuance
event MedicalRecordIssued(uint256 id, uint256 patientId, string recordData, uint256 timestamp);
// Event to log medical record invalidation
event MedicalRecordInvalidated(uint256 id);

// Function to set the institution address (only callable once)
function setInstitution(address _institution) public {
    require(institution == address(0), "Institution address already set");
    institution = _institution;
}

// Function to register a new patient
function registerPatient(
    string memory _name,
    uint256 _birthdate,
    address _patientAddress
) public onlyInstitution {
    uint256 patientId = patients.length + 1;
    Patient memory newPatient = Patient(
        patientId,
        _name,
        _birthdate,
        _patientAddress,
        true
    );
    patients.push(newPatient);
    emit PatientRegistered(patientId, _name, _birthdate, _patientAddress);
}

// Function to issue a medical record
function issueMedicalRecord(
    uint256 _patientId,
    string memory _recordData
) public onlyInstitution {
    require(_patientId > 0 && _patientId <= patients.length, "Patient does not exist");
    uint256 recordId = medicalRecords.length + 1;
    uint256 timestamp = block.timestamp;
    MedicalRecord memory newRecord = MedicalRecord(
        recordId,
        _patientId,
        _recordData,
        timestamp,
        true
    );
    medicalRecords.push(newRecord);
    emit MedicalRecordIssued(recordId, _patientId, _recordData, timestamp);
}

// Function to verify a medical record
function verifyMedicalRecord(uint256 _id) public view returns (
    uint256 patientId,
    string memory recordData,
    uint256 timestamp,
    bool isValid
) {
    require(_id > 0 && _id <= medicalRecords.length, "Medical record does not exist");
    MedicalRecord memory record = medicalRecords[_id - 1];
    return (record.patientId, record.recordData, record.timestamp, record.isValid);
}

// Function to invalidate a medical record
function invalidateMedicalRecord(uint256 _id) public onlyInstitution {
    require(_id > 0 && _id <= medicalRecords.length, "Medical record does not exist");
    MedicalRecord storage record = medicalRecords[_id - 1];
    record.isValid = false;
    emit MedicalRecordInvalidated(_id);
}

// Function to return all valid medical records
function getValidMedicalRecords() public view returns (MedicalRecord[] memory) {
    uint256 validCount = 0;
    for (uint256 i = 0; i < medicalRecords.length; i++) {
        if (medicalRecords[i].isValid) {
            validCount++;
        }
    }
    MedicalRecord[] memory validRecords = new MedicalRecord[](validCount);
    uint256 index = 0;
    for (uint256 i = 0; i < medicalRecords.length; i++) {
        if (medicalRecords[i].isValid) {
            validRecords[index] = medicalRecords[i];
            index++;
        }
    }
    return validRecords;
}

// Function to return all invalid medical records
function getInvalidMedicalRecords() public view returns (MedicalRecord[] memory) {
    uint256 invalidCount = 0;
    for (uint256 i = 0; i < medicalRecords.length; i++) {
        if (!medicalRecords[i].isValid) {
            invalidCount++;
        }
    }
    MedicalRecord[] memory invalidRecords = new MedicalRecord[](invalidCount);
    uint256 index = 0;
    for (uint256 i = 0; i < medicalRecords.length; i++) {
        if (!medicalRecords[i].isValid) {
            invalidRecords[index] = medicalRecords[i];
            index++;
        }
    }
    return invalidRecords;
}
}
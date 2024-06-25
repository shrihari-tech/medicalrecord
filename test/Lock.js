import hardhat from "hardhat";
const { ethers } = hardhat;
import { expect } from "chai";

describe("HealthcareRecords", function () {
    let HealthcareRecords;
    let healthcareRecords;
    let institution;
    let otherAccount;
    let patientAccount;

    beforeEach(async function () {
        [institution, otherAccount, patientAccount] = await ethers.getSigners();

        HealthcareRecords = await ethers.getContractFactory("HealthcareRecords");
        healthcareRecords = await HealthcareRecords.deploy();
        //await healthcareRecords.deployed();

        await healthcareRecords.setInstitution(institution.address);
    });

    it("Should set the institution address correctly", async function () {
        expect(await healthcareRecords.institution()).to.equal(institution.address);
    });

    it("Should allow the institution to register a new patient", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);

        const patient = await healthcareRecords.patients(0);
        expect(patient.name).to.equal("John Doe");
        expect(patient.birthdate).to.equal(1234567890);
        expect(patient.patientAddress).to.equal(patientAccount.address);
        expect(patient.isValid).to.be.true;
    });

    it("Should not allow non-institution to register a new patient", async function () {
        await expect(healthcareRecords.connect(otherAccount).registerPatient("John Doe", 1234567890, patientAccount.address)).to.be.revertedWith("Only institution can manage records");
    });

    it("Should allow the institution to issue a medical record", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);
        await healthcareRecords.connect(institution).issueMedicalRecord(1, "encrypted_data");

        const record = await healthcareRecords.medicalRecords(0);
        expect(record.patientId).to.equal(1);
        expect(record.recordData).to.equal("encrypted_data");
        expect(record.isValid).to.be.true;
    });

    it("Should not allow non-institution to issue a medical record", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);
        await expect(healthcareRecords.connect(otherAccount).issueMedicalRecord(1, "encrypted_data")).to.be.revertedWith("Only institution can manage records");
    });

    it("Should allow the institution to invalidate a medical record", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);
        await healthcareRecords.connect(institution).issueMedicalRecord(1, "encrypted_data");

        await healthcareRecords.connect(institution).invalidateMedicalRecord(1);
        const record = await healthcareRecords.medicalRecords(0);
        expect(record.isValid).to.be.false;
    });

    it("Should not allow non-institution to invalidate a medical record", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);
        await healthcareRecords.connect(institution).issueMedicalRecord(1, "encrypted_data");

        await expect(healthcareRecords.connect(otherAccount).invalidateMedicalRecord(1)).to.be.revertedWith("Only institution can manage records");
    });

    it("Should return all valid medical records", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);
        await healthcareRecords.connect(institution).issueMedicalRecord(1, "encrypted_data");

        const validRecords = await healthcareRecords.getValidMedicalRecords();
        expect(validRecords.length).to.equal(1);
        expect(validRecords[0].recordData).to.equal("encrypted_data");
    });

    it("Should return all invalid medical records", async function () {
        await healthcareRecords.connect(institution).registerPatient("John Doe", 1234567890, patientAccount.address);
        await healthcareRecords.connect(institution).issueMedicalRecord(1, "encrypted_data");
        await healthcareRecords.connect(institution).invalidateMedicalRecord(1);

        const invalidRecords = await healthcareRecords.getInvalidMedicalRecords();
        expect(invalidRecords.length).to.equal(1);
        expect(invalidRecords[0].recordData).to.equal("encrypted_data");
    });
});

-- ============================================================================
-- 1. CORE TABLES
-- ============================================================================

CREATE TABLE STAFF (
    staffNo           VARCHAR2(5)    CONSTRAINT pk_staff PRIMARY KEY,
    fName             VARCHAR2(20)   NOT NULL,
    lName             VARCHAR2(20)   NOT NULL,
    street            VARCHAR2(50)   NOT NULL,
    city              VARCHAR2(25)   NOT NULL,
    province          CHAR(2)        NOT NULL,
    postalCode        VARCHAR2(7)    NOT NULL,
    telNo             VARCHAR2(15)   NOT NULL,
    DOB               DATE           NOT NULL,
    gender            VARCHAR2(10),
    SIN               CHAR(9)        NOT NULL CONSTRAINT uq_staff_sin UNIQUE,
    position          VARCHAR2(30)   NOT NULL,
    currentSalary     NUMBER(10, 2)  NOT NULL CONSTRAINT ck_staff_salary CHECK (currentSalary >= 0),
    reportsToStaffNo  VARCHAR2(5),
    CONSTRAINT fk_staff_manager FOREIGN KEY (reportsToStaffNo)
        REFERENCES STAFF (staffNo)
);

CREATE TABLE QUALIFICATION (
    qualID            VARCHAR2(6)    CONSTRAINT pk_qualification PRIMARY KEY,
    qualType          VARCHAR2(40)   NOT NULL
);

CREATE TABLE ASSEMBLY_LINE (
    lineID                  NUMBER(3)     CONSTRAINT pk_assembly_line PRIMARY KEY,
    lineName                VARCHAR2(30)  NOT NULL,
    supervisorStaffNo       VARCHAR2(5)   NOT NULL CONSTRAINT uq_line_supervisor UNIQUE,
    personnelOfficerStaffNo VARCHAR2(5)   NOT NULL,
    CONSTRAINT fk_line_supervisor FOREIGN KEY (supervisorStaffNo)
        REFERENCES STAFF (staffNo),
    CONSTRAINT fk_line_po FOREIGN KEY (personnelOfficerStaffNo)
        REFERENCES STAFF (staffNo)
);

CREATE TABLE WORKSTATION (
    lineID            NUMBER(3)      NOT NULL,
    workstationNo     NUMBER(3)      NOT NULL,
    stationFunction   VARCHAR2(15)   NOT NULL
        CONSTRAINT ck_ws_function CHECK (stationFunction IN ('Manufacture', 'Assemble')),
    CONSTRAINT pk_workstation PRIMARY KEY (lineID, workstationNo),
    CONSTRAINT fk_ws_line FOREIGN KEY (lineID)
        REFERENCES ASSEMBLY_LINE (lineID) ON DELETE CASCADE
);

CREATE TABLE STAFF_ROTATION (
    rotationID        VARCHAR2(8)    CONSTRAINT pk_staff_rotation PRIMARY KEY,
    weekStartDate     DATE           NOT NULL,
    shiftDate         DATE           NOT NULL,
    workerStaffNo     VARCHAR2(5)    NOT NULL,
    supervisorStaffNo VARCHAR2(5)    NOT NULL,
    lineID            NUMBER(3)      NOT NULL,
    workstationNo     NUMBER(3)      NOT NULL,
    CONSTRAINT ck_rotation_dates CHECK (shiftDate >= weekStartDate),
    CONSTRAINT fk_rot_worker FOREIGN KEY (workerStaffNo)
        REFERENCES STAFF (staffNo),
    CONSTRAINT fk_rot_supervisor FOREIGN KEY (supervisorStaffNo)
        REFERENCES STAFF (staffNo),
    CONSTRAINT fk_rot_workstation FOREIGN KEY (lineID, workstationNo)
        REFERENCES WORKSTATION (lineID, workstationNo)
);

CREATE TABLE PRODUCT (
    productID         VARCHAR2(8)    CONSTRAINT pk_product PRIMARY KEY,
    productName       VARCHAR2(40)   NOT NULL,
    lineID            NUMBER(3)      NOT NULL,
    CONSTRAINT fk_product_line FOREIGN KEY (lineID)
        REFERENCES ASSEMBLY_LINE (lineID)
);

CREATE TABLE REQUISITION (
    reqNo               VARCHAR2(8)  CONSTRAINT pk_requisition PRIMARY KEY,
    reqDate             DATE         DEFAULT SYSDATE NOT NULL,
    lineID              NUMBER(3)    NOT NULL,
    authorizedByStaffNo VARCHAR2(5)  NOT NULL,
    CONSTRAINT fk_req_line FOREIGN KEY (lineID)
        REFERENCES ASSEMBLY_LINE (lineID),
    CONSTRAINT fk_req_supervisor FOREIGN KEY (authorizedByStaffNo)
        REFERENCES STAFF (staffNo)
);

CREATE TABLE STOREHOUSE_ITEM (
    stockNo           VARCHAR2(8)    CONSTRAINT pk_storehouse_item PRIMARY KEY,
    itemType          VARCHAR2(10)   NOT NULL
        CONSTRAINT ck_item_type CHECK (itemType IN ('Material', 'Equipment')),
    description       VARCHAR2(60)   NOT NULL,
    weight            NUMBER(8, 2)   NOT NULL CONSTRAINT ck_item_weight CHECK (weight > 0),
    qtyInStock        NUMBER(6)      NOT NULL CONSTRAINT ck_item_qty CHECK (qtyInStock >= 0),
    reorderLevel      NUMBER(5)      NOT NULL CONSTRAINT ck_item_reorder CHECK (reorderLevel >= 0),
    costPerUnit       NUMBER(10, 2)  NOT NULL CONSTRAINT ck_item_cost CHECK (costPerUnit >= 0)
);

CREATE TABLE EQUIPMENT (
    stockNo           VARCHAR2(8)    CONSTRAINT pk_equipment PRIMARY KEY,
    expectedLife      VARCHAR2(20)   NOT NULL,
    servicingReq      VARCHAR2(100),
    CONSTRAINT fk_equip_item FOREIGN KEY (stockNo)
        REFERENCES STOREHOUSE_ITEM (stockNo) ON DELETE CASCADE
);

CREATE TABLE SUPPLIER (
    supplierNo        VARCHAR2(6)    CONSTRAINT pk_supplier PRIMARY KEY,
    supplierName      VARCHAR2(50)   NOT NULL,
    address           VARCHAR2(100)  NOT NULL,
    email             VARCHAR2(50),
    telNo             VARCHAR2(15)   NOT NULL,
    faxNo             VARCHAR2(15)
);

-- ============================================================================
-- 2. ASSOCIATIVE (BRIDGE) TABLES
-- ============================================================================

CREATE TABLE STAFF_QUALIFICATION (
    staffNo           VARCHAR2(5)    NOT NULL,
    qualID            VARCHAR2(6)    NOT NULL,
    dateAchieved      DATE           NOT NULL,
    institution       VARCHAR2(50)   NOT NULL,
    CONSTRAINT pk_staff_qual PRIMARY KEY (staffNo, qualID),
    CONSTRAINT fk_sq_staff FOREIGN KEY (staffNo)
        REFERENCES STAFF (staffNo) ON DELETE CASCADE,
    CONSTRAINT fk_sq_qual FOREIGN KEY (qualID)
        REFERENCES QUALIFICATION (qualID)
);

CREATE TABLE WORKSTATION_QUALIFICATION (
    qualID            VARCHAR2(6)    NOT NULL,
    lineID            NUMBER(3)      NOT NULL,
    workstationNo     NUMBER(3)      NOT NULL,
    CONSTRAINT pk_ws_qual PRIMARY KEY (qualID, lineID, workstationNo),
    CONSTRAINT fk_wsq_qual FOREIGN KEY (qualID)
        REFERENCES QUALIFICATION (qualID),
    CONSTRAINT fk_wsq_ws FOREIGN KEY (lineID, workstationNo)
        REFERENCES WORKSTATION (lineID, workstationNo) ON DELETE CASCADE
);

CREATE TABLE WORKSTATION_EQUIPMENT (
    lineID            NUMBER(3)      NOT NULL,
    workstationNo     NUMBER(3)      NOT NULL,
    stockNo           VARCHAR2(8)    NOT NULL,
    CONSTRAINT pk_ws_equip PRIMARY KEY (lineID, workstationNo, stockNo),
    CONSTRAINT fk_wse_ws FOREIGN KEY (lineID, workstationNo)
        REFERENCES WORKSTATION (lineID, workstationNo) ON DELETE CASCADE,
    CONSTRAINT fk_wse_equip FOREIGN KEY (stockNo)
        REFERENCES EQUIPMENT (stockNo)
);

CREATE TABLE PRODUCT_REQUIREMENT (
    productID         VARCHAR2(8)    NOT NULL,
    stockNo           VARCHAR2(8)    NOT NULL,
    qtyRequired       NUMBER(5)      NOT NULL CONSTRAINT ck_prod_req_qty CHECK (qtyRequired > 0),
    CONSTRAINT pk_prod_req PRIMARY KEY (productID, stockNo),
    CONSTRAINT fk_pr_product FOREIGN KEY (productID)
        REFERENCES PRODUCT (productID) ON DELETE CASCADE,
    CONSTRAINT fk_pr_item FOREIGN KEY (stockNo)
        REFERENCES STOREHOUSE_ITEM (stockNo)
);

CREATE TABLE REQUISITION_ITEM (
    reqNo             VARCHAR2(8)    NOT NULL,
    stockNo           VARCHAR2(8)    NOT NULL,
    qtyRequested      NUMBER(5)      NOT NULL CONSTRAINT ck_req_item_qty CHECK (qtyRequested > 0),
    CONSTRAINT pk_req_item PRIMARY KEY (reqNo, stockNo),
    CONSTRAINT fk_ri_req FOREIGN KEY (reqNo)
        REFERENCES REQUISITION (reqNo) ON DELETE CASCADE,
    CONSTRAINT fk_ri_item FOREIGN KEY (stockNo)
        REFERENCES STOREHOUSE_ITEM (stockNo)
);

CREATE TABLE SUPPLIER_ITEM (
    supplierNo        VARCHAR2(6)    NOT NULL,
    stockNo           VARCHAR2(8)    NOT NULL,
    CONSTRAINT pk_supplier_item PRIMARY KEY (supplierNo, stockNo),
    CONSTRAINT fk_si_supplier FOREIGN KEY (supplierNo)
        REFERENCES SUPPLIER (supplierNo) ON DELETE CASCADE,
    CONSTRAINT fk_si_item FOREIGN KEY (stockNo)
        REFERENCES STOREHOUSE_ITEM (stockNo) ON DELETE CASCADE
);




-- Foreign Key Indexes (prevents table locks and speeds up joins)
CREATE INDEX idx_staff_manager        ON STAFF (reportsToStaffNo);
CREATE INDEX idx_line_po              ON ASSEMBLY_LINE (personnelOfficerStaffNo);
CREATE INDEX idx_rot_worker           ON STAFF_ROTATION (workerStaffNo);
CREATE INDEX idx_rot_workstation      ON STAFF_ROTATION (lineID, workstationNo);
CREATE INDEX idx_product_line         ON PRODUCT (lineID);
CREATE INDEX idx_req_line             ON REQUISITION (lineID);
CREATE INDEX idx_req_supervisor       ON REQUISITION (authorizedByStaffNo);

-- Frequent Search & Reporting Indexes
CREATE INDEX idx_staff_position       ON STAFF (position);
CREATE INDEX idx_rot_week_shift       ON STAFF_ROTATION (weekStartDate, shiftDate);
CREATE INDEX idx_req_date             ON REQUISITION (reqDate);
CREATE INDEX idx_item_type_stock      ON STOREHOUSE_ITEM (itemType, qtyInStock, reorderLevel);



-- View 1: Personnel Officer — Staff Personal & Payroll Records
CREATE OR REPLACE VIEW vw_PO_Staff_Directory AS
SELECT staffNo, fName, lName, street, city, province, postalCode,
       telNo, DOB, gender, SIN, position, currentSalary
FROM STAFF;

-- View 2: Personnel Officer — Staff Qualifications & Line Eligibility
CREATE OR REPLACE VIEW vw_PO_Staff_Qualifications AS
SELECT s.staffNo, s.fName, s.lName, s.position,
       q.qualType, sq.dateAchieved, sq.institution,
       al.lineID, al.lineName, wq.workstationNo
FROM STAFF s
JOIN STAFF_QUALIFICATION sq ON s.staffNo = sq.staffNo
JOIN QUALIFICATION q        ON sq.qualID = q.qualID
LEFT JOIN WORKSTATION_QUALIFICATION wq ON q.qualID = wq.qualID
LEFT JOIN ASSEMBLY_LINE al  ON wq.lineID = al.lineID;

-- View 3: Line Supervisor — Weekly Assembly Line Staff Rotation
CREATE OR REPLACE VIEW vw_LS_Weekly_Rotation AS
SELECT al.lineID, al.lineName, w.workstationNo, w.stationFunction,
       sr.rotationID, sr.weekStartDate, sr.shiftDate,
       s.staffNo, s.fName, s.lName, s.position
FROM STAFF_ROTATION sr
JOIN STAFF s          ON sr.workerStaffNo = s.staffNo
JOIN WORKSTATION w    ON sr.lineID = w.lineID AND sr.workstationNo = w.workstationNo
JOIN ASSEMBLY_LINE al ON w.lineID = al.lineID;

-- View 4: Line Supervisor — Line Requisitions & Storehouse Stock Availability
CREATE OR REPLACE VIEW vw_LS_Resource_Requisitions AS
SELECT r.reqNo, r.reqDate, al.lineID, al.lineName, r.authorizedByStaffNo,
       si.stockNo, si.itemType, si.description, ri.qtyRequested,
       si.qtyInStock, si.reorderLevel, e.servicingReq
FROM REQUISITION r
JOIN ASSEMBLY_LINE al   ON r.lineID = al.lineID
JOIN REQUISITION_ITEM ri ON r.reqNo = ri.reqNo
JOIN STOREHOUSE_ITEM si ON ri.stockNo = si.stockNo
LEFT JOIN EQUIPMENT e   ON si.stockNo = e.stockNo;

-- View 5: Managing Director — Plant Operations & Resource Cost Summary
CREATE OR REPLACE VIEW vw_MD_Resource_Cost_Summary AS
SELECT al.lineID, al.lineName, al.supervisorStaffNo,
       r.reqNo, r.reqDate, si.stockNo, si.itemType, si.description,
       ri.qtyRequested, si.costPerUnit,
       (ri.qtyRequested * si.costPerUnit) AS totalRequisitionCost
FROM ASSEMBLY_LINE al
JOIN REQUISITION r       ON al.lineID = r.lineID
JOIN REQUISITION_ITEM ri ON r.reqNo = ri.reqNo
JOIN STOREHOUSE_ITEM si  ON ri.stockNo = si.stockNo;

-- View 6: Managing Director — Storehouse Inventory & Supplier Procurement
CREATE OR REPLACE VIEW vw_MD_Inventory_Suppliers AS
SELECT si.stockNo, si.itemType, si.description, si.weight,
       si.qtyInStock, si.reorderLevel, si.costPerUnit,
       e.expectedLife, e.servicingReq,
       sup.supplierNo, sup.supplierName, sup.email, sup.telNo, sup.faxNo
FROM STOREHOUSE_ITEM si
LEFT JOIN EQUIPMENT e      ON si.stockNo = e.stockNo
JOIN SUPPLIER_ITEM sup_i   ON si.stockNo = sup_i.stockNo
JOIN SUPPLIER sup          ON sup_i.supplierNo = sup.supplierNo;



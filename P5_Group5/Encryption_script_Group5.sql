-- ============================================
-- Cloud Kitchen Management System
-- Encryption Script | DAMG 6210 | Group 5
-- ============================================

USE CloudKitchenDB;
GO

-- STEP 1: CREATE DATABASE MASTER KEY
IF NOT EXISTS (
    SELECT 1 FROM sys.symmetric_keys
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'CloudKitchen@Secure2024!';
END
GO


-- STEP 2: CREATE CERTIFICATE

IF NOT EXISTS (
    SELECT 1 FROM sys.certificates
    WHERE name = 'CloudKitchenCert'
)
BEGIN
    CREATE CERTIFICATE CloudKitchenCert
    WITH SUBJECT = 'Cloud Kitchen Data Protection Certificate';
END
GO


-- STEP 3: CREATE SYMMETRIC KEY

IF NOT EXISTS (
    SELECT 1 FROM sys.symmetric_keys
    WHERE name = 'CloudKitchenSymKey'
)
BEGIN
    CREATE SYMMETRIC KEY CloudKitchenSymKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CloudKitchenCert;
END
GO


-- STEP 4: ADD ENCRYPTED COLUMNS
-- Add encrypted column to CUSTOMER for email
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('CUSTOMER')
    AND name = 'email_encrypted'
)
BEGIN
    ALTER TABLE CUSTOMER ADD email_encrypted VARBINARY(256) NULL;
END
GO

-- Add encrypted column to CUSTOMER for phone_number
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('CUSTOMER')
    AND name = 'phone_encrypted'
)
BEGIN
    ALTER TABLE CUSTOMER ADD phone_encrypted VARBINARY(256) NULL;
END
GO

-- Add encrypted column to PAYMENT for transaction_id
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('PAYMENT')
    AND name = 'transaction_id_encrypted'
)
BEGIN
    ALTER TABLE PAYMENT ADD transaction_id_encrypted VARBINARY(256) NULL;
END
GO


-- STEP 5: ENCRYPT EXISTING DATA

OPEN SYMMETRIC KEY CloudKitchenSymKey
DECRYPTION BY CERTIFICATE CloudKitchenCert;
GO

-- Encrypt CUSTOMER.email ? email_encrypted
UPDATE CUSTOMER
SET email_encrypted = EncryptByKey(
    Key_GUID('CloudKitchenSymKey'),
    email
);
GO

-- Encrypt CUSTOMER.phone_number ? phone_encrypted
UPDATE CUSTOMER
SET phone_encrypted = EncryptByKey(
    Key_GUID('CloudKitchenSymKey'),
    phone_number
);
GO

-- Encrypt PAYMENT.transaction_id ? transaction_id_encrypted
-- Only encrypt non-NULL transaction IDs
UPDATE PAYMENT
SET transaction_id_encrypted = EncryptByKey(
    Key_GUID('CloudKitchenSymKey'),
    transaction_id
)
WHERE transaction_id IS NOT NULL;
GO

CLOSE SYMMETRIC KEY CloudKitchenSymKey;
GO


-- STEP 6A: CONFIRM ENCRYPTED VALUES ARE UNREADABLE
-- CUSTOMER: plaintext vs encrypted side by side
SELECT
    customer_id,
    customer_name,
    email                           AS email_plaintext,
    email_encrypted                 AS email_encrypted_binary,
    phone_number                    AS phone_plaintext,
    phone_encrypted                 AS phone_encrypted_binary
FROM CUSTOMER;
GO

-- PAYMENT: plaintext vs encrypted side by side
SELECT
    payment_id,
    order_id,
    payment_status,
    transaction_id                  AS transaction_id_plaintext,
    transaction_id_encrypted        AS transaction_id_encrypted_binary
FROM PAYMENT;
GO



-- STEP 6B: VERIFY DECRYPTION WORKS CORRECTLY
OPEN SYMMETRIC KEY CloudKitchenSymKey
DECRYPTION BY CERTIFICATE CloudKitchenCert;

-- CUSTOMER decryption verification
SELECT
    customer_id,
    customer_name,
    email                                                       AS email_plaintext,
    CAST(DecryptByKey(email_encrypted) AS VARCHAR(150))         AS email_decrypted,
    CASE
        WHEN email = CAST(DecryptByKey(email_encrypted) AS VARCHAR(150))
        THEN 'MATCH' ELSE 'MISMATCH'
    END                                                         AS email_check,
    phone_number                                                AS phone_plaintext,
    CAST(DecryptByKey(phone_encrypted) AS VARCHAR(15))          AS phone_decrypted,
    CASE
        WHEN phone_number = CAST(DecryptByKey(phone_encrypted) AS VARCHAR(15))
        THEN 'MATCH' ELSE 'MISMATCH'
    END                                                         AS phone_check
FROM CUSTOMER;

-- PAYMENT decryption verification
SELECT
    payment_id,
    order_id,
    transaction_id                                               AS transaction_id_plaintext,
    CAST(DecryptByKey(transaction_id_encrypted) AS VARCHAR(100)) AS transaction_id_decrypted,
    CASE
        WHEN transaction_id = CAST(DecryptByKey(transaction_id_encrypted) AS VARCHAR(100))
        THEN 'MATCH' ELSE 'MISMATCH'
    END                                                          AS transaction_check
FROM PAYMENT
WHERE transaction_id IS NOT NULL;

CLOSE SYMMETRIC KEY CloudKitchenSymKey;
GO


-- STEP 7: DROP ORIGINAL PLAINTEXT COLUMNS
-- Drop unique constraints first
IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = 'UQ_CUSTOMER_EMAIL'
    AND parent_object_id = OBJECT_ID('CUSTOMER')
)
    ALTER TABLE CUSTOMER DROP CONSTRAINT UQ_CUSTOMER_EMAIL;
GO

IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = 'UQ_CUSTOMER_PHONE'
    AND parent_object_id = OBJECT_ID('CUSTOMER')
)
    ALTER TABLE CUSTOMER DROP CONSTRAINT UQ_CUSTOMER_PHONE;
GO

-- Drop plaintext email and phone from CUSTOMER
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('CUSTOMER') AND name = 'email'
)
    ALTER TABLE CUSTOMER DROP COLUMN email;
GO

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('CUSTOMER') AND name = 'phone_number'
)
    ALTER TABLE CUSTOMER DROP COLUMN phone_number;
GO

-- Drop plaintext transaction_id from PAYMENT
-- First drop the filtered unique index on transaction_id
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UQ_TRANSACTION_ID'
    AND object_id = OBJECT_ID('PAYMENT')
)
    DROP INDEX UQ_TRANSACTION_ID ON PAYMENT;
GO

IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('PAYMENT') AND name = 'transaction_id'
)
    ALTER TABLE PAYMENT DROP COLUMN transaction_id;
GO


-- STEP 8: HOW TO DECRYPT IN APPLICATION QUERIES
/*
    -- Always open key before decrypting, close after:

    OPEN SYMMETRIC KEY CloudKitchenSymKey
    DECRYPTION BY CERTIFICATE CloudKitchenCert;

    SELECT
        customer_id,
        customer_name,
        CAST(DecryptByKey(email_encrypted)   AS VARCHAR(150)) AS email,
        CAST(DecryptByKey(phone_encrypted)   AS VARCHAR(15))  AS phone_number
    FROM CUSTOMER;

    CLOSE SYMMETRIC KEY CloudKitchenSymKey;
*/
GO

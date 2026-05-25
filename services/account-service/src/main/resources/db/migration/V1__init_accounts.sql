-- V1__init_accounts.sql
--
-- STARTER SCHEMA — see project README "Current state" table.
-- Known shortcuts that will be replaced in later iterations:
--   * cards.card_number stores the raw PAN; will move to encrypted_pan +
--     pan_token columns once HashiCorp Vault transit engine is wired in.
--   * Seed data uses test BIN numbers (Visa 4111…, Mastercard 5555…) that
--     are guaranteed-fake; do NOT replace with real-looking numbers.
--   * Audit columns (created_by, updated_by) and soft-delete are missing
--     intentionally — will arrive with the security layer.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Wallets
CREATE TABLE wallets (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id         VARCHAR(255) NOT NULL,
    wallet_type     VARCHAR(20)  NOT NULL,
    currency        VARCHAR(3)   NOT NULL DEFAULT 'KZT',
    balance         DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    status          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_wallet_type
        CHECK (wallet_type IN ('MAIN', 'SAVINGS', 'DEPOSIT')),
    CONSTRAINT chk_wallet_status
        CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    CONSTRAINT chk_balance_non_negative
        CHECK (balance >= 0)
);

CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_status ON wallets(status);

-- Cards
CREATE TABLE cards (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    wallet_id       UUID         NOT NULL REFERENCES wallets(id),
    -- TODO(vault): replace with encrypted_pan (BYTEA) + pan_token (UUID)
    --              once HashiCorp Vault transit engine is wired in.
    card_number     VARCHAR(16)  NOT NULL,
    card_type       VARCHAR(20)  NOT NULL,
    cardholder_name VARCHAR(100) NOT NULL,
    expiry_date     VARCHAR(5)   NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    is_virtual      BOOLEAN      NOT NULL DEFAULT false,
    daily_limit     DECIMAL(15, 2) DEFAULT 500000.00,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_card_type
        CHECK (card_type IN ('VISA', 'MASTERCARD')),
    CONSTRAINT chk_card_status
        CHECK (status IN ('ACTIVE', 'BLOCKED', 'EXPIRED', 'CLOSED'))
);

CREATE INDEX idx_cards_wallet_id ON cards(wallet_id);
CREATE UNIQUE INDEX idx_cards_number ON cards(card_number);

-- Seed data
INSERT INTO wallets (id, user_id, wallet_type, currency, balance, status)
VALUES
    ('a0000000-0000-0000-0000-000000000001', 'testuser',
     'MAIN', 'KZT', 542870.50, 'ACTIVE'),
    ('a0000000-0000-0000-0000-000000000002', 'testuser',
     'SAVINGS', 'KZT', 1250000.00, 'ACTIVE');

-- Use the official guaranteed-fake test BINs so this seed data is never
-- mistaken for real cards by audits or secret scanners.
INSERT INTO cards (id, wallet_id, card_number, card_type,
                   cardholder_name, expiry_date, status, is_virtual)
VALUES
    ('c0000000-0000-0000-0000-000000000001',
     'a0000000-0000-0000-0000-000000000001',
     '4111111111111111', 'VISA', 'TEST USER', '12/28', 'ACTIVE', false),
    ('c0000000-0000-0000-0000-000000000002',
     'a0000000-0000-0000-0000-000000000001',
     '5555555555554444', 'MASTERCARD', 'TEST USER', '06/29', 'ACTIVE', true);
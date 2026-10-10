-- SanjayMart PostgreSQL schema
-- Run this file once in your Neon SQL Editor for the database used by Render.
-- The statements are safe to re-run for an empty or already initialized schema.
-- Do not add passwords, API keys, or database connection strings to this file.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.users (
    id              SERIAL PRIMARY KEY,
    name            TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    mobile          VARCHAR(10) NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    role            TEXT NOT NULL CHECK (role IN ('BUYER', 'SELLER', 'ADMIN')),
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    otp_hash        TEXT,
    otp_expires_at  TIMESTAMPTZ,
    otp_attempts    INTEGER NOT NULL DEFAULT 0 CHECK (otp_attempts >= 0),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.products (
    id          SERIAL PRIMARY KEY,
    seller_id   INTEGER NOT NULL REFERENCES public.users(id),
    name        TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    category    TEXT NOT NULL DEFAULT 'Other',
    price       NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    stock       INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_url   TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.cart_items (
    id         SERIAL PRIMARY KEY,
    buyer_id   INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cart_items_buyer_product_unique UNIQUE (buyer_id, product_id)
);

CREATE TABLE IF NOT EXISTS public.orders (
    id           SERIAL PRIMARY KEY,
    buyer_id     INTEGER NOT NULL REFERENCES public.users(id),
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    status       TEXT NOT NULL DEFAULT 'PLACED',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id         SERIAL PRIMARY KEY,
    order_id   INTEGER NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES public.products(id),
    seller_id  INTEGER NOT NULL REFERENCES public.users(id),
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    price      NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.product_reviews (
    id         BIGSERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    buyer_id   INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating     INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT product_reviews_product_buyer_unique UNIQUE (product_id, buyer_id)
);

CREATE INDEX IF NOT EXISTS products_seller_id_idx ON public.products(seller_id);
CREATE INDEX IF NOT EXISTS cart_items_buyer_id_idx ON public.cart_items(buyer_id);
CREATE INDEX IF NOT EXISTS orders_buyer_id_idx ON public.orders(buyer_id);
CREATE INDEX IF NOT EXISTS order_items_order_id_idx ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS order_items_seller_id_idx ON public.order_items(seller_id);
CREATE INDEX IF NOT EXISTS product_reviews_product_id_idx ON public.product_reviews(product_id);

-- Verification: this should list users, products, cart_items, orders,
-- order_items, and product_reviews in the public schema.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('users', 'products', 'cart_items', 'orders', 'order_items', 'product_reviews')
ORDER BY table_name;

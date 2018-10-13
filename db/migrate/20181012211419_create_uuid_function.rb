ROM::SQL.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
    run %{
      CREATE OR REPLACE FUNCTION public.set_uniq_id() RETURNS trigger
        LANGUAGE plpgsql
        AS $$ BEGIN
          IF (TG_OP = 'UPDATE') THEN
            NEW."id" := OLD."id";
          ELSIF (TG_OP = 'INSERT') THEN
            NEW."id" := concat(uuid_generate_v4(), '-', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 100000);
          END IF;
          RETURN NEW;
        END;
      $$;
    }
  end

  down do
    run 'DROP FUNCTION IF EXISTS public.set_uniq_id();'
    run 'DROP EXTENSION IF EXISTS "uuid-ossp"'
  end
end

// Configuración del proyecto de Supabase del CRM.
// La "anon key" es pública por diseño: los datos los protege el login
// y las políticas de seguridad (RLS) definidas en setup.sql.
window.CRM_CONFIG = {
  url: "PEGAR_URL_DEL_PROYECTO",      // ej.: https://abcdxyz.supabase.co
  anonKey: "PEGAR_ANON_PUBLIC_KEY"    // Project Settings › API › anon public
};

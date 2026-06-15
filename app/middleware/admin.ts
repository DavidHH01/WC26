export default defineNuxtRouteMiddleware(async () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  if (!user.value) return navigateTo('/auth/login')

  const { data } = await supabase
    .from('profiles')
    .select('is_admin')
    .eq('id', user.value.id)
    .single()

  if (!(data as any)?.is_admin) return navigateTo('/')
})

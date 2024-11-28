<template>
  <div class="lg:hidden mb-6 bg-white dark:bg-gray-800 rounded-lg shadow-md dark:shadow-gray-900">
    <nav class="flex justify-around">
      <a
        href="/"
        class="flex-1 px-4 py-3 text-center text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-brand-primary dark:hover:text-brand-primary border-b-2 border-transparent hover:border-brand-primary"
        :class="{ 'text-brand-primary dark:text-brand-primary border-brand-primary': currentPath === '/' }"
      >
        Dashboard
      </a>
      <a
        href="/bookmarks"
        class="flex-1 px-4 py-3 text-center text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-brand-primary dark:hover:text-brand-primary border-b-2 border-transparent hover:border-brand-primary"
        :class="{ 'text-brand-primary dark:text-brand-primary border-brand-primary': currentPath === '/bookmarks' }"
      >
        Bookmarks
      </a>
      <a
        href="/tags"
        class="flex-1 px-4 py-3 text-center text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-brand-primary dark:hover:text-brand-primary border-b-2 border-transparent hover:border-brand-primary"
        :class="{ 'text-brand-primary dark:text-brand-primary border-brand-primary': currentPath === '/tags' }"
      >
        Tags
      </a>
    </nav>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const currentPath = ref('')

onMounted(() => {
  currentPath.value = window.location.pathname
})
</script>

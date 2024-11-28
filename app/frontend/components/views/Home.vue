<template>
  <div class="px-3 sm:px-6">
    <MobileNav />
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl sm:text-3xl font-semibold text-gray-900">Dashboard</h1>
        <p class="mt-2 text-sm sm:text-base text-gray-700">
          Welcome to your bookmark manager. Here's an overview of your saved links and tags.
        </p>
      </div>
    </div>

    <div class="mt-4 sm:mt-8 grid grid-cols-1 gap-4 sm:gap-6 sm:grid-cols-2 lg:grid-cols-3">
      <!-- Recent Bookmarks -->
      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-3 sm:p-5">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <BookmarkIcon class="h-5 w-5 sm:h-6 sm:w-6 text-gray-400" />
            </div>
            <div class="ml-2 sm:ml-5 w-0 flex-1">
              <dl>
                <dt class="text-sm font-medium text-gray-500 truncate">Bookmarks</dt>
                <dd class="flex items-baseline">
                  <div class="text-xl sm:text-2xl font-semibold text-gray-900">{{ bookmarks.length }}</div>
                </dd>
              </dl>
            </div>
          </div>
        </div>
        <div class="bg-gray-50 px-3 sm:px-5 py-2">
          <div class="text-sm">
            <a href="/bookmarks" class="font-medium text-brand-primary hover:text-brand-secondary"> View all </a>
          </div>
        </div>
      </div>

      <!-- Tags -->
      <div class="bg-white overflow-hidden shadow rounded-lg">
        <div class="p-3 sm:p-5">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <TagIcon class="h-5 w-5 sm:h-6 sm:w-6 text-gray-400" />
            </div>
            <div class="ml-2 sm:ml-5 w-0 flex-1">
              <dl>
                <dt class="text-sm font-medium text-gray-500 truncate">Tags</dt>
                <dd class="flex items-baseline">
                  <div class="text-xl sm:text-2xl font-semibold text-gray-900">{{ tags.length }}</div>
                </dd>
              </dl>
            </div>
          </div>
        </div>
        <div class="bg-gray-50 px-3 sm:px-5 py-2">
          <div class="text-sm">
            <a href="/tags" class="font-medium text-brand-primary hover:text-brand-secondary"> View all </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { BookmarkIcon, TagIcon } from '@heroicons/vue/24/outline/index.js'
import MobileNav from '../shared/MobileNav.vue'

const bookmarks = ref([])
const tags = ref([])

const fetchData = () => {
  try {
    const homeElement = document.getElementById('home')
    if (homeElement) {
      // Get bookmarks from data attribute
      const bookmarksData = homeElement.dataset.bookmarks
      bookmarks.value = bookmarksData ? JSON.parse(bookmarksData) : []

      // Get tags from data attribute
      const tagsData = homeElement.dataset.tags
      tags.value = tagsData ? JSON.parse(tagsData) : []
    }
  } catch (error) {
    console.error('Error parsing dashboard data:', error)
  }
}

onMounted(() => {
  fetchData()
})
</script>

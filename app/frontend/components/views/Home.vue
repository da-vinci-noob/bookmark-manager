<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    <MobileNav />
    <main class="container mx-auto px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center min-h-screen py-12">
      <div class="w-full max-w-4xl">
        <div class="text-center">
          <h1 class="text-4xl font-bold text-gray-900 dark:text-white sm:text-5xl md:text-6xl">
            Welcome to Bookmark Manager
          </h1>
          <p class="mt-3 text-base text-gray-500 dark:text-gray-400 sm:text-lg md:mt-5 md:text-xl">
            Organize and manage your bookmarks efficiently
          </p>
          <div class="mt-8 flex justify-center">
            <div class="rounded-md shadow">
              <a
                href="/bookmarks"
                class="w-full flex items-center justify-center px-8 py-3 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 dark:bg-indigo-500 dark:hover:bg-indigo-600 md:py-4 md:text-lg md:px-10"
              >
                View Bookmarks
              </a>
            </div>
          </div>

          <!-- Stats Section -->
          <div class="mt-12 w-full">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:gap-8 px-4 sm:px-0">
              <!-- Bookmarks stat -->
              <div
                class="bg-white dark:bg-gray-800 overflow-hidden shadow-lg rounded-lg transition-all duration-300 hover:shadow-xl"
              >
                <div class="p-6 sm:p-8">
                  <div class="flex items-center justify-center sm:justify-start">
                    <div class="flex-shrink-0">
                      <BookmarkIcon class="h-8 w-8 text-indigo-600 dark:text-indigo-400" aria-hidden="true" />
                    </div>
                    <div class="ml-5">
                      <dl>
                        <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Bookmarks</dt>
                        <dd class="mt-1 flex items-baseline justify-center sm:justify-start">
                          <div class="text-3xl font-semibold text-gray-900 dark:text-white">{{ bookmarks.length }}</div>
                        </dd>
                      </dl>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Tags stat -->
              <div
                class="bg-white dark:bg-gray-800 overflow-hidden shadow-lg rounded-lg transition-all duration-300 hover:shadow-xl"
              >
                <div class="p-6 sm:p-8">
                  <div class="flex items-center justify-center sm:justify-start">
                    <div class="flex-shrink-0">
                      <TagIcon class="h-8 w-8 text-indigo-600 dark:text-indigo-400" aria-hidden="true" />
                    </div>
                    <div class="ml-5">
                      <dl>
                        <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Tags</dt>
                        <dd class="mt-1 flex items-baseline justify-center sm:justify-start">
                          <div class="text-3xl font-semibold text-gray-900 dark:text-white">{{ tags.length }}</div>
                        </dd>
                      </dl>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
    <ThemeToggle class="fixed bottom-4 right-4" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { BookmarkIcon, TagIcon } from '@heroicons/vue/24/outline/index.js'
import MobileNav from '../shared/MobileNav.vue'
import ThemeToggle from '../shared/ThemeToggle.vue'

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

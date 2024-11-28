<template>
  <div class="container mx-auto px-4 py-8 flex">
    <!-- Sidebar -->
    <div class="w-64 flex-shrink-0 pr-6">
      <div class="bg-white rounded-lg shadow-md p-4 mb-4">
        <h2 class="text-lg font-semibold mb-3">Statistics</h2>
        <div class="space-y-2">
          <div class="flex justify-between items-center">
            <span class="text-gray-600">Total Bookmarks</span>
            <span class="font-medium">{{ totalBookmarks }}</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-gray-600">Total Tags</span>
            <span class="font-medium">{{ availableTags.length }}</span>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md p-4 mb-4">
        <h2 class="text-lg font-semibold mb-3">Filter by Tags</h2>
        <div class="space-y-2">
          <div class="mb-3">
            <span class="text-sm text-gray-600">
              {{ selectedTags.length ? `${selectedTags.length} tags selected` : 'No tags selected' }}
            </span>
          </div>
          <div
            v-for="tag in availableTags"
            :key="tag.id"
            @click="toggleTagFilter(tag.id)"
            class="flex items-center justify-between p-2 rounded hover:bg-gray-50 cursor-pointer transition-colors duration-200"
            :class="{ 'bg-gray-100': selectedTags.includes(tag.id) }"
            :style="{ backgroundColor: selectedTags.includes(tag.id) ? `${tag.color}16` : '' }"
          >
            <div class="flex items-center space-x-2">
              <span class="w-3 h-3 rounded-full" :style="{ backgroundColor: tag.color || '#94a3b8' }"></span>
              <span class="text-gray-700">{{ tag.name }}</span>
            </div>
            <div class="flex items-center space-x-2">
              <span class="text-sm text-gray-500">{{ getBookmarkCountByTag(tag.id) }}</span>
              <div v-if="selectedTags.includes(tag.id)" class="w-2 h-2 rounded-full bg-blue-500"></div>
            </div>
          </div>
          <button
            @click="showUntaggedOnly"
            class="w-full p-2 text-left rounded hover:bg-gray-50 cursor-pointer transition-colors duration-200"
            :class="{ 'bg-gray-100': isShowingUntagged }"
          >
            Show Untagged
          </button>
          <div class="flex justify-between items-center mb-3">
            <button @click="clearTagFilters" class="text-sm text-blue-600 hover:text-blue-800">
              Clear All Filters
            </button>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md p-4">
        <h2 class="text-lg font-semibold mb-3">Quick Actions</h2>
        <div class="space-y-2">
          <div class="flex flex-col space-y-2 mb-2">
            <button
              @click="sortBookmarks('date')"
              class="px-3 py-2 rounded hover:bg-gray-100 flex justify-between"
              :class="{ 'bg-gray-100': currentSort.field === 'date' }"
            >
              <span>Sort by Date</span>
              <span class="text-gray-500">{{ getSortIndicator('date') }}</span>
            </button>
            <button
              @click="sortBookmarks('title')"
              class="px-3 py-2 rounded hover:bg-gray-100 flex justify-between"
              :class="{ 'bg-gray-100': currentSort.field === 'title' }"
            >
              <span>Sort by Title</span>
              <span class="text-gray-500">{{ getSortIndicator('title') }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="flex-1">
      <div class="flex justify-between items-center mb-6">
        <div>
          <h1 class="text-2xl font-bold">Bookmarks</h1>
          <p v-if="errorMessage" class="text-red-600 text-sm mt-2">{{ errorMessage }}</p>
        </div>
        <button
          @click="(showModal = true), (isEditing = false)"
          class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Add Bookmark
        </button>
      </div>

      <!-- Search Box -->
      <div class="mb-6">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search bookmarks by title, description, or tags..."
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <!-- Bookmark Grid -->
      <div class="mt-8">
        <div v-if="displayedBookmarks.length === 0" class="text-center py-8">
          <p class="text-gray-500 text-lg">No bookmarks found</p>
          <p v-if="selectedTags.length > 0" class="text-gray-400 mt-2">Try removing some tag filters</p>
          <p v-if="searchQuery" class="text-gray-400 mt-2">Try modifying your search query</p>
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="bookmark in displayedBookmarks"
            :key="bookmark.id"
            class="bg-white rounded-lg shadow-md overflow-hidden"
          >
            <!-- Thumbnail -->
            <div class="aspect-w-16 aspect-h-9">
              <img
                v-if="bookmark.thumbnail_url"
                :src="bookmark.thumbnail_url"
                :alt="bookmark.title"
                class="w-full h-48 object-cover"
                @error="handleImageError"
              />
              <div v-else class="w-full h-48 bg-gray-200 flex items-center justify-center">
                <DocumentIcon class="h-12 w-12 text-gray-400" />
              </div>
            </div>

            <!-- Content -->
            <div class="p-4">
              <h3 class="text-lg font-semibold mb-2 line-clamp-2">
                {{ bookmark.title || 'Untitled' }}
              </h3>
              <p class="text-gray-600 text-sm mb-3 line-clamp-3">
                {{ bookmark.description || 'No description available' }}
              </p>
              <!-- Tags -->
              <div class="mt-2 flex flex-wrap gap-2">
                <span
                  v-for="tag in bookmark.tags"
                  :key="tag.id"
                  class="inline-flex items-center px-2 py-1 rounded-full text-sm"
                  :style="{
                    backgroundColor: `${tag.color || '#94a3b8'}16`,
                    color: tag.color || '#64748b'
                  }"
                >
                  <span class="w-2 h-2 rounded-full mr-1.5" :style="{ backgroundColor: tag.color || '#94a3b8' }"></span>
                  {{ tag.name }}
                </span>
              </div>
              <div class="flex items-center justify-between">
                <a
                  :href="bookmark.url"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-blue-600 hover:text-blue-800 text-sm"
                >
                  Visit Site →
                </a>
                <div class="flex space-x-2">
                  <button @click="openEditModal(bookmark)" class="text-gray-600 hover:text-gray-800">
                    <PencilIcon class="h-5 w-5" />
                  </button>
                  <button @click="deleteBookmark(bookmark.id)" class="text-red-600 hover:text-red-800">
                    <TrashIcon class="h-5 w-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal -->
      <TransitionRoot appear :show="showModal" as="template">
        <Dialog as="div" @close="closeModal" class="relative z-10">
          <TransitionChild
            as="template"
            enter="duration-300 ease-out"
            enter-from="opacity-0"
            enter-to="opacity-100"
            leave="duration-200 ease-in"
            leave-from="opacity-100"
            leave-to="opacity-0"
          >
            <div class="fixed inset-0 bg-black bg-opacity-25" />
          </TransitionChild>

          <div class="fixed inset-0 overflow-y-auto">
            <div class="flex min-h-full items-center justify-center p-4">
              <TransitionChild
                as="template"
                enter="duration-300 ease-out"
                enter-from="opacity-0 scale-95"
                enter-to="opacity-100 scale-100"
                leave="duration-200 ease-in"
                leave-from="opacity-100 scale-100"
                leave-to="opacity-0 scale-95"
              >
                <DialogPanel
                  class="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all"
                >
                  <DialogTitle as="h3" class="text-lg font-medium leading-6 text-gray-900">
                    {{ isEditing ? 'Edit Bookmark' : 'Add New Bookmark' }}
                  </DialogTitle>

                  <form @submit.prevent="submitBookmark" class="mt-4 space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700">URL</label>
                      <input
                        v-model="currentBookmark.url"
                        @blur="fetchThumbnail"
                        type="url"
                        required
                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700">Title</label>
                      <input
                        v-model="currentBookmark.title"
                        type="text"
                        required
                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700">Description</label>
                      <textarea
                        v-model="currentBookmark.description"
                        rows="3"
                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      ></textarea>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700">Tags</label>
                      <div class="mt-1 flex flex-wrap gap-2">
                        <div v-for="tag in availableTags" :key="tag.id" class="flex items-center">
                          <input
                            type="checkbox"
                            :id="'tag-' + tag.id"
                            :value="tag.id"
                            v-model="currentBookmark.tag_ids"
                            class="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                          />
                          <label :for="'tag-' + tag.id" class="ml-2 text-sm text-gray-600">
                            {{ tag.name }}
                          </label>
                        </div>
                      </div>
                    </div>
                    <p v-if="errorMessage" class="text-red-600 text-sm mt-2">{{ errorMessage }}</p>
                    <div class="mt-6 flex justify-end space-x-3">
                      <button
                        type="button"
                        @click="closeModal"
                        class="rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        class="rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                      >
                        {{ isEditing ? 'Save Changes' : 'Add Bookmark' }}
                      </button>
                    </div>
                  </form>
                </DialogPanel>
              </TransitionChild>
            </div>
          </div>
        </Dialog>
      </TransitionRoot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { Dialog, DialogPanel, DialogTitle, TransitionChild, TransitionRoot } from '@headlessui/vue'
import { DocumentIcon, PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'

interface Tag {
  id: number
  name: string
  color: string
}

interface Bookmark {
  id?: number
  url: string
  title: string
  description?: string
  thumbnail_url?: string
  tags?: Tag[]
  tag_ids?: number[]
  created_at: string
}

const bookmarks = ref<any[]>([])
const showModal = ref(false)
const isEditing = ref(false)
const searchQuery = ref('')
const selectedTags = ref<number[]>([])
const currentBookmark = ref<Bookmark>({
  url: '',
  title: '',
  description: '',
  thumbnail_url: '',
  tag_ids: [],
  created_at: new Date().toISOString()
})
const availableTags = ref<any[]>([])
const isShowingUntagged = ref(false)
const currentSort = ref({
  field: 'date',
  direction: 'desc'
})
const errorMessage = ref('')

const filteredBookmarks = computed(() => {
  let result = [...bookmarks.value]

  if (isShowingUntagged.value) {
    result = result.filter((bookmark) => !bookmark.tags || bookmark.tags.length === 0)
  } else if (selectedTags.value.length > 0) {
    result = result.filter((bookmark) => bookmark.tags?.some((tag) => selectedTags.value.includes(tag.id)))
  }

  return result
})

const searchFilteredBookmarks = computed(() => {
  if (!searchQuery.value) return filteredBookmarks.value

  const query = searchQuery.value.toLowerCase()
  return filteredBookmarks.value.filter(
    (bookmark) =>
      bookmark.title?.toLowerCase().includes(query) ||
      bookmark.description?.toLowerCase().includes(query) ||
      bookmark.tags?.some((tag) => tag.name.toLowerCase().includes(query))
  )
})

const displayedBookmarks = computed(() => {
  return searchFilteredBookmarks.value
})

const totalBookmarks = computed(() => bookmarks.value.length)

const getBookmarkCountByTag = (tagId: number) => {
  if (!Array.isArray(bookmarks.value)) return 0
  return bookmarks.value.filter((bookmark) => bookmark.tags?.some((tag) => tag.id === tagId)).length
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  img.src = '/placeholder.png'
}

const openEditModal = (bookmark: Bookmark) => {
  currentBookmark.value = {
    ...bookmark,
    tag_ids: bookmark.tags?.map((tag) => tag.id) || []
  }
  isEditing.value = true
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  currentBookmark.value = {
    url: '',
    title: '',
    description: '',
    thumbnail_url: '',
    tag_ids: [],
    created_at: new Date().toISOString()
  }
  isEditing.value = false
  errorMessage.value = ''
}

const submitBookmark = async () => {
  try {
    errorMessage.value = ''
    const bookmarkData = {
      bookmark: {
        url: currentBookmark.value.url,
        title: currentBookmark.value.title,
        description: currentBookmark.value.description,
        thumbnail_url: currentBookmark.value.thumbnail_url,
        tag_ids: currentBookmark.value.tag_ids
      }
    }

    var method = 'POST'
    var url = '/bookmarks'

    if (isEditing.value && currentBookmark.value.id) {
      method = 'PUT'
      url = `/bookmarks/${currentBookmark.value.id}`
    }

    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
      },
      body: JSON.stringify(bookmarkData)
    })

    if (!response.ok) {
      const data = await response.json()
      throw new Error(data.error || 'Failed to save bookmark')
    }

    await fetchData()
    closeModal()
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while saving the bookmark'
  }
}

const fetchThumbnail = async () => {
  try {
    errorMessage.value = ''
    if (!currentBookmark.value.url) return

    const response = await fetch(`/bookmarks/fetch_thumbnail?url=${encodeURIComponent(currentBookmark.value.url)}`)
    if (!response.ok) throw new Error('Failed to fetch thumbnail')

    const data = await response.json()
    currentBookmark.value.title = data.title || currentBookmark.value.title
    currentBookmark.value.description = data.description || currentBookmark.value.description
    currentBookmark.value.thumbnail_url = data.thumbnail_url || ''
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while fetching the thumbnail'
  }
}

const deleteBookmark = async (id: number) => {
  try {
    errorMessage.value = ''
    if (!confirm('Are you sure you want to delete this bookmark?')) return

    const response = await fetch(`/bookmarks/${id}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
      }
    })

    if (!response.ok) {
      const data = await response.json()
      throw new Error(data.error || 'Failed to delete bookmark')
    }

    await fetchData()
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while deleting the bookmark'
  }
}

const toggleTagFilter = (tagId: number) => {
  const index = selectedTags.value.indexOf(tagId)
  if (index > -1) {
    selectedTags.value = []
  } else {
    selectedTags.value = [tagId]
  }
  isShowingUntagged.value = false
}

const clearTagFilters = () => {
  selectedTags.value = []
  isShowingUntagged.value = false
}

const showUntaggedOnly = () => {
  selectedTags.value = []
  isShowingUntagged.value = !isShowingUntagged.value
}

const sortBookmarks = (sortBy: string) => {
  // Toggle direction if clicking the same field
  if (sortBy === currentSort.value.field) {
    currentSort.value.direction = currentSort.value.direction === 'asc' ? 'desc' : 'asc'
  } else {
    currentSort.value.field = sortBy
    // Default to ascending for title, descending for date
    currentSort.value.direction = sortBy === 'title' ? 'asc' : 'desc'
  }

  const direction = currentSort.value.direction === 'asc' ? 1 : -1

  if (sortBy === 'date') {
    bookmarks.value.sort((a, b) => {
      const dateA = new Date(a.created_at).getTime()
      const dateB = new Date(b.created_at).getTime()
      return (dateA - dateB) * direction
    })
  } else if (sortBy === 'title') {
    bookmarks.value.sort((a, b) => {
      const titleA = (a.title || '').toLowerCase()
      const titleB = (b.title || '').toLowerCase()
      return titleA.localeCompare(titleB) * direction
    })
  }
}

const getSortIndicator = (field: string) => {
  if (currentSort.value.field !== field) return ''
  return currentSort.value.direction === 'asc' ? '↑' : '↓'
}

const fetchData = async () => {
  try {
    errorMessage.value = ''
    const params: Record<string, any> = {}

    if (searchQuery.value) {
      params.query = searchQuery.value
    }

    if (isShowingUntagged.value) {
      params.untagged = 'true'
    } else if (selectedTags.value.length > 0) {
      params.tag_ids = selectedTags.value.join(',')
    }

    const response = await fetch(`/bookmarks.json?${new URLSearchParams(params)}`, {
      headers: {
        Accept: 'application/json'
      }
    })
    if (!response.ok) throw new Error('Failed to fetch bookmarks')

    const data = await response.json()
    bookmarks.value = data.bookmarks || []
    availableTags.value = data.tags || []
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while fetching bookmarks'
  }
}

const fetchTags = () => {
  try {
    errorMessage.value = ''
    const tagsElement = document.getElementById('tags')
    if (tagsElement) {
      // Get Tags from data attribute
      const tagsData = tagsElement.dataset.bookmarks
      availableTags.value = tagsData ? JSON.parse(tagsData) : []
    }
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while fetching tags'
  }
}

onMounted(async () => {
  await Promise.all([fetchData(), fetchTags()])
})
</script>

<style scoped>
.aspect-w-16.aspect-h-9 {
  position: relative;
  padding-bottom: 56.25%;
}

.aspect-w-16.aspect-h-9 img,
.aspect-w-16.aspect-h-9 div {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>

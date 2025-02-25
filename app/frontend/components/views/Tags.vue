<template>
  <div class="px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
    <MobileNav />
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-xl sm:text-2xl font-semibold text-gray-900 dark:text-white">Tags</h1>
        <p class="mt-2 text-sm text-gray-700 dark:text-gray-300">Manage your bookmark tags and their colors.</p>
      </div>
      <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
        <button
          type="button"
          class="w-full sm:w-auto inline-flex items-center justify-center rounded-md border border-transparent bg-brand-primary dark:bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-brand-primary focus:ring-offset-2 dark:focus:ring-offset-gray-800"
          @click="showAddTag = true"
        >
          Add Tag
        </button>
      </div>
    </div>

    <!-- Tags List -->
    <div class="mt-6 sm:mt-8">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle">
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 dark:ring-white dark:ring-opacity-10 sm:rounded-lg">
            <!-- Mobile View -->
            <div class="sm:hidden">
              <div class="divide-y divide-gray-200 dark:divide-gray-700 bg-white dark:bg-gray-800">
                <div v-for="tag in availableTags" :key="tag.id" class="p-4">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                      <div class="h-5 w-5 rounded-full" :style="{ backgroundColor: tag.color }"></div>
                      <span class="font-medium text-gray-900 dark:text-white">{{ tag.name }}</span>
                    </div>
                    <div class="flex items-center space-x-4">
                      <span class="text-sm text-gray-500 dark:text-gray-400">{{ tag.bookmarks.length || 0 }} bookmarks</span>
                      <div class="flex space-x-2">
                        <button
                          type="button"
                          class="text-brand-primary hover:text-brand-secondary"
                          @click="editTag(tag)"
                        >
                          Edit
                        </button>
                        <button
                          type="button"
                          class="text-red-600 hover:text-red-900"
                          @click="deleteTag(tag.id)"
                        >
                          Delete
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Desktop View -->
            <table class="hidden sm:table min-w-full divide-y divide-gray-300 dark:divide-gray-700">
              <thead class="bg-gray-50 dark:bg-gray-900">
                <tr>
                  <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 dark:text-white sm:pl-6">
                    Name
                  </th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-white">Color</th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-white">Bookmarks</th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
                    <span class="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 dark:divide-gray-700 bg-white dark:bg-gray-800">
                <tr v-for="tag in availableTags" :key="tag.id">
                  <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 dark:text-white sm:pl-6">
                    {{ tag.name }}
                  </td>
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400">
                    <div class="flex items-center">
                      <div class="h-6 w-6 rounded-full mr-2" :style="{ backgroundColor: tag.color }"></div>
                      {{ tag.color }}
                    </div>
                  </td>
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400">
                    {{ tag.bookmarks.length || 0 }}
                  </td>
                  <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                    <button
                      type="button"
                      class="text-brand-primary hover:text-brand-secondary mr-4"
                      @click="editTag(tag)"
                    >
                      Edit
                    </button>
                    <button type="button" class="text-red-600 hover:text-red-900" @click="deleteTag(tag.id)">
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Tag Modal -->
    <div v-if="showAddTag" class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 flex items-center justify-center p-4">
      <div class="bg-white dark:bg-gray-800 rounded-lg p-4 sm:p-6 max-w-lg w-full">
        <h2 class="text-lg font-medium text-gray-900 dark:text-white">{{ editingTag ? 'Edit Tag' : 'Add New Tag' }}</h2>
        <form @submit.prevent="submitTag" class="mt-4 space-y-4">
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Name</label>
            <input
              type="text"
              id="name"
              v-model="newTag.name"
              required
              class="mt-1 block w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-brand-primary focus:ring-brand-primary dark:focus:ring-blue-500 sm:text-sm"
            />
          </div>
          <div>
            <label for="color" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Color</label>
            <input
              type="color"
              id="color"
              v-model="newTag.color"
              required
              class="mt-1 block w-full h-10 rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 shadow-sm focus:border-brand-primary focus:ring-brand-primary dark:focus:ring-blue-500 sm:text-sm"
            />
          </div>
          <p v-if="errorMessage" class="text-red-600 text-sm mt-2">{{ errorMessage }}</p>
          <div class="mt-5 sm:mt-6 flex space-x-3">
            <button
              type="submit"
              class="inline-flex justify-center rounded-md border border-transparent bg-brand-primary dark:bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-brand-primary focus:ring-offset-2 dark:focus:ring-offset-gray-800 sm:w-auto"
            >
              Save
            </button>
            <button
              type="button"
              class="inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 shadow-sm hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-brand-primary focus:ring-offset-2 dark:focus:ring-offset-gray-800 sm:w-auto"
              @click="cancelTagEdit"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
  <ThemeToggle class="fixed bottom-4 right-4" />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import MobileNav from '../shared/MobileNav.vue'
import ThemeToggle from '../shared/ThemeToggle.vue'

const showAddTag = ref(false)
const availableTags = ref([])
const editingTag = ref(null)
const errorMessage = ref('')

const newTag = ref({
  name: '',
  color: '#3B82F6'
})

const resetNewTag = (tagName = '', tagColor = '#3B82F6') => {
  newTag.value.name = tagName
  newTag.value.color = tagColor
}

const editTag = (tag) => {
  errorMessage.value = '' // Clear error when starting edit
  editingTag.value = tag
  resetNewTag(tag.name, tag.color)
  showAddTag.value = true
}

const cancelTagEdit = () => {
  errorMessage.value = '' // Clear error when canceling
  editingTag.value = null
  resetNewTag()
  showAddTag.value = false
}

const submitTag = async () => {
  try {
    errorMessage.value = '' // Clear error before submitting
    const tagData = {
      tag: {
        name: newTag.value.name,
        color: newTag.value.color
      }
    }

    var method = 'POST'
    var url = '/tags'

    if (showAddTag.value && editingTag?.value?.id) {
      method = 'PUT'
      url = `/tags/${editingTag.value.id}`
    }
    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
      },
      body: JSON.stringify(tagData)
    })
    if (!response.ok) {
      const data = await response.json()
      throw new Error(data.error || 'Failed to save bookmark')
    }
    await fetchTags()
    resetNewTag()
    showAddTag.value = false
    editingTag.value = null
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while saving the tag'
  }
}

const deleteTag = async (id) => {
  if (!confirm('Are you sure you want to delete this tag?')) return

  try {
    errorMessage.value = '' // Clear error before deleting
    const response = await fetch(`/tags/${id}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
      }
    })
    if (!response.ok) {
      const data = await response.json()
      throw new Error(data.error || 'Failed to delete tag')
    }
    await fetchTags()
  } catch (err) {
    errorMessage.value = err.message || 'An error occurred while deleting the tag'
  }
}

// Fetch initial data
const fetchTags = async () => {
  try {
    const response = await fetch(`/tags.json`, {
      headers: {
        Accept: 'application/json'
      }
    })
    if (!response.ok) throw new Error('Failed to fetch tags')
    availableTags.value = await response.json()
  } catch (err) {
    console.error('Error fetching tags:', err)
  }
}

onMounted(async () => {
  await fetchTags()
})
</script>

export const useMetaTags = () => {
  const updateMetaTags = (data) => {
    const { title, description, url } = data

    document.title = title || 'splitmybills'

    const metaTags = [
      { property: 'og:title', content: title },
      { property: 'og:description', content: description },
      { property: 'og:url', content: url },
      { name: 'twitter:title', content: title },
      { name: 'twitter:description', content: description }
    ]

    metaTags.forEach(({ property, name, content }) => {
      if (!content) return

      const selector = property ? `meta[property="${property}"]` : `meta[name="${name}"]`
      let tag = document.querySelector(selector)

      if (!tag) {
        tag = document.createElement('meta')
        if (property) tag.setAttribute('property', property)
        if (name) tag.setAttribute('name', name)
        document.head.appendChild(tag)
      }

      tag.setAttribute('content', content)
    })
  }

  const resetMetaTags = () => {
    document.title = 'splitmybills'

    const defaultTags = [
      { property: 'og:title', content: 'splitmybills - Split Bills Made Easy' },
      { property: 'og:description', content: 'Easily split bills and track payments with friends' },
      { name: 'twitter:title', content: 'splitmybills - Split Bills Made Easy' },
      { name: 'twitter:description', content: 'Easily split bills and track payments with friends' }
    ]

    defaultTags.forEach(({ property, name, content }) => {
      const selector = property ? `meta[property="${property}"]` : `meta[name="${name}"]`
      const tag = document.querySelector(selector)
      if (tag) {
        tag.setAttribute('content', content)
      }
    })
  }

  return {
    updateMetaTags,
    resetMetaTags
  }
}

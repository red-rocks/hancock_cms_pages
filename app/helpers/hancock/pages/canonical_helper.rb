module Hancock::Pages::CanonicalHelper
  def hancock_canonical_tag(url = "")
    return if url.blank?
    tag(:link, href: url, rel: :canonical)
  end

  def hancock_canonical_tag_for(obj)
    return if obj.use_hancock_canonicalable
    url = obj.hancock_canonicalable_url
    url = url_for(obj.hancock_canonicalable) if !url.blank? and obj.hancock_canonicalable
    hancock_canonical_tag(url) if url.blank?
  end
end

module Hancock::Pages::CanonicalHelper
  def hancock_canonical_tag(url = "")
    return if url.blank?
    tag(:link, href: url, rel: :canonical)
  end

  def hancock_canonical_tag_for(obj)
    return unless obj.use_hancock_canonicalable
    url = obj.hancock_canonical_url
    hancock_canonical_tag(url) unless url.blank?
  end
end

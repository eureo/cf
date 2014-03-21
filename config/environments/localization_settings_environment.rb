module LocalizationSettings
  CONFIG = {
    # Default language
    :default_language => 'fr',
    :web_charset => 'utf-8'
  }

  if CONFIG[:web_charset] == 'utf-8'
    $KCODE = 'u'
  end
end

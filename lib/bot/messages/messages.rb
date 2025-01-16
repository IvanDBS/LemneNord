# Тексты сообщений
module Messages
  ERRORS = {
    'ru' => {
      invalid_data: '❌ Неверные данные. Пожалуйста, проверьте введенную информацию.',
      not_found: '❌ Запись не найдена.',
      unknown: '❌ Произошла ошибка. Пожалуйста, попробуйте позже.',
      invalid_phone: '❌ Неверный формат номера телефона. Пожалуйста, введите корректный номер.',
      invalid_address: '❌ Адрес слишком короткий. Пожалуйста, введите полный адрес доставки.'
    },
    'ro' => {
      invalid_data: '❌ Date invalide. Vă rugăm să verificați informațiile introduse.',
      not_found: '❌ Înregistrarea nu a fost găsită.',
      unknown: '❌ A apărut o eroare. Vă rugăm să încercați mai târziu.',
      invalid_phone: '❌ Format invalid al numărului de telefon. Vă rugăm să introduceți un număr valid.',
      invalid_address: '❌ Adresa este prea scurtă. Vă rugăm să introduceți adresa completă de livrare.'
    }
  }

  MESSAGES = {
    'ru' => {
      welcome: "👋 Добро пожаловать в LemneNord!\n\n🌐 Выберите язык / Alegeți limba:",
      language_selected: "🇷🇺 Вы выбрали русский язык",
      menu: "🔹 Выберите действие:",
      new_order: "🛒 Новый заказ",
      my_orders: "📋 Мои заказы",
      change_language: "🌐 Изменить язык",
      select_product: "Наш ассортимент дров:\n\nВыберите тип дров, нажав на соответствующую кнопку:",
      enter_quantity: "Укажите необходимое количество складометров:",
      enter_address: "Укажите адрес доставки:",
      enter_phone: "Укажите контактный телефон для связи:",
      price_info: "💰 Стоимость заказа:\n▫️ Цена за складометр: %{price} лей\n▫️ Общая стоимость: %{total} лей",
      application_submitted: "Спасибо за заказ! Ваша заявка принята на рассмотрение. Мы свяжемся с вами в ближайшее время.",
      no_orders: "У вас пока нет заказов. Используйте /start для создания заказа.",
      active_order_exists: "У вас уже есть активный заказ. Хотите отменить его и создать новый?",
      cancel_order: "❌ Отменить заказ",
      order_cancelled: "Заказ отменен. Теперь вы можете создать новый заказ.",
      saved_phone: '✅ Номер телефона сохранен',
      saved_address: '✅ Адрес доставки сохранен',
      use_saved_phone: 'Использовать сохраненный номер?',
      use_saved_address: 'Использовать сохраненный адрес?',
      saved_address_used: "✅ Использован сохраненный адрес",
      saved_phone_used: "✅ Использован сохраненный номер"
    },
    'ro' => {
      welcome: "👋 Bine ați venit la LemneNord!\n\n🌐 Alegeți limba / Выберите язык:",
      language_selected: "🇷🇴 Ați ales limba română",
      menu: "🔹 Selectați acțiunea:",
      new_order: "🛒 Comandă nouă",
      my_orders: "📋 Comenzile mele",
      change_language: "🌐 Schimbă limba",
      select_product: "Sortimentul nostru de lemne:\n\nSelectați tipul de lemne apăsând butonul corespunzător:",
      enter_quantity: "Indicați cantitatea necesară în steri:",
      enter_address: "Indicați adresa de livrare:",
      enter_phone: "Indicați numărul de telefon pentru contact:",
      price_info: "💰 Costul comenzii:\n▫️ Preț per ster: %{price} lei\n▫️ Cost total: %{total} lei",
      application_submitted: "Vă mulțumim pentru comandă! Cererea dvs. a fost acceptată spre examinare. Vă vom contacta în curând.",
      no_orders: "Nu aveți comenzi încă. Folosiți /start pentru a crea o comandă.",
      active_order_exists: "Aveți deja o comandă activă. Doriți să o anulați și să creați una nouă?",
      cancel_order: "❌ Anulează comanda",
      order_cancelled: "Comanda a fost anulată. Acum puteți crea o comandă nouă.",
      saved_phone: '✅ Numărul de telefon a fost salvat',
      saved_address: '✅ Adresa de livrare a fost salvată',
      use_saved_phone: 'Folosiți numărul salvat?',
      use_saved_address: 'Folosiți adresa salvată?',
      saved_address_used: "✅ A fost utilizată adresa salvată",
      saved_phone_used: "✅ A fost utilizat numărul salvat"
    }
  }
end 
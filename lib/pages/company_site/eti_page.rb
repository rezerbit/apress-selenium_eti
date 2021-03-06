# TODO: удалить неиспользуемые локаторы
module CompanySite
  class EtiPage < Page
    checkbox(:product_checkbox, css: '.js-check-product')
    checkbox(:deal_checkbox, css: '.js-input-deals')
    button(:save_deals, css: 'div.ui-dialog div > button:nth-child(1)')
    button(:add_products_to_deal, css: '.js-deals-config')
    button(:save, xpath: "//*[contains(text(), 'Подтвердить актуальность')]")
    button(:save_description, css: '.edit-description .js-check')
    button(:save_wholesale_price, css: '.js-save-wholesale')
    button(:save_portal_traits, css: '.js-popup-traits-values .fa-check ')
    span(:progress_bar, css: '#pb')
    button(:to_catalog, css: '.ml15')
    span(:save_status, css: '.js-status-bar-content')
    button(:add_products_menu, css: '.sb-label')
    button(:add_product_manually, css: '.js-add-product')
    span(:empty_product_name, xpath: "//*[text()[contains(., 'Указать название')]]")

    span(:name_cell, xpath: "//*[@data-placeholder='Указать название']")
    span(:price_cell, xpath: "//*[contains(text(), 'Указать розничную цену')]")
    span(:wholesale_price_cell, css: '.js-eti-wholesaleprice .bp-price-free')
    span(:exist_cell, xpath: "//*[contains(text(), 'Указать наличие')]")
    span(:portal_traits_cell, css: '.js-eti-traits-edit')
    button(:add_product, css: '.new.js-add-product')
    text_area(:edit_text_area, css: '.edit-text')

    text_area(:price_text_area, css: '.js-text-price')
    text_area(:price_from, xpath: "(//*[@class = 'pv-text-field js-text-price'])[2]")
    text_area(:price_to, css: '.js-text-price-max')
    text_area(:previous_price, css: '.js-text-price-prev')
    text_area(:discount_price, css: '.js-product-form-discount-price')
    text_area(:discount_expires_at_date, css: '.js-discount-expires-at')
    text_area(:short_description_cell, css: '.js-eti-announce')
    text_area(:description_cell, css: '.js-eti-description')
    text_area(:description, css: '.cke_textarea_inline')
    text_area(:wholesale_price, css: '.js-wholesale-price')
    text_area(:wholesale_number, css: '.js-wholesale-min-qty')
    text_area(:gost, xpath: "//input[@data-name='ГОСТ']")
    text_area(:condition, xpath: "//input[@data-name='Состояние']")
    text_area(:manufacturer_country, xpath: "//input[@data-name='Страна-производитель']")
    button(:save_price, css: '.ui-button.ui-widget.ui-state-default.ui-corner-all.ui-button-text-only')

    span(:price_value, css: '.bp-price.fsn')
    spans(:price_values, css: '.bp-price.fsn')
    span(:discount_price_value, css: '.discount .bp-price.fsn')
    span(:previous_price_value, css: '.bp-price.fwn.fsn')
    span(:discount_expires_at_date_value, css: '.discount-date')

    span(:exists_value, css: '.cost-dog-link')
    span(:upload_image, name: 'images')
    image(:image, css: '.ibb-img.js-img')
    # HACK: цепляемся за .ui-resizable, потому что больше нет уникальных идентификаторов
    button(:close_image_uploader, css: '.ui-resizable .ui-dialog-titlebar-close')

    span(:image_uploader, css: '.ui-dialog.ui-widget.ui-widget-content.ui-corner-all.ui-front.ui-draggable')
    button(:image_cell, css: '.fa-camera')
    button(:image_upload_btn, css: '.js-upload-input')
    span(:thermometer, css: '.js-battery-wrapper')
    span(:rubric_cell, css: '.js-rubric-preview-link')
    text_area(:rubric_search, css: '.js-input-rubric-search')
    button(:rubric_search_submit, css: '.js-button-rubric-search')
    button(:first_rubric_search_result, css: '.src-link')
    link(:page_2, xpath: "//*[@data-page='2']")
    link(:page_1, xpath: "//*[@data-page='1']")
    span(:found_products_count, css: '.js-products-count')
    radio_button(:from_to, xpath: "(//*[@class = 'va-1 mr5 js-select-type-price'])[2]")
    radio_button(:discount, xpath: "(//*[@class = 'va-1 mr5 js-select-type-price'])[3]")

    button(:operation_undo, css: 'div.operation.undo')
    button(:operation_redo, css: 'div.operation.redo')
    button(:publish_product, css: '.dialog-status .published')
    button(:archive_product, css: '.dialog-status .archived')

    select_list(:choose_amount_of_products_on_page, css: '.ptrfap-choose-amount')
    divs(:product, css: 'tr.pt-tr')
    div(:save_status, css: '.js-status-bar-content')
    text_area(:product_search, xpath: "//*[@id='product-bindings-search']")
    button(:search_button, css: '.js-search-submit')
    span(:first_product_status, css: '.js-eti-status > div > i')

    checkbox(:exact_search, css: '#exact_search')
    divs(:product_rows, css: '.js-pt-tr')
    span(:inframe_block, css: '.js-bcm-content')

    alias old_confirm confirm
    def save
      old_confirm
      confirm_not_exists?(30)
    end

    def wait_saving(delay = 0.1)
      # Задержка, так как иначе в wait_until идет предыдущий статус изменений
      sleep delay
      wait_until { save_status == 'Все изменения сохранены' }
    end

    module Fields
      def create_and_set_product_fields(options = {})
        add_product
        options.each do |field_key, field_value|
          send("set_#{field_key}", field_value)
        end
      end

      def set_name(text)
        browser
          .action
          .move_to(name_cell_element.element)
          .click
          .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
          .send_keys(text)
          .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
          .perform

        wait_saving
      end

      def set_price_from_to(options = {})
        browser
          .action
          .move_to(price_cell_element.element)
          .click
          .perform

        select_from_to
        self.price_from = options.fetch(:from, '')
        self.price_to = options.fetch(:to, '')

        save_price
        wait_saving
      end

      def set_discount_price(options = {})
        browser
          .action
          .move_to(price_cell_element.element)
          .click
          .perform

        select_discount

        self.previous_price = options.fetch(:previous, '')
        self.discount_price = options.fetch(:discount, '')
        discount_expires_at_date_element.element.send_keys(Selenium::WebDriver::Keys::KEYS[:enter])

        save_price
        wait_saving
      end

      def set_price(text)
        browser
          .action
          .move_to(price_cell_element.element)
          .click
          .send_keys(price_text_area_element.element, text)
          .perform

        try_to(:save_price)
        wait_saving
      end

      def set_wholesale_price(options = {})
        browser
          .action
          .move_to(wholesale_price_cell_element.element)
          .click
          .perform

        self.wholesale_price = options.fetch(:wholesale_price, '')
        self.wholesale_number = options.fetch(:wholesale_number, '')

        save_wholesale_price
        wait_saving
      end

      def set_rubric(text)
        browser
          .action
          .move_to(rubric_cell_element.element)
          .click
          .perform

        self.rubric_search = text
        rubric_search_submit
        wait_until { first_rubric_search_result? }
        first_rubric_search_result

        wait_saving
      end

      def set_image(path)
        image_cell
        upload_file(upload_image_element, path)
        wait_until { image_loaded? }
        # TODO
        # добавить закрытие попапа (close_image_uploader) и изменить кейс в mini_eti_spec
      end

      def set_short_description(text)
        browser
          .action
          .move_to(short_description_cell_element.element)
          .click
          .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
          .perform

        wait_until { inframe_block? }

        execute_script("$('.edit-announce iframe').get()[0].contentWindow.document.body.innerHTML='#{text}'")

        browser
          .action
          .move_to(short_description_cell_element.element)
          .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
          .perform

        wait_saving
      end

      def set_description(text)
        browser
          .action
          .move_to(description_cell_element.element)
          .click
          .send_keys(Selenium::WebDriver::Keys::KEYS[:enter])
          .perform

        wait_until { description? }
        description_element.send_keys(text)
        save_description

        wait_saving
      end

      def set_portal_traits(options = {})
        Page.link(:gost_link, xpath: "//a[text()='#{options.fetch(:gost, '')}']")
        Page.link(:condition_link, xpath: "//a[text()='#{options.fetch(:condition, '')}']")
        Page.link(:manufacturer_country_link, xpath: "//a[text()='#{options.fetch(:manufacturer_country, '')}']")

        wait_until { portal_traits_cell_element.text.include?('указать характеристики') }

        browser
          .action
          .move_to(portal_traits_cell_element.element)
          .click
          .perform

        self.gost = options.fetch(:gost, '')
        wait_until { gost_link? }
        gost_link

        self.condition = options.fetch(:condition, '')
        wait_until { condition_link? }
        condition_link

        self.manufacturer_country = options.fetch(:manufacturer_country, '')
        wait_until { manufacturer_country_link? }
        manufacturer_country_link

        save_portal_traits
        wait_saving
      end

      def set_exists(value)
        Page.link(:exists_link, xpath: "//li/a[text()='#{value}']")

        browser
          .action
          .move_to(exist_cell_element.element)
          .click
          .perform

        exists_link
        wait_saving
      end
    end

    include Fields

    def thermometer_value
      thermometer.tr('%', '').to_i
    end

    def price
      price_cell_element.text
    end

    def product_name?(name)
      Page.span(:product_name_span, xpath: "//*[contains(text(), '#{name}')]")
      product_name_span?
    end

    def product_rubric_tree(name)
      Page.span(:rubric_header_span, xpath:
          "//td[@data-text='#{name}']/..//span[@class='dashed-span js-rubric-preview-link']")
      rubric_header_span_element.text
    end

    def product_published?(name)
      Page.span(:publish_status_icon, xpath: "//td[@data-text='#{name}']/..//i[contains(@class, 'published')]")
      publish_status_icon?
    end

    def product_unpublished?(name)
      Page.span(:unpublish_status_icon, xpath: "//td[@data-text='#{name}']/..//i[contains(@class, 'unpublished')]")
      unpublish_status_icon?
    end

    def product_archived?(name)
      Page.span(:archived_status_icon, xpath: "//td[@data-text='#{name}']/..//i[contains(@class, 'archived')]")
      archived_status_icon?
    end

    def product_declined?(name)
      Page.span(:declined_status_icon, xpath: "//td[@data-text='#{name}']/..//i[contains(@class, 'declined')]")
      declined_status_icon?
    end

    def search_product(name)
      check_exact_search
      self.product_search = name
      search_button
    end

    def delete_product(name)
      search_product(name)
      Page.button(:delete_product_icon, xpath:
          "//td[@data-text='#{name}']/..//i[contains(@class, 'js-delete-product')]")

      confirm(true) { delete_product_icon }
      wait_saving
    end

    def copy_product(name)
      Page.button(:copy_product_icon, xpath: "//td[@data-text='#{name}']/..//i[contains(@class, 'js-copy-product')]")
      copy_product_icon

      wait_saving
    end

    def change_status_to_published(name)
      Page.button(:product_status, xpath: "//*[@data-text='#{name}']/..//*[contains(@class, 'js-change-status')]")
      product_status
      publish_product

      wait_saving
    end

    def change_status_to_archived(name)
      Page.button(:product_status, xpath: "//*[@data-text='#{name}']/..//*[contains(@class, 'js-change-status')]")
      product_status
      archive_product

      wait_saving
    end

    ActiveSupport.run_load_hooks(:'apress/selenium_eti/company_site/eti_page', self)
  end
end

require 'kimurai'
class ProductScraper < Kimurai::Base
  @name = 'product_scraper'
  @engine = :mechanize
  def self.process
    ## Magento framework pass here
    url = 'https://magento-test.finology.com.my/breathe-easy-tank.html'
    @start_urls = [url]
    @config = {
      skip_request_errors: [
        { error: RuntimeError, message: "404 => Net::HTTPInternalServerError" }
      ]
    }
    self.crawl!
  end

  def parse(response, url:, data: {})
    puts "scraping started"
    scrape_page response
    find_links response
  end

  def scrape_page response
    response.xpath("//main[@class='page-main']").each do |product|
      item = {}
      item[:name]       = product.css('div.product-info-main .page-title-wrapper .page-title span')&.text&.squish
      item[:price]      = product.css('div.product-info-main .product-info-price .price-final_price span.price-wrapper span.price')&.text&.squish
      item[:detail]     = product.css('div.product.info.detailed div#description div.description div.value')&.text&.squish
      item[:extra_info] = ""
      product.css('div.product.info.detailed div#additional table#product-attribute-specs-table tbody tr').each do |table_row|
        row_data = table_row.css('th.label')&.text&.squish
        row_data =  "#{row_data}:" + table_row.css('td.data')&.text&.squish + ","
        if row_data.present?
          item[:extra_info] += "#{row_data}"
        end
      end
      puts item
      Product.where(item).first_or_create
      find_links product
    end
  end

  def find_links response
    response.css(".product-item-link").each do |product|
      if @@item_links.select {|item| item["name"] == product&.text.squish }.count == 0
        @@item_links << {
          link: product&.attr('href'),
          name: product&.text.squish
        }
        browser.visit(product&.attr('href'))
        scrape_page browser.current_response
      end
    end
  end
end
ProductScraper.process
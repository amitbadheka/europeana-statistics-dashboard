module Impl
  module Reports
    class ManualReport < Europeana::Styleguide::View
      def page_title
        "#{@impl_report.name.titleize} - Europeana Statistics Dashboard"
      end

      def bodyclass
        "europeana_statsdashboard page_static"
      end

      def version
        {
          is_beta: @is_beta
        }
      end

      def navigation
        {
          global: {
              logo: {
                url: root_path,
                text: "Europeana statistics"
              },
              primary_nav: {
                menu_id: "main-menu",
                items: [
                  {
                    text: "Europeana Stats",
                    url: europeana_report_path
                  },
                  {
                    text: "Find a dashboard",
                    submenu: {
                      items: [
                          {
                            url: false,
                            text: "Browse Statistics:",
                            subtitle: true
                          },
                          {
                            url: countries_path,
                            text: "By Country"
                          },
                          {
                              is_divider: true
                          },
                          {
                            url: false,
                            text: "Find statistics for an organisation:",
                            subtitle: true
                          },
                          {
                            url: providers_path,
                            text: "Find an Aggregator"
                          },
                          {
                            url: data_providers_path,
                            text: "Find an Institution"
                          }
                      ]
                    }
                  },
                  {
                    url: @about_report.present? ? manual_report_path(@about_report) : false,
                    text: @about_report.present? ? "About" : "",
                    is_current: @about_report.slug == @impl_report.slug
                  }

                ]
              }
            }
         }
      end

      def css_files
        [
          { path: styleguide_url('/css/statistics/screen.css'), media: 'all', title: nil }
        ]
      end

      def js_files
        [
          {
            path: styleguide_url('/js/dist/require.js'),
            data_main: styleguide_url('/js/dist/main/main-statistics.js')
          }
        ]
      end

      def content
        {
          prose: {
            html: @markdown.render(@impl_report.html_content)
          }
        }
      end

      def title
        ""
      end

    end
  end
end

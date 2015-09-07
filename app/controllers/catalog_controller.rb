# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController  
  include Blacklight::Marc::Catalog

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10,
      :df => 'texto',
      :"hl" => true,
      :"hl.snippets" => 3,
      :"hl.fragsize" => 250
    }
    
    # solr path which will be added to solr base url before the other solr params.
    config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
      :fl => '*',
      :rows => 1,
      :q => '{!raw f=id v=$id}'
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'Diários Oficiais Da Cidade De São Paulo'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.title_field = 'Diários Oficiais Da Cidade De São Paulo'
    config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'org_facet', :label => 'Órgão', :limit => 10 
    #config.add_facet_field 'orgao_facet', :label => 'Orgão', :limit => 10 
    #config.add_facet_field 'tipo_conteudo_facet', :label => 'Tipo de Conteúdo', :limit => 10 
    #config.add_facet_field 'secretaria_facet', :label => 'Publication Year', :single => true
    #config.add_facet_field 'tipo_conteudo_facet', :label => 'Topic', :limit => 20 
    #config.add_facet_field 'language_facet', :label => 'Language', :limit => true 
    #config.add_facet_field 'lc_1letter_facet', :label => 'Call Number' 
    #config.add_facet_field 'subject_geo_facet', :label => 'Region' 
    #config.add_facet_field 'subject_era_facet', :label => 'Era'  

    #config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']

    config.add_facet_field 'data', :label => 'Data de Resposta', :query => {
      :date_range => { :label => 'Intervalo de Datas', :fq => "data:[* TO *]" }, :week_1 => { :label => 'Menos de 1 semana', :fq => "data:[#{Date.today - 7.days}T00:00:00.000Z TO #{Date.today}T00:00:00.000Z]" },
      :month_1 => { :label => 'Menos de 1 mês', :fq => "data:[#{Date.today - 1.months}T00:00:00.000Z TO #{Date.today}T00:00:00.000Z]" },
      :years_1 => { :label => 'Menos de 1 ano', :fq => "data:[#{Date.today - 1.years}T00:00:00Z TO #{Date.today}T00:00:00.000Z]" },
      :years_5 => { :label => 'Menos de 5 anos', :fq => "data:[#{Date.today - 5.years}T00:00:00Z TO #{Date.today}T00:00:00.000Z]" },
      :years_mais_5 => { :label => 'Mais de 5 anos', :fq => "data:[* TO #{Date.today - 5.years}T00:00:00Z]" }
    }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'org', :label => 'Orgão'
    config.add_index_field 'pedido', :label => 'Pedido'
    config.add_index_field 'resposta', :label => 'Resposta', :highlight => true
    #config.add_index_field 'tipo_conteudo', :label => 'Tipo de Conteúdo'
    #config.add_index_field 'texto', :label => 'Texto', :highlight => true


    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'org', :label => 'Órgão'
    config.add_show_field 'pedido', :label => 'Pergunta'
    config.add_show_field 'resposta', :label => 'Resposta'
    #config.add_show_field 'tipo_conteudo', :label => 'Tipo de Conteúdo'
    #config.add_show_field 'texto', :label => 'Texto'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    #config.add_search_field 'texto', :label => 'Texto'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    #config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      #field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      #field.solr_local_parameters = { 
        #:qf => '$title_qf',
        #:pf => '$title_pf'
      #}
    #end
    
    #config.add_search_field('author') do |field|
      #field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      #field.solr_local_parameters = { 
        #:qf => '$author_qf',
        #:pf => '$author_pf'
      #}
    #end
    
    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    #config.add_search_field('subject') do |field|
      #field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      #field.qt = 'search'
      #field.solr_local_parameters = { 
        #:qf => '$subject_qf',
        #:pf => '$subject_pf'
      #}
    #end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, data desc', :label => 'Relevância'
    config.add_sort_field 'data desc', :label => 'Data'


    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

    # get search results from the solr index
    def index
      (@response, @document_list) = get_search_results
      respond_to do |format|
        format.html { }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
        hash_result = render_search_results_as_json
        hash_result[:pages][:is_first_page] = hash_result[:pages][:"first_page?"]
        hash_result[:pages][:is_last_page] = hash_result[:pages][:"last_page?"]
        hash_result[:pages].delete(:"first_page?")
        hash_result[:pages].delete(:"last_page?")
    
        format.json do
          render json: {:response => hash_result}
        end
        format.xml do
          render xml: JSON.parse(hash_result.to_json).to_xml(:root=>"response")
        end

        additional_response_formats(format)
        document_export_formats(format)
      end
    end

    def render_search_results_as_json
      {docs: @document_list, facets: search_facets_as_json, pages: pagination_info(@response)}
    end

    # get single document from the solr index
    def show
      @response, @document = get_solr_response_for_doc_id   

      respond_to do |format|
        format.html {setup_next_and_previous_documents}

        format.json { render json: {:response => @document } }
	format.xml { render xml: @document.to_xml(:root=>'response') }

        # Add all dynamically added (such as by document extensions)
        # export formats.
        @document.export_formats.each_key do | format_name |
          # It's important that the argument to send be a symbol;
          # if it's a string, it makes Rails unhappy for unclear reasons. 
          format.send(format_name.to_sym) { render :text => @document.export_as(format_name), :layout => false }
        end
        
      end
    end

   # displays values and pagination links for a single facet field
    def facet
      @facet = blacklight_config.facet_fields[params[:id]]
      @response = get_facet_field_response(@facet.field, params)
      @display_facet = @response.facets.first

      # @pagination was deprecated in Blacklight 5.1
      @pagination = facet_paginator(@facet, @display_facet)


      respond_to do |format|
        # Draw the facet selector for users who have javascript disabled:
        format.html 
        format.json { render json: render_facet_list_as_json }

        # Draw the partial for the "more" facet modal window:
        format.js { render :layout => false }
      end
    end
    
end 

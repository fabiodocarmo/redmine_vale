class NfXmlController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def index
  end

  def create
    # Make sure that API users get used to set this content type
    # as it won't trigger Rails' automatic parsing of the request body for parameters
    unless request.content_type == 'application/octet-stream'
      render :nothing => true, :status => 406
      return
    end
    
    if Setting.plugin_nf_xml_to_form["transport_converter_issues"].blank?
      nf_xml = XmlConverter.convert(request.raw_post)
    else
      if params[:tracker].in? Setting.plugin_nf_xml_to_form["transport_converter_issues"]
        if params[:cf_xml] == Setting.plugin_nf_xml_to_form["transport_material_field"]
          nf_xml = MaterialXmlConverter.convert(request.raw_post)
        else
          nf_xml = TransportXmlConverter.convert(request.raw_post)
        end
      else
        nf_xml = XmlConverter.convert(request.raw_post)
      end
    end
    if params[:cf_xml] == Setting.plugin_nf_xml_to_form["transport_material_field"]
      xml_hash = material_xml_to_hash nf_xml
    else
      xml_hash = xml_to_hash nf_xml, params[:tracker]
    end
    respond_to do |format|
      format.js {
        validation = XmlValidator.validate(xml_hash, params[:tracker])
        validation[:xml_hash] = xml_hash
        render json: validation
      }
    end
  end

  def show
    if Setting.plugin_nf_xml_to_form["transport_converter_issues"].blank?
      nf_xml = XmlConverter.convert(File.open(Attachment.find(params[:id]).diskfile))
    else
      if params[:tracker].in? Setting.plugin_nf_xml_to_form["transport_converter_issues"]
        if params[:cf_xml] == Setting.plugin_nf_xml_to_form["transport_material_field"]
          nf_xml = MaterialXmlConverter.convert(File.open(Attachment.find(params[:id]).diskfile))
        else
          nf_xml = TransportXmlConverter.convert(File.open(Attachment.find(params[:id]).diskfile))
        end
      else
        nf_xml = XmlConverter.convert(File.open(Attachment.find(params[:id]).diskfile))
      end
    end

    if params[:cf_xml] == Setting.plugin_nf_xml_to_form["transport_material_field"]
      xml_hash = material_xml_to_hash nf_xml
    else
      xml_hash = xml_to_hash nf_xml, params[:tracker]
    end
    respond_to do |format|
      format.js {
        render json: xml_hash
      }
    end
  end

  protected

  def material_xml_to_hash(xml)
    xml = Nokogiri::XML(xml).remove_namespaces!

    {
      Setting.plugin_nf_xml_to_form["chave_acesso"].to_i => xml.xpath('//infProt//ChaveAcesso').text
    }
  end

  def xml_to_hash(xml, tracker_id)
    XmlToHashService.convert(xml, tracker_id)
  end
end

function setupTooltip()
{
  $("#TooltipText").text = $.Localize( $.GetContextPanel().GetAttributeString( "text", "not-found" ) );
}
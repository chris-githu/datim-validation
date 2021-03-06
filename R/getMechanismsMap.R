#' @export
#' @title getMechanismsMap()
#' 
#' @description Utility function to produce a map of valid mechanisms
#'
#' @param organisationUnit Operating unit in question specified as a UID. If not specified, assume to be Global.
#' @return Returns a data frame  of name,code,id, and categoryOptionCombo (which is the UID of interest) along with start and endDates of the mechanisms
#' 
getMechanismsMap<-function(organisationUnit=NA) {
  if ( is.na(organisationUnit) ) { 
    organisationUnit<-getOption("organisationUnit")
    warning( paste("No organisation unit specified. Using orgunit",organisationUnit) )
  }
  #Determine if we should filter by OU
  ou_filter= !( organisationUnit== "ybg3MO3hcf4"  )
  #Special cases when global OU is used, particularly for SIMS Import
  url<-paste0(getOption("baseurl"),"api/categoryOptionCombos?filter=categoryCombo.id:eq:wUpfppgjEza&fields=code,name,id,categoryOptions[startDate,endDate]&paging=false")
  if  ( ou_filter ){
    url<-paste0(url,paste0("&filter=categoryOptions.organisationUnits.id:eq:",organisationUnit)) 
  }
  url<-URLencode(url)
  sig<-digest::digest(paste0(url),algo='md5', serialize = FALSE)
  mechs<-getCachedObject(sig)
  if (!is.null(mechs))  { return(mechs) } else
  if(is.null(mechs)) {
  
  r<-httr::GET(url,httr::timeout(60))
  if (r$status == 200L ){
  r<- httr::content(r, "text")
  mechs<-jsonlite::fromJSON(r,flatten=TRUE)[[1]]
  #Need to unwind the dates
  mechs$startDate<-as.Date(sapply(mechs$categoryOptions, function(x) ifelse(is.null(x$startDate),"1900-01-01",x$startDate)),"%Y-%m-%d")
  mechs$endDate<-as.Date(sapply(mechs$categoryOptions, function(x) ifelse(is.null(x$endDate),"1900-01-01",x$endDate)),"%Y-%m-%d")
  mechs<-mechs[,-which(names(mechs) == "categoryOptions")]
  saveCachedObject(mechs,sig) }
  return( mechs ) } 
  
  else {
      print(paste("Could not retreive mechanisms",httr::content(r,"text")))
      stop()
    }
  
}
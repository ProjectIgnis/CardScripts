--超戦士の萌芽
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtypeRITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0x10cf),lv=8,extrafil=s.extragroup,
									extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_series={0x10cf}
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.matfilter(c,e,tp)
	return s.matfilter1(c)
end
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
function s.ritcheck(e,tp,g,sc)
	return #g==2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
end

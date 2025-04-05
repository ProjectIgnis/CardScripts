--超戦士の萌芽
--Super Soldier Synthesis
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_BLACK_LUSTER_SOLDIER),lv=8,extrafil=s.extragroup,
									extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,specificmatfilter=s.specificfilter,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BLACK_LUSTER_SOLDIER}
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.specificfilter(c,rc,mg,tp)
	return mg:IsExists(s.matfilter2,1,nil,c,tp,rc)
end
function s.matfilter2(c,gc,tp,rc)
	if ((c:GetAttribute()|gc:GetAttribute())&(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))==(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and ((c:GetLocation()|gc:GetLocation())&(LOCATION_HAND|LOCATION_DECK))==(LOCATION_HAND|LOCATION_DECK) then
		return Group.FromCards(c,gc):CheckWithSumEqual(Card.GetRitualLevel,8,2,2,rc) 
	end
	return false
end
function s.matfilter(c,e,tp)
	return s.matfilter1(c)
end
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLocation(LOCATION_HAND|LOCATION_DECK) and c:IsAbleToGrave()
end
function s.ritcheck(e,tp,g,sc)
	return #g==2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK),#g>2
end
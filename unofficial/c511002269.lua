--Gathering of Malice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=aux.FilterBoolFunction(Card.IsCode,23116808),
									matfilter=Fusion.OnFieldMat(s.fil),extrafil=s.fextra}
	c:RegisterEffect(e1)
end
s.listed_names={23116808,23116809}
function s.fil(c)
	return c:IsCode(23116809)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
end
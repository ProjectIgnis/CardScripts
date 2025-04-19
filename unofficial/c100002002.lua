--幽合
--Ghost Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=s.matfilter,extrafil=s.extrafil,extraop=s.extraop,exactcount=2})
	c:RegisterEffect(e1)
end
function s.matfilter(c,e,tp)
	if not c:IsRace(RACE_ZOMBIE) then return false end
	local loc=c:GetLocation()
	return (loc&(LOCATION_DECK|LOCATION_MZONE)~=0 and c:IsAbleToGrave()) or loc&LOCATION_GRAVE~=0
end
function s.check(tp,sg,fc)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)
	return ct==1,ct>1
end
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil),s.check
end
function s.extraop(e,tc,tp,sg)
	Duel.SendtoGrave(sg:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_GRAVE),REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
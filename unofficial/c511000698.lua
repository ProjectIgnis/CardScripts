--ディメンション・エクシーズ
--Dimension Xyz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.xyzmatfilter(c)
	return c:IsCanBeXyzMaterial() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=1000
end
function s.xyzfilter(c,g)
	return c:IsXyzSummonable(nil,g,3,3)
end
function s.rescon(exg)
	return function(sg)
		if sg:CheckDifferentProperty(Card.GetCode) then return false,false end
		return #sg==3 and exg:IsExists(Card.IsXyzSummonable,1,nil,nil,sg,3,3)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.xyzmatfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if chk==0 then return aux.SelectUnselectGroup(mg,e,tp,3,3,s.rescon(exg),0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.xyzmatfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #exg==0 then return end
	local matg=aux.SelectUnselectGroup(mg,e,tp,3,3,s.rescon(exg),1,tp,HINTMSG_XMATERIAL1)
	if #matg~=3 then return end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,matg)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,matg,matg,3,3)
	end
end
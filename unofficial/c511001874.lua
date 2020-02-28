--Rescue Xyz
local s,id=GetID()
function s.initial_effect(c)
	--xyz effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:GetOwner()~=c:GetControler()
end
function s.cfilter(c)
	return not c:IsHasEffect(EFFECT_XYZ_MATERIAL)
end
function s.xyzfilter(c,mg)
	local g=mg:Filter(s.cfilter,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_MATERIAL)
		e1:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	local res=c:IsXyzSummonable(nil,mg)
	tc=g:GetFirst()
	while tc do
		tc:ResetEffect(EFFECT_XYZ_MATERIAL,RESET_CODE)
		tc=g:GetNext()
	end
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local mg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=g:Select(tp,1,1,nil):GetFirst()
		local g2=mg:Filter(s.cfilter,nil)
		local tc=g2:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_XYZ_MATERIAL)
			e1:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e1)
			tc=g2:GetNext()
		end
		Duel.XyzSummon(tp,xyz,nil,mg,99,99)
	end
end

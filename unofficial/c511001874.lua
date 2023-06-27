--レスキュー・エクシーズ
--Xyz Rescue
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
function s.xyzfilter(c,tp,mg)
	return c:IsXyzSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local reset={}
		local mg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		for tc in aux.Next(mg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_XYZ_MATERIAL)
			tc:RegisterEffect(e1)
			table.insert(reset,e1)
		end
		local res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local reset={}
	local mg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_MATERIAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		table.insert(reset,e1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,mg):GetFirst()
	if xyz then
		Duel.XyzSummon(tp,xyz,nil,mg,1,99)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetOperation(function()
			for _,eff in ipairs(reset) do
				eff:Reset()
			end
		end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		xyz:RegisterEffect(e1,true)
	else
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
	end
end

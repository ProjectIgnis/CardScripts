-- 虚鋼演機乱流
--Imaginary Arc Turbulence
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Change position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.sumfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.gyfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDefense(500)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sumfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(8) and c:IsCanChangePositionRush()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetChainLimit(function(e)return not e:IsHasType(EFFECT_TYPE_ACTIVATE)end)
end
function s.filter(c,race)
	return c:IsRace(race) and c:IsType(TYPE_NORMAL)
end
function s.desfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,c:GetRace())
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g<1 then return end
	Duel.HintSelection(g,true)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)>0
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
--マジカル・ファイアストーム
--Magical Firestorm
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Up to 3 Effect monsters your opponent controls lose 400 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.desfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()<=6 and not c:IsMaximumModeSide()
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,ct,nil)
	if #dg>0 then
		dg=dg:AddMaximumCheck()
		Duel.HintSelection(dg,true)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
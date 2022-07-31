--ヴォイド・インターセプト
--Void Intercept
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent normal/special summons a monster, discard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.filter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return eg:IsExists(s.filter1,1,nil,tp) and #g>0 and g:FilterCount(s.filter,nil)==#g
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,1-tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #dg>0 then
		local g=dg:RandomSelect(tp,1)
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0 then
			if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=2 and Duel.IsPlayerCanDraw(1-tp,1) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Draw(1-tp,1,REASON_EFFECT)
			end
		end
	end
end
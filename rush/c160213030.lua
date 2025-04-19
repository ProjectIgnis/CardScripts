--対峙する黒竜
--Confronting the Black Dragon
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE|ATTRIBUTE_DARK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 then return false end
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsType(TYPE_EFFECT) and tc:IsCanTurnSet() and tc:IsCanChangePositionRush()
		and tc:IsSummonPlayer(1-tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg:GetFirst(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 and #dg>=3 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=dg:RandomSelect(tp,1)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

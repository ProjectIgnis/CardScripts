--手揉みドラコ
--Draco the Palm Greaser
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackPos() and c:IsCanChangePositionRush() end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,1-tp,100)
end
function s.operation(e,tp)
	local c=e:GetHandler()
	--Requirement
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,0,0)<1 then return end
	--Effect
	Duel.Recover(1-tp,100,REASON_EFFECT)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local tc=g:RandomSelect(tp,1):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	if tc and tc:IsRace(RACE_DRAGON) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.ShuffleHand(tp)
end
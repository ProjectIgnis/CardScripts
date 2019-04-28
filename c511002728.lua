--D－タイム
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local lv=tc:GetLevel()
	return #eg==1 and tc:IsSetCard(0x3008) and tc:IsPreviousPosition(POS_FACEUP) and tc:IsPreviousControler(tp)
end
function s.filter(c,lv)
	return c:IsLevelBelow(lv) and c:IsSetCard(0xc008) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,eg:GetFirst():GetLevel()) end
	e:SetLabel(eg:GetFirst():GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,lv)
	if #sg==0 then return end
	local ag=Group.CreateGroup()
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		sg:RemoveCard(tc)
		lv=lv-tc:GetLevel()
		ag:AddCard(tc)
		sg:Remove(Card.IsLevelAbove,nil,lv+1)
	until #sg==0 or not Duel.SelectYesNo(tp,aux.Stringid(9354555,0))
	Duel.SendtoHand(ag,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,ag)
end

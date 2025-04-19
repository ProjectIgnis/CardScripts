--ダイスキー・イチカ
--Dice Key Ichika
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 3 cards and send 1 to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160019006),tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.ShuffleDeck(tp)
	--Effect
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetFirst()
	if ct:IsMonster() and ct:IsLevel(7) and ct.roll_dice then
		local dam=Duel.Damage(1-tp,700,REASON_EFFECT)
		if dam>0 and Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			sg=g:Select(tp,1,7,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
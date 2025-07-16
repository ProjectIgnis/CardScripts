--超戦士の魂
--Super Soldier Soul
local s,id=GetID()
function s.initial_effect(c)
	--Make this card's ATK become 3000 and its name become "Black Luster Soldier"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Add 1 "Beginning Knight" or "Evening Twilight Knight" from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BLACK_LUSTER_SOLDIER}
s.listed_names={5405694,6628343,32013448} --"Black Luster Soldier", "Beginning Knight", "Evening Twilight Knight"
function s.atkcostfilter(c)
	return c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.atkcostfilter,1,1,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local ct=Duel.IsTurnPlayer(tp) and 2 or 1
		--Until your opponent's next End Phase, this card's ATK becomes 3000, and this card's name becomes "Black Luster Soldier"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(3000)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,ct)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(5405694)
		e2:SetReset(RESETS_STANDARD_PHASE_END,ct)
		c:RegisterEffect(e2)
	end
end
function s.thfilter(c)
	return c:IsCode(6628343,32013448) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
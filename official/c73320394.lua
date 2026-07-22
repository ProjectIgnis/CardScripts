--邪悪なる魔王－ゾーク
--Evil Lord - Zorc
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--You can discard 2 cards, including this card; add 1 Level 8 Fiend monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--When your Fiend monster is destroyed by battle: You can Special Summon this card from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--During your Main Phase: You can roll a six-sided die and apply this effect based on the result
	--● 1, 2, 3, or 4: Take control of, or destroy, 1 monster your opponent controls
	--● 5 or 6: Destroy 1 card you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_CONTROL+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.dicetg)
	e3:SetOperation(s.diceop)
	c:RegisterEffect(e3)
end
s.roll_dice=true
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	local sg=Group.FromCards(c)
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	while #sg<2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local sc=Group.SelectUnselect(g,sg,tp,false,false,2,2)
		if sc~=c then sg:AddCard(sc) end
	end
	Duel.SendtoGrave(sg,REASON_COST|REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
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
function s.spconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousRaceOnField(RACE_FIEND)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local dice=Duel.TossDice(tp,1)
	if dice>=1 and dice<=4 then
		--● 1, 2, 3, or 4: Take control of, or destroy, 1 monster your opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		local b1=sc:IsAbleToChangeControler()
		local b2=true
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,4)},
			{b2,aux.Stringid(id,5)})
		if op==1 then
			Duel.GetControl(sc,tp)
		elseif op==2 then
			Duel.Destroy(sc,REASON_EFFECT)
		end
	elseif dice==5 or dice==6 then
		--● 5 or 6: Destroy 1 card you control
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

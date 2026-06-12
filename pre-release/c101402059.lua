--呼応する伝説の都
--Atlantis Call
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 monster that mentions "Atlantis, the Dragon City" from your Deck to your hand, then if you control "Atlantis, the Dragon City", you can negate the effects of 1 Effect Monster your opponent controls until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If you control "Umi": You can banish this card from your GY; all WATER monsters you currently control gain 500 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_UMI),tp,LOCATION_ONFIELD,0,1,nil)
	end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,500)
		Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,nil,1,tp,500)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,nil)
		for tc in g:Iter() do
			--All WATER monsters you currently control gain 500 ATK/DEF
			tc:UpdateAttack(500,nil,c)
			tc:UpdateDefense(500,nil,c)
		end
	end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ATLANTIS_THE_DRAGON_CITY,CARD_UMI}
function s.thfilter(c)
	return c:ListsCode(CARD_ATLANTIS_THE_DRAGON_CITY) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ATLANTIS_THE_DRAGON_CITY),tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.AND(Card.IsEffectMonster,Card.IsNegatableMonster),tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local sc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsEffectMonster,Card.IsNegatableMonster),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			if not sc then return end
			Duel.HintSelection(sc)
			Duel.BreakEffect()
			--Negate the effects of 1 Effect Monster your opponent controls until the end of this turn
			sc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
		end
	end
end
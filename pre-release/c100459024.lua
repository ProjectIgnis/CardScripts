--マジックカード「エネミーコントローラー」
--Spell Card "Enemy Controller"
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Pay 1000 LP, then target 1 face-up monster your opponent controls; apply 1 of these effects
	--● Destroy it
	--● Immediately after this effect resolves, Tribute Summon 1 monster by Tributing monsters including the targeted opponent's monster, even though you do not control it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.PayLP(1000))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase: You can banish this card from your GY; add 1 "Spell Card "Enemy Controller"" from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local extra_tribute_eff=nil
	if tc:IsControler(1-tp) then
		--Tribute Summon 1 monster by Tributing monsters including the targeted opponent's monster, even though you do not control it
		extra_tribute_eff=Effect.CreateEffect(e:GetHandler())
		extra_tribute_eff:SetType(EFFECT_TYPE_SINGLE)
		extra_tribute_eff:SetCode(EFFECT_EXTRA_RELEASE)
		extra_tribute_eff:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(extra_tribute_eff,true)
	end
	--● Destroy it
	local option_1=true
	--● Immediately after this effect resolves, Tribute Summon 1 monster by Tributing monsters including the targeted opponent's monster, even though you do not control it
	local option_2=extra_tribute_eff and Duel.IsExistingMatchingCard(Card.CanSummonOrSet,tp,LOCATION_HAND,0,1,nil,true,nil,1)
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	if choice==1 then
		--● Destroy it
		extra_tribute_eff:Reset()
		Duel.Destroy(tc,REASON_EFFECT)
	elseif choice==2 then
		--● Immediately after this effect resolves, Tribute Summon 1 monster by Tributing monsters including the targeted opponent's monster, even though you do not control it
		local sc=Duel.SelectMatchingCard(tp,Card.CanSummonOrSet,tp,LOCATION_HAND,0,1,1,nil,true,nil,1):GetFirst()
		if sc then
			Duel.SummonOrSet(tp,sc,true,nil,1)
		end
	end
end
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
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
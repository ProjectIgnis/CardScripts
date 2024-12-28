--闘気炎斬剣
--Fighting Flame Sword
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_FLAME_SWORDSMAN,id}
function s.thfilter(c)
	return c:ListsCode(CARD_FLAME_SWORDSMAN) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.disconfilter(c,tp)
	return ((c:IsCode(CARD_FLAME_SWORDSMAN) and c:IsOnField()) or (c:ListsCode(CARD_FLAME_SWORDSMAN) and c:IsLocation(LOCATION_MZONE))) and c:IsFaceup() and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return e:GetLabel()==2 and chkc:IsOnField() and chkc~=c end
	local bc=Duel.GetBattleMonster(tp)
	local b3_event,_,event_p,event_v,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local tg=b3_event and Duel.GetChainInfo(event_v,CHAININFO_TARGET_CARDS) or nil
	--Add 1 card from your Deck to your hand that mentions "Flame Swordsman", except "Fighting Flame Sword"
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	--Destroy 1 card on the field
	local b2=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and bc and bc:IsAttribute(ATTRIBUTE_FIRE) and bc:IsRace(RACE_WARRIOR) and bc:IsFaceup()
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	--Negate an opponent's effect that targets "Flame Swordsman" or a monster(s) that mentions it, that you control
	local b3=b3_event and event_p==1-tp and event_reff:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and tg:IsExists(s.disconfilter,1,nil,tp)
		and Duel.IsChainDisablable(event_v)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(0)
		e:SetLabel(op,event_v)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,event_reff:GetHandler(),1,tp,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op,event_v=e:GetLabel()
	if op==1 then
		--Add 1 card from your Deck to your hand that mentions "Flame Swordsman", except "Fighting Flame Sword"
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--Destroy 1 card on the field
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif op==3 then
		--Negate an opponent's effect that targets "Flame Swordsman" or a monster(s) that mentions it, that you control
		Duel.NegateEffect(event_v)
	end
end
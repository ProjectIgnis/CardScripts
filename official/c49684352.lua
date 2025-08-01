--虹彩の魔術師
--Double Iris Magician
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Make 1 DARK Spellcaster monster you control inflict double battle damage to your opponent this turn if it battles an opponent's monster, then destroy this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Add 1 "Pendulumgraph" card from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_BATTLE|REASON_EFFECT) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PENDULUM_DRAGON,SET_PENDULUMGRAPH}
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsFaceup() and not c:HasFlagEffect(id)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,0)
		--Double any battle damage that monster inflicts to your opponent this turn if it battles an opponent's monster
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(function(e) local bc=e:GetHandler():GetBattleTarget() return bc and bc:IsControler(1-e:GetHandlerPlayer()) end)
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_PENDULUMGRAPH) and c:IsAbleToHand()
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
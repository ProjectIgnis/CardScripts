--オッドアイズ・ペンデュラム・ドラゴン
--Odd-Eyes Pendulum Dragon
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--You can reduce the battle damage you take from an attack involving a Pendulum Monster you control to 0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.nodamcon)
	e1:SetOperation(s.nodamop)
	c:RegisterEffect(e1)
	--Destroy this card, and if you do, add 1 Pendulum Monster with 1500 or less ATK from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--If this card battles an opponent's monster, any battle damage this card inflicts to your opponent is doubled
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(function(e) local bc=e:GetHandler():GetBattleTarget() return bc and bc:IsControler(1-e:GetHandlerPlayer()) end)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
function s.nodamcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==tp and not Duel.HasFlagEffect(tp,id)) then return false end
	local bc1=Duel.GetAttacker()
	local bc2=Duel.GetAttackTarget()
	return (bc1 and bc1:IsPendulumMonster() and bc1:IsControler(tp)) or (bc2 and bc2:IsPendulumMonster() and bc2:IsControler(tp))
end
function s.nodamop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.HasFlagEffect(tp,id) and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.ChangeBattleDamage(tp,0)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.thfilter(c)
	return c:IsPendulumMonster() and c:IsAttackBelow(1500) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
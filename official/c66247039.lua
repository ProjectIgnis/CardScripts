--聖なる心のバリア －マインドフォース－
--Mind Mirror Force
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent controls 5 or more face-up cards, this card's activation and effect cannot be negated, also you can activate this card the turn it was Set
	c:RegisterFlagEffect(id,0,0,1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CANNOT_INACTIVATE)
		ge1:SetValue(function(e,ch)
			local trig_eff=Chain.GetTriggeringEffect(ch)
			local trig_player=Chain.GetTriggeringPlayer(ch)
			return trig_eff:GetHandler():HasFlagEffect(id) and Duel.GetMatchingGroupCount(Card.IsFaceup,trig_player,0,LOCATION_ONFIELD,nil)>=5
		end)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_CANNOT_DISEFFECT)
		Duel.RegisterEffect(ge2,0)
	end)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(function(e)
		return Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,nil)>=5
	end)
	c:RegisterEffect(e0)
	--At any of the following timings: Negate the effects of as many face-up cards your opponent controls as possible, and if you do, destroy them, also your monsters cannot attack directly until the end of the next turn after this card resolves
	--● When the monster your opponent controls with the highest ATK (even if tied) declares an attack
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,1))
	e1a:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1a:SetCondition(s.condition1)
	e1a:SetTarget(s.target)
	e1a:SetOperation(s.activate)
	c:RegisterEffect(e1a)
	--● When your opponent activates a monster effect that would destroy a card(s) on the field
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetCondition(s.condition2)
	c:RegisterEffect(e1b)
	--● When your opponent activates a monster effect in the hand or field during your turn
	local e1c=e1b:Clone()
	e1c:SetCondition(s.condition3)
	c:RegisterEffect(e1c)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	return bc:IsControler(1-tp) and Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack):IsContains(bc)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	--Avoid prompting which effect to activate if both 'condition1' and 'condition2' are true
	local event_chk,event_g,event_p,event_v,event_reff,event_r,event_rp=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE,true)
	if event_chk and s.condition1(e,tp,event_g,event_p,event_v,event_reff,event_r,event_rp) then return false end
	if not (rp==1-tp and re:IsMonsterEffect()) then return false end
	local opinfo_chk,opinfo_g=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return opinfo_chk and opinfo_g and opinfo_g:IsExists(Card.IsOnField,1,nil)
end
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	--Avoid prompting which effect to activate if both 'condition2' and 'condition3' are true
	if s.condition2(e,tp,eg,ep,ev,re,r,rp) then return false end
	return Duel.IsTurnPlayer(tp) and rp==1-tp and re:IsMonsterEffect() and Chain.IsTriggeringLocation(ev,LOCATION_HAND|LOCATION_MZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil):Match(Card.IsCanBeDisabledByEffect,nil,e)
	if #g>0 then
		for nc in g:Iter() do
			--Negate the effects of as many face-up cards your opponent controls as possible, and if you do, destroy them
			nc:NegateEffects(c)
		end
		Duel.AdjustInstantly()
		Duel.Destroy(g,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2),nil,2)
	--Your monsters cannot attack directly until the end of the next turn after this card resolves
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end

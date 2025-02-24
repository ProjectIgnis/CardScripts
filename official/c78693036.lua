--呪雷神ジュラ
--Jura the Curse-Thunder Deity
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Each time your opponent activates a card or effect, gain 300 LP immediately after it resolves
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetOperation(aux.chainreg)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_DELAY)
	e1b:SetCode(EVENT_CHAIN_SOLVED)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(1) end)
	e1b:SetOperation(s.lpop)
	c:RegisterEffect(e1b)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(Cost.AND(Cost.PayLP(1500),Cost.SelfTribute))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Recover(tp,300,REASON_EFFECT)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap),tp,0,LOCATION_ONFIELD,nil)
	local b1=#g1>0
	local b2=#g2>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local g=(op==1 and g1 or g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Destroy all face-up monsters your opponent controls
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		--Destroy all face-up Spells/Traps your opponent controls
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap),tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
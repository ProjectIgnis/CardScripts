--幻獄神メディクリウス
--Medicurius the Power Patron of Illusions
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including a Fusion, Synchro, Xyz, or Link Monster
	Link.AddProcedure(c,nil,2,3,s.linkmatcheck)
	--Gains these effects based on the number of monsters it points to
	--● 1+: Once per turn: You can negate the effects of all face-up monsters your opponent currently controls, also until the end of this turn, their ATK's become halved
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.commoncondition(1))
	e1:SetTarget(s.disableatktg)
	e1:SetOperation(s.disableatkop)
	c:RegisterEffect(e1)
	--● 2+: Unaffected by your opponent's activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.commoncondition(2))
	e2:SetValue(function(e,te)
		return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
	end)
	c:RegisterEffect(e2)
	--● 3: Once per opponent's turn (Quick Effect): You can banish this card, also banish all cards your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp)
		return Duel.IsTurnPlayer(1-tp) and e:GetHandler():GetLinkedGroupCount()==3
	end)
	e3:SetTarget(s.bantg)
	e3:SetOperation(s.banop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
function s.linkmatcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_EXTRA,lc,sumtype,tp)
end
function s.commoncondition(minimum_number)
	return function(e)
		return e:GetHandler():GetLinkedGroupCount()>=minimum_number
	end
end
function s.disableatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,0)
end
function s.disableatkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Negate the effects of all face-up monsters your opponent currently controls
		tc:NegateEffects(c)
		--Also until the end of this turn, their ATK's become halved
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()/2)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if c:IsRelateToEffect(e) and c:IsAbleToRemove() then g:AddCard(c) end
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
--ネジマキシキガミ (Anime)
--Gearspring Spirit (Anime)
local s,id=GetID()
local COUNTER_GEARSPRING=0x107
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by removing 3 Gearspring Counters from your side of the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(function(e,tp) Duel.RemoveCounter(tp,1,0,COUNTER_GEARSPRING,3,REASON_COST) end)
	c:RegisterEffect(e1)
	--ake the ATK of 1 face-up monster your opponent controls 0 until the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,nil) end end)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.counter_list={COUNTER_GEARSPRING}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_GEARSPRING,3,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local sc=Duel.SelectMatchingCard(tp,Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if sc then
		Duel.HintSelection(sc)
		--Its ATK becomes 0 until the end of the turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
	end
end
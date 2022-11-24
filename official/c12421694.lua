--閃刀姫-カイナ
--Sky Striker Ace - Kaina
--Scripted by AlphaKretin

local s,id=GetID()
function s.initial_effect(c)
	--Can only be special summoned once per turn
	c:SetSPSummonOnce(id)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	--Targeted monster cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.natg)
	e1:SetOperation(s.naop)
	c:RegisterEffect(e1)
	--Gain 100 LP each time you activate a "Sky Striker" Spell card or effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():GetFlagEffect(1)>0 end)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SKY_STRIKER}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_SKY_STRIKER,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_ALL-ATTRIBUTE_EARTH,scard,sumtype,tp)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--Cannot attack
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		tc:RegisterEffect(e1)
	end
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsSpellEffect() and rp==tp and c:IsSetCard(SET_SKY_STRIKER) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Recover(tp,100,REASON_EFFECT)
	end
end
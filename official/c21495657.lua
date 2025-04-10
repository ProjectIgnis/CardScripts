--宝竜星－セフィラフウシ
--Zefraxi, Treasure of the Yang Zing
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--You cannot Pendulum Summon monsters, except "Yang Zing" and "Zefra" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) return sumtype&SUMMON_TYPE_PENDULUM==SUMMON_TYPE_PENDULUM and not c:IsSetCard({SET_YANG_ZING,SET_ZEFRA}) end)
	c:RegisterEffect(e1)
	--Treat 1 "Yang Zing" or "Zefra" monster you control, except "Zefraxi, Treasure of the Yang Zing", as a Tuner this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tunercon)
	e2:SetTarget(s.tunertg)
	e2:SetOperation(s.tunerop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_YANG_ZING,SET_ZEFRA}
s.listed_names={id}
function s.tunercon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPendulumSummoned() or c:IsSummonLocation(LOCATION_DECK)
end
function s.tunerfilter(c)
	return c:IsSetCard({SET_YANG_ZING,SET_ZEFRA}) and not c:IsType(TYPE_TUNER) and c:IsFaceup() and not c:IsCode(id)
end
function s.tunertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tunerfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tunerfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tunerfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.tunerop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--That face-up monster is treated as a Tuner this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
	if c:IsRelateToEffect(e) then
		--Place this card on the bottom of the Deck when it leaves the field
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3301)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetValue(LOCATION_DECKBOT)
		e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e2)
	end
end

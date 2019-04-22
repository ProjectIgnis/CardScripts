--マドルチェ・ルセット
--Madolche Recette
--Scripted by Eerie Code
function c120401039.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,120401039+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c120401039.target)
	c:RegisterEffect(e1)
end
function c120401039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(120401039,0),aux.Stringid(120401039,1))
	if op==0 then
		e:SetOperation(c120401039.lvop)
	else
		e:SetOperation(c120401039.nsop)
	end
end
function c120401039.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:GetFlagEffect(120401039)==0
end
function c120401039.lvop(e,tp,eg,ep,ev,re,r,rp)
	c120401039.lvadjust(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(c120401039.lvadjust)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c120401039.lvadjust(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c120401039.lvfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(120401039,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
function c120401039.nsop(e,tp,eg,ep,ev,re,r,rp)
	--extra summon
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x71))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

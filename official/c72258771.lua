--コアキメイル・ヴァラファール
--Koa'ki Meiru Valafar
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn, during your End Phases, send 1 "Iron Core of Koa'ki Meiru" from your hand to the GY or destroy this card
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(tp)
	end)
	e0:SetOperation(s.maintop)
	c:RegisterEffect(e0)
	--You can Tribute Summon this card by Tributing 1 "Koa'ki Meiru" monster
	aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,1),
		function(c,tp)
			return c:IsSetCard(SET_KOAKI_MEIRU) and (c:IsControler(tp) or c:IsFaceup())
		end)
	--Cannot be destroyed by Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,re,rp)
		return re:IsTrapEffect()
	end)
	c:RegisterEffect(e1)
	--If this card attacks a Defense Position monster, inflict piercing battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KOAKI_MEIRU}
s.listed_names={36623431} --"Iron Core of Koa'ki Meiru"
function s.ironcorefilter(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
function s.maintop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	local b1=Duel.IsExistingMatchingCard(s.ironcorefilter,tp,LOCATION_HAND,0,1,nil)
	local b2=true
	--Send 1 "Iron Core of Koa'ki Meiru" from your hand to the GY or destroy this card
	local op=b1 and Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)}) or 2
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.ironcorefilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	elseif op==2 then
		Duel.Destroy(c,REASON_COST)
	end
end
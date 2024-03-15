--魔轟神ディアネイラ
--Fabled Dianaira
local s,id=GetID()
function s.initial_effect(c)
	--Can be Tribute Summoned by Tributing 1 "Fabled" monster
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--The effect of a Normal Spell activated by the opponent becomes "Your opponent discards 1 card"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.chcon1)
	e1:SetOperation(s.chop1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_ACTIVATING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.chcon2)
	e2:SetOperation(s.chop2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FABLED}
function s.otfilter(c,tp)
	return c:IsSetCard(SET_FABLED) and (c:IsControler(tp) or c:IsFaceup())
end
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:GetHandler():IsNormalSpell() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end
function s.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return ev==1 and e:GetHandler():HasFlagEffect(id)
end
function s.chop2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.ChangeChainOperation(1,s.rep_op)
end
function s.rep_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
end

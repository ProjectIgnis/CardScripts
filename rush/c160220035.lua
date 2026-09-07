--雲海翔竜 ヴェルディアス
--Cross Lostream Verdias
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.condtion)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--Cannot be destroyed by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--pos change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.poscon)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
function s.condtion(e)
	return Duel.IsBattlePhase()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_UNION)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCountRush(s.cfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*400
end
function s.con(e)
	return Duel.GetMatchingGroupCountRush(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)>=3
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(160220036)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackAnnouncedCount()~=0 and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
--ナチュル・モスキート
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.atcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--reflect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.refcon)
	e2:SetOperation(s.refop)
	c:RegisterEffect(e2)
end
s.listed_series={0x2a}
function s.atcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x2a),e:GetOwnerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.reftg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x2a)
end
function s.refcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local c=e:GetHandler()
	return ((a~=c and a:IsSetCard(0x2a)) or (d and d~=c and d:IsSetCard(0x2a))) 
		and Duel.GetBattleDamage(tp)>0
end
function s.refop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)+Duel.GetBattleDamage(tp),false)
	Duel.ChangeBattleDamage(tp,0)
end

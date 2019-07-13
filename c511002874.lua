--ジュラシックワールド
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR+RACE_WINGEDBEAST))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--Def
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--immune
	local e4=e2:Clone()
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--change battle target
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42256406,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.cbcon)
	e5:SetOperation(s.cbop)
	c:RegisterEffect(e5)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and e:GetOwnerPlayer()~=te:GetOwnerPlayer()
end
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and bt:IsFaceup() and bt:IsControler(tp) and bt:IsRace(RACE_DINOSAUR+RACE_WINGEDBEAST) 
		and bt:IsAttackPos()
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local at=eg:GetFirst()
	if at:IsAttackPos() and at:IsRelateToBattle() then
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	end
end

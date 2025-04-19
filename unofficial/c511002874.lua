--ジュラシックワールド (Anime)
--Jurassic World (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Dinosaur and Winged Beast monsters gain 300 ATK and DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR|RACE_WINGEDBEAST))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Your opponent cannot target Dinosaur or Winged Beast monsters with Trap effects
	local e4=e2:Clone()
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(s.efilter1)
	c:RegisterEffect(e4)
	--Dinosaur and Winged Beast monsters are unaffected by your opponent's Trap effects
	local e5=e2:Clone()
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.efilter2)
	c:RegisterEffect(e5)
	--Change that monster to Defense Position
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BE_BATTLE_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.cbcon)
	e6:SetOperation(s.cbop)
	c:RegisterEffect(e6)
end
function s.efilter1(e,re,rp)
	return re:IsTrapEffect() and e:GetHandlerPlayer()~=rp
end
function s.efilter2(e,te)
	return te:IsTrapEffect() and e:GetHandlerPlayer()~=te:GetOwnerPlayer()
end
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and bt:IsFaceup() and bt:IsControler(tp) and bt:IsRace(RACE_DINOSAUR|RACE_WINGEDBEAST) 
		and bt:IsAttackPos() and Duel.GetAttacker():IsControler(1-tp)
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local at=eg:GetFirst()
	if at:IsAttackPos() and at:IsRelateToBattle() then
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	end
end
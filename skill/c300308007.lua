--Dino Brain Immunity
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--Flip this card over at the start of the Duel
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Dinosaur monsters on the field cannot change their position by Trap Cards or effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsRace(RACE_DINOSAUR) end)
	e1:SetValue(function(e,te) return (te:IsTrapEffect() and POS_FACEUP|POS_FACEDOWN) or 0x100 end)
	Duel.RegisterEffect(e1,tp)
	--Level 7 or higher Dinosaur monsters on the field cannot be targeted by Spell Cards or effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(0x5f)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c:IsLevelAbove(7) and c:IsRace(RACE_DINOSAUR) end)
	e2:SetValue(function(e,re,rp) return re:IsActiveType(TYPE_SPELL) end)
	Duel.RegisterEffect(e2,tp)
end
